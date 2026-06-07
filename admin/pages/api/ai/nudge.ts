/**
 * POST /api/ai/nudge — generate a contextual nudge/action card (FR-7.5).
 *
 * Server-side Gemini (NFR-2). Returns a short motivating nudge plus actionable
 * buttons (e.g. "Start a session", "Remind me in 1h") the client maps to
 * behavior. Fallback nudge on failure (NFR-4).
 *
 * Request:  POST, Authorization: Bearer <token>
 *           body: { context?: { name?, rank?, points?, streakDays?, shields?,
 *                                mood?, pendingTasks?[] } }
 * Response 200: { nudge: { text: string,
 *                          actions: [{ label: string, action: string }] },
 *                 fallback: boolean }
 * Errors:   401 (auth), 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';
import { generateNudge, type UserContext } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { context } = (req.body ?? {}) as { context?: unknown };
  const ctx: UserContext =
    typeof context === 'object' && context !== null ? (context as UserContext) : {};

  const result = await generateNudge(ctx);
  sendJson(res, result);
});
