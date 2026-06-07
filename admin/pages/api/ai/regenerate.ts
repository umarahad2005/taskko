/**
 * POST /api/ai/regenerate — regenerate a plan from the same/edited goal (FR-5.5).
 *
 * Like breakdown, but asks Gemini for a DIFFERENT plan, optionally avoiding the
 * tasks from the previous plan. Server-side Gemini (NFR-2); fallback on failure.
 *
 * Request:  POST, Authorization: Bearer <token>
 *           body: { goal: string, availableMinutes?: number, avoid?: string[] }
 * Response 200: { tasks: [{ title, minutes, points }], fallback: boolean }
 * Errors:   400 (invalid goal), 401 (auth), 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { regenerateBreakdown } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { goal, availableMinutes, avoid } = (req.body ?? {}) as {
    goal?: unknown;
    availableMinutes?: unknown;
    avoid?: unknown;
  };

  if (typeof goal !== 'string' || goal.trim().length < 3 || goal.length > 500) {
    return sendError(res, 400, 'A non-empty goal (3–500 chars) is required', false);
  }
  const minutes =
    typeof availableMinutes === 'number' && availableMinutes > 0
      ? Math.round(availableMinutes)
      : undefined;
  const avoidList = Array.isArray(avoid)
    ? avoid.filter((x): x is string => typeof x === 'string').slice(0, 20)
    : undefined;

  const result = await regenerateBreakdown(goal.trim(), minutes, avoidList);
  sendJson(res, result);
});
