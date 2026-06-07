/**
 * POST /api/ai/breakdown — goal → ordered task list (FR-5.3).
 *
 * Calls Gemini server-side (NFR-2). On AI failure returns a deterministic
 * fallback plan with `fallback: true` so the Plan flow never breaks (FR-5.4).
 *
 * Request:  POST, Authorization: Bearer <token>
 *           body: { goal: string, availableMinutes?: number }
 * Response 200: { tasks: [{ title: string, minutes: number, points: number }],
 *                 fallback: boolean }
 * Errors:   400 (missing/invalid goal), 401 (auth), 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { generateBreakdown } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { goal, availableMinutes } = (req.body ?? {}) as {
    goal?: unknown;
    availableMinutes?: unknown;
  };

  if (typeof goal !== 'string' || goal.trim().length < 3 || goal.length > 500) {
    return sendError(res, 400, 'A non-empty goal (3–500 chars) is required', false);
  }
  const minutes =
    typeof availableMinutes === 'number' && availableMinutes > 0
      ? Math.round(availableMinutes)
      : undefined;

  const result = await generateBreakdown(goal.trim(), minutes);
  sendJson(res, result);
});
