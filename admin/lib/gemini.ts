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
import { GoogleGenerativeAI } from '@google/generative-ai';

const DEFAULT_MODEL = process.env.GEMINI_MODEL ?? 'gemini-2.5-flash';
// Bound Gemini work to stay under the Vercel function limit (NFR-1, §9 risk).
const GEMINI_TIMEOUT_MS = 20_000;

let cachedClient: GoogleGenerativeAI | undefined;

function client(): GoogleGenerativeAI {
  if (cachedClient) return cachedClient;
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new Error('GEMINI_API_KEY is not set.');
  cachedClient = new GoogleGenerativeAI(key);
  return cachedClient;
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

async function generateText(
  prompt: string,
  opts?: { json?: boolean; maxOutputTokens?: number },
): Promise<string> {
  const model = client().getGenerativeModel({
    model: DEFAULT_MODEL,
    generationConfig: {
      maxOutputTokens: opts?.maxOutputTokens ?? 1024,
      temperature: 0.7,
      ...(opts?.json ? { responseMimeType: 'application/json' } : {}),
    },
  });

  const timeout = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new GeminiError('Gemini request timed out')), GEMINI_TIMEOUT_MS),
  );

  try {
    const result = await Promise.race([model.generateContent(prompt), timeout]);
    const text = (result as Awaited<ReturnType<typeof model.generateContent>>).response.text();
    if (!text || !text.trim()) throw new GeminiError('Empty response from Gemini');
    return text;
  } catch (err) {
    if (err instanceof GeminiError) throw err;
    throw new GeminiError(`Gemini call failed: ${(err as Error).message}`);
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
    ? `The student has about ${availableMinutes} minutes available; scope the plan to fit within that budget.`
    : 'Aim for a realistic same-day plan.';
  return [
    TAKO_PERSONA,
    '',
    `Break this student goal into an ordered list of small, actionable tasks: "${goal}".`,
    budget,
    'Each task: a short actionable title, an estimated duration in whole minutes (5–90),',
    'and a point value (5–50) reflecting effort. Keep it to 3–8 tasks.',
    '',
    'Respond ONLY with a JSON array, no prose, no markdown fences, in this exact shape:',
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
  return [
    { title: `Outline what "${goal}" needs`.slice(0, 140), minutes: slice, points: 15 },
    { title: 'Do the most important part first', minutes: slice, points: 20 },
    { title: 'Review and wrap up', minutes: Math.max(10, total - slice * 2), points: 10 },
  ];
}

export async function generateBreakdown(
  goal: string,
  availableMinutes?: number,
): Promise<{ tasks: PlanTask[]; fallback: boolean }> {
  try {
    const raw = await generateText(buildBreakdownPrompt(goal, availableMinutes), {
      json: true,
      maxOutputTokens: 1024,
    });
    return { tasks: parseBreakdown(raw), fallback: false };
  } catch (err) {
    logFailure('breakdown', err);
    return { tasks: fallbackBreakdown(goal, availableMinutes), fallback: true };
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
    const raw = await generateText(base + avoidNote, { json: true, maxOutputTokens: 1024 });
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
    TAKO_PERSONA,
    contextBlock(ctx),
    '',
    `The student says: "${message}"`,
    '',
    'Reply in 1–3 short sentences. Be encouraging and practical. Plain text only.',
  ].join('\n');
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
    const raw = await generateText(buildChatPrompt(message, ctx), { maxOutputTokens: 400 });
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
    const raw = await generateText(buildNudgePrompt(ctx), { maxOutputTokens: 200 });
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
      json: true,
      maxOutputTokens: 300,
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
    TAKO_PERSONA,
    '',
    `A student wants help with this goal/task: "${goal}".`,
    'If it is ambiguous, ask up to 3 SHORT clarifying questions that would let you',
    'build a far more specific, useful plan (e.g. subject, scope, deadline, format,',
    'difficulty, number of items). For each question, suggest 2-4 quick-pick options.',
    'If the goal is already clear and specific, return an empty array.',
    '',
    'Respond ONLY with JSON, no prose, in this shape:',
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
    const raw = await generateText(buildClarifyPrompt(goal), { json: true, maxOutputTokens: 400 });
    return { questions: parseClarify(raw) };
  } catch (err) {
    logFailure('clarify', err);
    return { questions: [] };
  }
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

function clamp(n: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, n));
}

/** Strip ```json fences if the model wraps output despite instructions. */
function stripJsonFences(text: string): string {
  return text
    .trim()
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/\s*```$/i, '')
    .trim();
}

/**
 * Log usage/failure signals for the admin AI Insights view (FR-11.6).
 * M9 wires this to Firestore; for now it is structured console logging.
 */
function logFailure(feature: string, err: unknown): void {
  // eslint-disable-next-line no-console
  console.warn(`[taskko][gemini][${feature}] falling back:`, (err as Error)?.message ?? err);
}
