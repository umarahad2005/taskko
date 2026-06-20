/**
 * lib/gemini.ts — server-only Gemini client + per-feature prompt builders,
 * response parsers, and fallbacks (SRS §6, NFR-2, NFR-4; FR-5.3/5.5/7.2/7.5/9.1).
 *
 * Tako persona: a supportive student study-buddy — concise, motivating, never
 * preachy, and mood-aware (e.g. "Drained" → shorter tasks, gentler tone).
 *
 * Every feature follows the same robustness contract:
 *   build prompt → call Gemini (bounded) → parse/validate → on failure, fallback.
 * Failures are surfaced to callers as retryable so the UI can offer "Retry".
 *
 * Uses the Gemini API (Google Generative Language) with a server-side API key
 * created in the GCP project taskko-498611 (so usage bills to your credits).
 * The key (GEMINI_API_KEY) is read from env only — never shipped to the client.
 */
import { ChatGoogleGenerativeAI } from '@langchain/google-genai';
import { HumanMessage, SystemMessage } from '@langchain/core/messages';
import { FieldValue } from 'firebase-admin/firestore';
import { adminDb } from './firebaseAdmin';

/**
 * Premium model tiers (overridable via env). We deliberately favour accuracy
 * over cost (per product decision): the "pro" tier does the reasoning-heavy
 * structured work (task breakdown, clarifying questions, quizzes) while the
 * "flash" tier handles fast conversational replies (chat, nudges, mood).
 *
 * If a frontier model id is unavailable for the project/key, each call
 * transparently falls back to the matching stable 2.5 model, and only then to
 * the deterministic per-feature fallback — so the AI features never hard-fail.
 */
// Verified against the project's Gemini key (2026-06): `gemini-3.5-flash` and
// `gemini-2.5-flash` return 200, while `gemini-3.1-pro` is 404 and
// `gemini-2.5-pro` is 429 on this plan. So every tier uses 3.5-flash (frontier,
// strong at agentic/structured work) with a 2.5-flash fallback. All env-overridable.
const MODEL_PRO = process.env.GEMINI_MODEL_PRO ?? 'gemini-3.5-flash';
const MODEL_FLASH = process.env.GEMINI_MODEL ?? 'gemini-3.5-flash';
const FALLBACK_PRO = process.env.GEMINI_FALLBACK_PRO ?? 'gemini-2.5-flash';
const FALLBACK_FLASH = process.env.GEMINI_FALLBACK_FLASH ?? 'gemini-2.5-flash';

/** Convenience model selectors spread into generateText options. */
const PRO = { model: MODEL_PRO, fallbackModel: FALLBACK_PRO } as const;
const FLASH = { model: MODEL_FLASH, fallbackModel: FALLBACK_FLASH } as const;

// Gemini 3.x "flash" models *think* before answering, and the thinking tokens
// share the output budget — so a low maxOutputTokens truncates the visible reply
// mid-sentence. We give every call generous headroom (see per-feature values).
// Timeout stays under the Vercel function maxDuration (60s — see route configs).
const GEMINI_TIMEOUT_MS = 50_000;

/** Build a LangChain chat model for a given Gemini model id. */
function makeModel(
  model: string,
  maxOutputTokens: number,
  temperature: number,
  json: boolean,
): ChatGoogleGenerativeAI {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) throw new Error('GEMINI_API_KEY is not set.');
  // `json: true` sets responseMimeType=application/json so structured features
  // reliably parse even when the model would otherwise add prose/fences.
  return new ChatGoogleGenerativeAI({ apiKey, model, maxOutputTokens, temperature, maxRetries: 1, json });
}

/** Thrown when Gemini fails and the caller should return a retryable fallback. */
export class GeminiError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'GeminiError';
  }
}

// ---------------------------------------------------------------------------
// Shared types
// ---------------------------------------------------------------------------

export type Mood = 'fired_up' | 'focused' | 'chill' | 'drained' | string;

/** User context passed to grounded features (chat/nudge/mood) — SRS FR-7.2. */
export interface UserContext {
  name?: string;
  rank?: string;
  points?: number;
  streakDays?: number;
  shields?: number;
  mood?: Mood;
  pendingTasks?: string[];
}

export interface PlanTask {
  title: string;
  minutes: number;
  points: number;
}

export interface NudgeAction {
  label: string;
  /** Action key the client maps to behavior, e.g. start_session / remind_later. */
  action: string;
}

export interface NudgeCard {
  text: string;
  actions: NudgeAction[];
}

export interface MoodSession {
  suggestedMinutes: number;
  taskCount: number;
  tone: string;
  message: string;
}

// ---------------------------------------------------------------------------
// Low-level call with a timeout guard
// ---------------------------------------------------------------------------

interface GenerateOpts {
  /** Primary model id. Defaults to the flash tier. */
  model?: string;
  /** Stable model id to retry with if the primary model errors. */
  fallbackModel?: string;
  /** Hint that we expect JSON back (adds a system nudge; parsing stays tolerant). */
  json?: boolean;
  maxOutputTokens?: number;
  /** Lower temperature for structured/accuracy work, higher for conversational. */
  temperature?: number;
  /** Optional system prompt; defaults to the Tako persona. */
  system?: string;
  feature?: string;
}

/** Invoke one LangChain model with a hard timeout; returns the reply text. */
async function invokeModel(
  modelId: string,
  messages: (SystemMessage | HumanMessage)[],
  maxOutputTokens: number,
  temperature: number,
  json: boolean,
): Promise<string> {
  const model = makeModel(modelId, maxOutputTokens, temperature, json);
  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new GeminiError('Gemini request timed out')), GEMINI_TIMEOUT_MS),
  );
  const result = await Promise.race([model.invoke(messages), timeout]);
  const content = (result as Awaited<ReturnType<typeof model.invoke>>).content;
  const text = typeof content === 'string'
    ? content
    : Array.isArray(content)
      ? content.map((c) => (typeof c === 'string' ? c : (c as { text?: string }).text ?? '')).join('')
      : '';
  if (!text || !text.trim()) throw new GeminiError('Empty response from Gemini');
  return text;
}

/**
 * Run a prompt through LangChain's Gemini chat model. Tries the primary
 * (frontier) model first; on any error retries once with the stable fallback
 * model before giving up — so an unavailable model id never breaks a feature.
 */
async function generateText(prompt: string, opts?: GenerateOpts): Promise<string> {
  const primary = opts?.model ?? MODEL_FLASH;
  const fallback = opts?.fallbackModel;
  // Generous default so thinking tokens never starve the visible answer.
  const maxOutputTokens = opts?.maxOutputTokens ?? 2048;
  const temperature = opts?.temperature ?? (opts?.json ? 0.4 : 0.7);
  const json = opts?.json ?? false;
  const feature = opts?.feature ?? 'unknown';
  const system = opts?.system ?? TAKO_PERSONA;
  const messages: (SystemMessage | HumanMessage)[] = [
    new SystemMessage(json ? `${system}\nRespond with raw JSON only — no markdown, no commentary.` : system),
    new HumanMessage(prompt),
  ];

  const started = Date.now();
  try {
    const text = await invokeModel(primary, messages, maxOutputTokens, temperature, json);
    logUsage(feature, false, Date.now() - started);
    return text;
  } catch (primaryErr) {
    // Frontier model unavailable / transient error → try the stable fallback once.
    if (fallback && fallback !== primary) {
      try {
        const text = await invokeModel(fallback, messages, maxOutputTokens, temperature, json);
        logUsage(feature, false, Date.now() - started);
        return text;
      } catch {
        // fall through to the error below
      }
    }
    logUsage(feature, true, Date.now() - started);
    if (primaryErr instanceof GeminiError) throw primaryErr;
    throw new GeminiError(`Gemini call failed: ${(primaryErr as Error).message}`);
  }
}

const TAKO_PERSONA =
  'You are Tako, the AI study-buddy inside the Taskko app. You support university ' +
  'students who get overwhelmed. Be concise, warm, and motivating — never preachy ' +
  'or condescending. Adapt to the user\'s mood: if they are drained, be gentle and ' +
  'suggest shorter, lighter steps; if they are fired up, match their energy.';

function contextBlock(ctx: UserContext): string {
  const parts: string[] = [];
  if (ctx.name) parts.push(`name: ${ctx.name}`);
  if (ctx.rank) parts.push(`rank: ${ctx.rank}`);
  if (typeof ctx.points === 'number') parts.push(`points: ${ctx.points}`);
  if (typeof ctx.streakDays === 'number') parts.push(`streak: ${ctx.streakDays} days`);
  if (typeof ctx.shields === 'number') parts.push(`shields: ${ctx.shields}`);
  if (ctx.mood) parts.push(`mood: ${ctx.mood}`);
  if (ctx.pendingTasks?.length) parts.push(`pending tasks: ${ctx.pendingTasks.join('; ')}`);
  return parts.length ? `User context — ${parts.join(', ')}.` : 'No user context available.';
}

// ---------------------------------------------------------------------------
// Feature: breakdown (FR-5.3) — goal -> strict JSON [{title,minutes,points}]
// ---------------------------------------------------------------------------

export function buildBreakdownPrompt(goal: string, availableMinutes?: number): string {
  const budget = availableMinutes
    ? `The student has about ${availableMinutes} minutes available today; scope the whole plan to fit within that budget.`
    : 'Aim for a realistic same-day plan (roughly 60–120 minutes total unless the goal clearly needs more).';
  return [
    'A university student wants help achieving this goal:',
    `"""${goal}"""`,
    '',
    'The goal text may include a "Details:" section with answers the student gave to',
    'clarifying questions (subject, scope, deadline, format, count, difficulty). USE those',
    'details — never ignore them — so the plan is specific to THIS student, not generic.',
    '',
    budget,
    '',
    'Produce an ordered, realistic breakdown of small, concrete, actionable steps:',
    '- Each step is a single sitting the student can actually start and finish.',
    '- Titles MUST be specific, action-first, and reference the real subject/subtopics —',
    '  NEVER generic placeholders like "Outline what X needs", "Do the most important part",',
    '  or "Review and wrap up". Name the actual content.',
    '  Example — goal "viva of MAD in Flutter on state management", 3 steps →',
    '    ["Study the state-management overview: what it is and why it is needed",',
    '     "Compare the main approaches: setState, Provider/Riverpod, Bloc, GetX",',
    '     "Revise every topic and self-test with quick Q&A"]. Mirror that specificity.',
    '- If the Details specify a NUMBER of steps/tasks, produce EXACTLY that many.',
    '  Otherwise use 3–8 steps and match the scope.',
    '- Order the steps the way you would actually do them (gather → learn → practise → review).',
    '- minutes: a realistic whole-number estimate (5–90) per step.',
    '- points: 5–50 reflecting the effort/difficulty of that step.',
    '',
    'Respond with ONLY a JSON array in this exact shape (no prose, no markdown fences):',
    '[{"title": string, "minutes": number, "points": number}]',
  ].join('\n');
}

/** Validate + coerce an arbitrary parsed value into PlanTask[]. Throws if invalid. */
export function parseBreakdown(raw: string): PlanTask[] {
  let data: unknown;
  try {
    data = JSON.parse(stripJsonFences(raw));
  } catch {
    throw new GeminiError('Breakdown response was not valid JSON');
  }
  if (!Array.isArray(data) || data.length === 0) {
    throw new GeminiError('Breakdown response was not a non-empty array');
  }

  const tasks: PlanTask[] = [];
  for (const item of data) {
    if (typeof item !== 'object' || item === null) continue;
    const obj = item as Record<string, unknown>;
    const title = typeof obj.title === 'string' ? obj.title.trim() : '';
    const minutes = Number(obj.minutes);
    const points = Number(obj.points);
    if (!title || !Number.isFinite(minutes) || !Number.isFinite(points)) continue;
    tasks.push({
      title: title.slice(0, 140),
      minutes: clamp(Math.round(minutes), 5, 90),
      points: clamp(Math.round(points), 5, 50),
    });
  }
  if (tasks.length === 0) {
    throw new GeminiError('Breakdown contained no valid tasks');
  }
  return tasks;
}

/** Deterministic fallback plan so the Plan flow never crashes (FR-5.4, NFR-4). */
export function fallbackBreakdown(goal: string, availableMinutes?: number): PlanTask[] {
  const total = availableMinutes && availableMinutes > 0 ? availableMinutes : 60;
  const slice = Math.max(15, Math.round(total / 3));
  // No AI available — still reference the actual goal instead of generic placeholders.
  const g = goal.replace(/\s+/g, ' ').replace(/\n?Details:.*/s, '').trim().slice(0, 80);
  return [
    { title: `Gather notes & resources for: ${g}`.slice(0, 140), minutes: slice, points: 15 },
    { title: `Work through the core of: ${g}`.slice(0, 140), minutes: slice, points: 20 },
    { title: `Review & self-test: ${g}`.slice(0, 140), minutes: Math.max(10, total - slice * 2), points: 10 },
  ];
}

export async function generateBreakdown(
  goal: string,
  availableMinutes?: number,
): Promise<{ tasks: PlanTask[]; fallback: boolean }> {
  try {
    const raw = await generateText(buildBreakdownPrompt(goal, availableMinutes), {
      ...PRO,
      json: true,
      temperature: 0.4,
      maxOutputTokens: 6000,
      feature: 'breakdown',
    });
    return { tasks: parseBreakdown(raw), fallback: false };
  } catch (err) {
    logFailure('breakdown', err);
    return { tasks: fallbackBreakdown(goal, availableMinutes), fallback: true };
  }
}

// ---------------------------------------------------------------------------
// Feature: extract-tasks (multimodal) — a photo of a syllabus / assignment
// sheet / whiteboard / handwritten notes / timetable → an ordered task list.
// Reuses the breakdown JSON shape + parser so the app drops straight into the
// existing Plan-review/commit flow.
// ---------------------------------------------------------------------------

export function buildExtractTasksPrompt(): string {
  return [
    'The attached image is a photo from a university student — it could be a',
    'course syllabus, an assignment brief, a lecture slide, a whiteboard, a',
    'class timetable, or handwritten to-do notes.',
    '',
    'Read EVERYTHING legible in the image and turn it into an ordered, actionable',
    'study plan the student can start today:',
    '- Extract concrete tasks/assignments/readings/deadlines that actually appear',
    '  in the image. Titles must be specific and reference the real subject/topic',
    '  or item from the photo — never generic placeholders.',
    '- If a due date or date is visible, fold it into the title (e.g. "Lab report 2 — due Fri").',
    '- Order steps the way a student would actually tackle them.',
    '- minutes: a realistic whole-number estimate (5–90) per step.',
    '- points: 5–50 reflecting the effort/difficulty of that step.',
    '- Produce 3–8 steps. If the image has no legible tasks, return an empty array [].',
    '',
    'Respond with ONLY a JSON array in this exact shape (no prose, no markdown fences):',
    '[{"title": string, "minutes": number, "points": number}]',
  ].join('\n');
}

/**
 * Extract tasks from a base64-encoded image via Gemini's multimodal input.
 * Mirrors generateBreakdown's robustness contract, but on failure returns an
 * EMPTY task list with `fallback: true` (there is no sensible deterministic
 * plan to invent from an unread photo) so the app can prompt a retry.
 */
export async function generateExtractTasks(
  imageBase64: string,
  mimeType: string,
): Promise<{ tasks: PlanTask[]; fallback: boolean }> {
  const dataUrl = `data:${mimeType};base64,${imageBase64}`;
  const messages: (SystemMessage | HumanMessage)[] = [
    new SystemMessage(`${TAKO_PERSONA}\nRespond with raw JSON only — no markdown, no commentary.`),
    new HumanMessage({
      content: [
        { type: 'text', text: buildExtractTasksPrompt() },
        { type: 'image_url', image_url: { url: dataUrl } },
      ],
    }),
  ];

  const started = Date.now();
  try {
    let raw: string;
    try {
      raw = await invokeModel(MODEL_PRO, messages, 6000, 0.4, true);
    } catch (primaryErr) {
      if (FALLBACK_PRO && FALLBACK_PRO !== MODEL_PRO) {
        raw = await invokeModel(FALLBACK_PRO, messages, 6000, 0.4, true);
      } else {
        throw primaryErr;
      }
    }
    const tasks = parseBreakdown(raw);
    logUsage('extract-tasks', false, Date.now() - started);
    return { tasks, fallback: false };
  } catch (err) {
    logUsage('extract-tasks', true, Date.now() - started);
    logFailure('extract-tasks', err);
    return { tasks: [], fallback: true };
  }
}

// ---------------------------------------------------------------------------
// Feature: regenerate (FR-5.5) — same contract as breakdown, different framing
// ---------------------------------------------------------------------------

export async function regenerateBreakdown(
  goal: string,
  availableMinutes?: number,
  avoid?: string[],
): Promise<{ tasks: PlanTask[]; fallback: boolean }> {
  const base = buildBreakdownPrompt(goal, availableMinutes);
  const avoidNote = avoid?.length
    ? `\nProduce a DIFFERENT plan. Avoid repeating these previous tasks: ${avoid.join('; ')}.`
    : '\nProduce a fresh alternative plan with different phrasing and structure.';
  try {
    const raw = await generateText(base + avoidNote, { ...PRO, json: true, temperature: 0.6, maxOutputTokens: 6000, feature: 'regenerate' });
    return { tasks: parseBreakdown(raw), fallback: false };
  } catch (err) {
    logFailure('regenerate', err);
    return { tasks: fallbackBreakdown(goal, availableMinutes), fallback: true };
  }
}

// ---------------------------------------------------------------------------
// Feature: chat (FR-7.2) — Tako reply grounded in user context
// ---------------------------------------------------------------------------

export function buildChatPrompt(message: string, ctx: UserContext): string {
  return [
    contextBlock(ctx),
    '',
    "You can see the student's live stats and their current task list above.",
    "If they ask what they should do, what's left, or what their current/available tasks are,",
    'answer using their ACTUAL pending tasks by name (with rough minutes). If they have no',
    'pending tasks, say so plainly and offer to help plan something new.',
    '',
    `The student says: "${message}"`,
    '',
    'Reply in 1–4 short sentences. Be encouraging, specific, and practical. Plain text only,',
    'no markdown. Ground your reply in their real tasks/stats rather than speaking generically.',
  ].join('\n');
}

/**
 * Build a UserContext for a signed-in user from Firestore: their profile
 * (name/points/streak/mood) and their pending (not-done) tasks for today, so
 * Tako can answer questions like "what are my current tasks?" (FR-7.2).
 *
 * Best-effort: any read failure degrades to an empty/partial context rather
 * than failing the chat request.
 */
export async function loadUserContext(uid: string): Promise<UserContext> {
  const ctx: UserContext = {};
  const db = adminDb();
  try {
    const profile = (await db.collection('users').doc(uid).get()).data() ?? {};
    if (typeof profile.name === 'string') ctx.name = profile.name;
    if (typeof profile.points === 'number') ctx.points = profile.points;
    if (typeof profile.streakDays === 'number') ctx.streakDays = profile.streakDays;
    if (typeof profile.shields === 'number') ctx.shields = profile.shields;
    if (typeof profile.mood === 'string') ctx.mood = profile.mood;
  } catch {
    // ignore — profile is optional context
  }
  try {
    const snap = await db.collection('users').doc(uid).collection('tasks').where('status', '==', 'todo').limit(25).get();
    const pending = snap.docs
      .map((d) => d.data())
      .map((t) => {
        const title = typeof t.title === 'string' ? t.title.trim() : '';
        const minutes = typeof t.minutes === 'number' ? t.minutes : undefined;
        return title ? (minutes ? `${title} (~${minutes}m)` : title) : '';
      })
      .filter((s) => s.length > 0);
    if (pending.length) ctx.pendingTasks = pending;
  } catch {
    // ignore — tasks are optional context
  }
  return ctx;
}

export function fallbackChat(ctx: UserContext): string {
  const name = ctx.name ? `, ${ctx.name}` : '';
  return `I'm having a little trouble thinking right now${name} — but you've got this. Try one small task and tell me how it goes.`;
}

export async function generateChatReply(
  message: string,
  ctx: UserContext,
): Promise<{ reply: string; fallback: boolean }> {
  try {
    const raw = await generateText(buildChatPrompt(message, ctx), { ...FLASH, maxOutputTokens: 3000, feature: 'chat' });
    return { reply: raw.trim(), fallback: false };
  } catch (err) {
    logFailure('chat', err);
    return { reply: fallbackChat(ctx), fallback: true };
  }
}

// ---------------------------------------------------------------------------
// Feature: nudge (FR-7.5) — contextual nudge card with actions
// ---------------------------------------------------------------------------

const NUDGE_ACTIONS: NudgeAction[] = [
  { label: 'Start a session', action: 'start_session' },
  { label: 'Remind me in 1h', action: 'remind_later' },
];

export function buildNudgePrompt(ctx: UserContext): string {
  return [
    TAKO_PERSONA,
    contextBlock(ctx),
    '',
    'Write ONE short, motivating nudge (max 2 sentences) encouraging the student to',
    'take their next small step right now. Plain text only, no quotes, no emojis.',
  ].join('\n');
}

export function fallbackNudge(ctx: UserContext): NudgeCard {
  const streak = ctx.streakDays ? ` Keep your ${ctx.streakDays}-day streak alive!` : '';
  return {
    text: `One small step now beats a perfect plan later.${streak}`,
    actions: NUDGE_ACTIONS,
  };
}

export async function generateNudge(
  ctx: UserContext,
): Promise<{ nudge: NudgeCard; fallback: boolean }> {
  try {
    const raw = await generateText(buildNudgePrompt(ctx), { ...FLASH, maxOutputTokens: 1500, feature: 'nudge' });
    return { nudge: { text: raw.trim(), actions: NUDGE_ACTIONS }, fallback: false };
  } catch (err) {
    logFailure('nudge', err);
    return { nudge: fallbackNudge(ctx), fallback: true };
  }
}

// ---------------------------------------------------------------------------
// Feature: mood-session (FR-9.1) — mood-aware session suggestion (strict JSON)
// ---------------------------------------------------------------------------

export function buildMoodSessionPrompt(mood: Mood, ctx: UserContext): string {
  return [
    TAKO_PERSONA,
    contextBlock({ ...ctx, mood }),
    '',
    `The student's current mood is "${mood}". Suggest a study session tuned to that mood.`,
    'Drained → shorter session, fewer tasks, gentle tone. Fired up → longer, more tasks.',
    '',
    'Respond ONLY with JSON, no prose, in this shape:',
    '{"suggestedMinutes": number, "taskCount": number, "tone": string, "message": string}',
    'suggestedMinutes 10–90, taskCount 1–6, tone is one short word, message max 2 sentences.',
  ].join('\n');
}

export function parseMoodSession(raw: string): MoodSession {
  let data: unknown;
  try {
    data = JSON.parse(stripJsonFences(raw));
  } catch {
    throw new GeminiError('Mood-session response was not valid JSON');
  }
  if (typeof data !== 'object' || data === null) {
    throw new GeminiError('Mood-session response was not an object');
  }
  const obj = data as Record<string, unknown>;
  const suggestedMinutes = Number(obj.suggestedMinutes);
  const taskCount = Number(obj.taskCount);
  const tone = typeof obj.tone === 'string' ? obj.tone.trim() : '';
  const message = typeof obj.message === 'string' ? obj.message.trim() : '';
  if (!Number.isFinite(suggestedMinutes) || !Number.isFinite(taskCount) || !tone || !message) {
    throw new GeminiError('Mood-session response missing required fields');
  }
  return {
    suggestedMinutes: clamp(Math.round(suggestedMinutes), 10, 90),
    taskCount: clamp(Math.round(taskCount), 1, 6),
    tone: tone.slice(0, 24),
    message: message.slice(0, 280),
  };
}

export function fallbackMoodSession(mood: Mood): MoodSession {
  const drained = String(mood).toLowerCase().includes('drain');
  return drained
    ? { suggestedMinutes: 15, taskCount: 1, tone: 'gentle', message: 'Low energy is okay. Just one tiny task — start small and be kind to yourself.' }
    : { suggestedMinutes: 45, taskCount: 3, tone: 'focused', message: "Good energy! Let's lock in a focused block and knock out a few tasks." };
}

export async function generateMoodSession(
  mood: Mood,
  ctx: UserContext,
): Promise<{ session: MoodSession; fallback: boolean }> {
  try {
    const raw = await generateText(buildMoodSessionPrompt(mood, ctx), {
      ...FLASH,
      json: true,
      maxOutputTokens: 2000,
      feature: 'mood-session',
    });
    return { session: parseMoodSession(raw), fallback: false };
  } catch (err) {
    logFailure('mood-session', err);
    return { session: fallbackMoodSession(mood), fallback: true };
  }
}

// ---------------------------------------------------------------------------
// Feature: clarify (smarter task intake, FR-5.2) — ask clarifying questions to
// better classify an ambiguous goal before breaking it down.
// ---------------------------------------------------------------------------

export interface ClarifyQuestion {
  question: string;
  options: string[];
}

export function buildClarifyPrompt(goal: string): string {
  return [
    `A student wants help with this goal/task: "${goal}".`,
    '',
    'Act like a thoughtful tutor: BEFORE planning, ask 2–3 short clarifying questions so the',
    'plan fits exactly what they need. You MUST include both of these:',
    '  1) a question pinning down the SPECIFIC topic / subtopics / scope, and',
    '  2) a question asking HOW MANY steps (tasks) they want the goal broken into.',
    'A third question is optional (deadline / time available / difficulty / format).',
    '',
    'Rules:',
    '- Each question is short and concrete, with 2–4 realistic tappable quick-pick options',
    '  specific to THIS goal (not generic). Example: for a MAD/Flutter state-management viva,',
    '  topic options could be ["Overview + why", "Provider/Riverpod", "Bloc", "GetX"].',
    '- For the "how many steps" question use numeric options like ["3","5","7"].',
    '- Only return [] if the goal ALREADY states both the exact scope AND the number of steps.',
    '',
    'Respond with ONLY a JSON array in this exact shape (no prose, no markdown fences):',
    '[{"question": string, "options": [string]}]',
  ].join('\n');
}

export function parseClarify(raw: string): ClarifyQuestion[] {
  let data: unknown;
  try {
    data = JSON.parse(stripJsonFences(raw));
  } catch {
    return [];
  }
  if (!Array.isArray(data)) return [];
  const out: ClarifyQuestion[] = [];
  for (const item of data) {
    if (typeof item !== 'object' || item === null) continue;
    const o = item as Record<string, unknown>;
    const q = typeof o.question === 'string' ? o.question.trim() : '';
    if (!q) continue;
    const options = Array.isArray(o.options)
      ? o.options.filter((x): x is string => typeof x === 'string').map((s) => s.trim()).slice(0, 4)
      : [];
    out.push({ question: q.slice(0, 160), options });
    if (out.length >= 3) break;
  }
  return out;
}

export async function generateClarify(goal: string): Promise<{ questions: ClarifyQuestion[] }> {
  try {
    const raw = await generateText(buildClarifyPrompt(goal), { ...PRO, json: true, temperature: 0.5, maxOutputTokens: 3000, feature: 'clarify' });
    return { questions: parseClarify(raw) };
  } catch (err) {
    logFailure('clarify', err);
    return { questions: [] };
  }
}

// ---------------------------------------------------------------------------
// Feature: plan-day — time-block today's tasks by available time + mood.
// ---------------------------------------------------------------------------

export interface DayBlock {
  start: string;
  end: string;
  taskTitle: string;
}

export function buildPlanDayPrompt(
  tasks: { title: string; minutes: number }[],
  availableMinutes: number,
  mood: string,
): string {
  const list = tasks.map((t) => `- ${t.title} (~${t.minutes}m)`).join('\n');
  return [
    TAKO_PERSONA,
    '',
    `Schedule today's tasks into time blocks. Student mood: ${mood}. Available: ~${availableMinutes} minutes.`,
    'Add short breaks between work blocks; if the mood is drained, use shorter blocks + more breaks.',
    'Tasks:',
    list || '- (no tasks yet)',
    '',
    'Respond ONLY with JSON, no prose:',
    '[{"start":"HH:MM","end":"HH:MM","taskTitle":string}]  (use taskTitle "Break" for breaks)',
  ].join('\n');
}

export function parsePlanDay(raw: string): DayBlock[] {
  let data: unknown;
  try {
    data = JSON.parse(stripJsonFences(raw));
  } catch {
    return [];
  }
  if (!Array.isArray(data)) return [];
  const out: DayBlock[] = [];
  for (const item of data) {
    if (typeof item !== 'object' || item === null) continue;
    const o = item as Record<string, unknown>;
    const start = typeof o.start === 'string' ? o.start : '';
    const end = typeof o.end === 'string' ? o.end : '';
    const taskTitle = typeof o.taskTitle === 'string' ? o.taskTitle.trim() : '';
    if (start && end && taskTitle) out.push({ start, end, taskTitle: taskTitle.slice(0, 120) });
    if (out.length >= 20) break;
  }
  return out;
}

export async function generatePlanDay(
  tasks: { title: string; minutes: number }[],
  availableMinutes: number,
  mood: string,
): Promise<{ blocks: DayBlock[] }> {
  try {
    const raw = await generateText(buildPlanDayPrompt(tasks, availableMinutes, mood), {
      ...FLASH,
      json: true,
      maxOutputTokens: 3000,
      feature: 'plan-day',
    });
    return { blocks: parsePlanDay(raw) };
  } catch (err) {
    logFailure('plan-day', err);
    return { blocks: [] };
  }
}

// ---------------------------------------------------------------------------
// Feature: quiz — generate a study quiz on a topic.
// ---------------------------------------------------------------------------

export interface QuizQuestion {
  q: string;
  options: string[];
  answerIndex: number;
}

export function buildQuizPrompt(topic: string, count: number, difficulty: string): string {
  return [
    TAKO_PERSONA,
    '',
    `Create a ${difficulty} multiple-choice quiz to help a student study "${topic}".`,
    `Make exactly ${count} questions. Each has 4 plausible options and exactly one correct answer.`,
    '',
    'Respond ONLY with JSON, no prose:',
    '[{"q":string,"options":[string,string,string,string],"answerIndex":number}]  (answerIndex 0-3)',
  ].join('\n');
}

export function parseQuiz(raw: string): QuizQuestion[] {
  let data: unknown;
  try {
    data = JSON.parse(stripJsonFences(raw));
  } catch {
    return [];
  }
  if (!Array.isArray(data)) return [];
  const out: QuizQuestion[] = [];
  for (const item of data) {
    if (typeof item !== 'object' || item === null) continue;
    const o = item as Record<string, unknown>;
    const q = typeof o.q === 'string' ? o.q.trim() : '';
    const options = Array.isArray(o.options)
      ? o.options.filter((x): x is string => typeof x === 'string').map((s) => s.trim()).slice(0, 4)
      : [];
    const ai = Number(o.answerIndex);
    if (q && options.length >= 2 && Number.isFinite(ai)) {
      out.push({
        q: q.slice(0, 300),
        options,
        answerIndex: Math.min(Math.max(0, Math.round(ai)), options.length - 1),
      });
    }
    if (out.length >= 20) break;
  }
  return out;
}

export async function generateQuiz(
  topic: string,
  count: number,
  difficulty: string,
): Promise<{ questions: QuizQuestion[] }> {
  try {
    const raw = await generateText(buildQuizPrompt(topic, count, difficulty), {
      ...PRO,
      json: true,
      temperature: 0.5,
      maxOutputTokens: 8000,
      feature: 'quiz',
    });
    return { questions: parseQuiz(raw) };
  } catch (err) {
    logFailure('quiz', err);
    return { questions: [] };
  }
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

function clamp(n: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, n));
}

/**
 * Strip ```json fences and, if the model still wraps the JSON in prose, isolate
 * the outermost array/object so JSON.parse succeeds anyway (defensive — frontier
 * models occasionally add a sentence despite "JSON only" instructions).
 */
function stripJsonFences(text: string): string {
  const t = text.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/i, '').trim();
  if (t.startsWith('[') || t.startsWith('{')) return t;
  const firstArr = t.indexOf('[');
  const firstObj = t.indexOf('{');
  const start = firstArr === -1 ? firstObj : firstObj === -1 ? firstArr : Math.min(firstArr, firstObj);
  if (start === -1) return t;
  const closeCh = t[start] === '[' ? ']' : '}';
  const end = t.lastIndexOf(closeCh);
  return end > start ? t.slice(start, end + 1) : t;
}

/**
 * Log usage/failure signals for the admin AI Insights view (FR-11.6).
 * M9 wires this to Firestore; for now it is structured console logging.
 */
function logFailure(feature: string, err: unknown): void {
  // eslint-disable-next-line no-console
  console.warn(`[taskko][gemini][${feature}] falling back:`, (err as Error)?.message ?? err);
}

/** Fire-and-forget usage log to Firestore `aiLogs` for the admin AI Insights view (FR-11.6). */
function logUsage(feature: string, fallback: boolean, latencyMs: number): void {
  try {
    void adminDb().collection('aiLogs').add({
      feature,
      fallback,
      latencyMs,
      ts: FieldValue.serverTimestamp(),
    });
  } catch (_) {
    // ignore logging failures
  }
}
