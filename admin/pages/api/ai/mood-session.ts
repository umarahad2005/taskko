/**
 * POST /api/ai/mood-session — mood-aware session suggestion (FR-9.1).
 *
 * Server-side Gemini (NFR-2). Given the student's current mood (+ optional
 * context), returns a tuned session: suggested minutes, task count, tone, and a
 * short message. Falls back to a sensible default on failure (NFR-4).
 *
 * Request:  POST, Authorization: Bearer <token>
 *           body: { mood: string, context?: UserContext }
 * Response 200: { session: { suggestedMinutes, taskCount, tone, message },
 *                 fallback: boolean }
 * Errors:   400 (missing mood), 401 (auth), 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { generateMoodSession, type UserContext } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { mood, context } = (req.body ?? {}) as { mood?: unknown; context?: unknown };
  if (typeof mood !== 'string' || mood.trim().length === 0) {
    return sendError(res, 400, 'A "mood" string is required', false);
  }
  const ctx: UserContext =
    typeof context === 'object' && context !== null ? (context as UserContext) : {};

  const result = await generateMoodSession(mood.trim(), ctx);
  sendJson(res, result);
});
