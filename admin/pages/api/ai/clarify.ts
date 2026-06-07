/**
 * POST /api/ai/clarify — smarter task intake (FR-5.2).
 *
 * Given a (possibly vague) goal, Gemini returns up to 3 short clarifying
 * questions (each with quick-pick options) so the app can build a better plan.
 * Returns an empty list if the goal is already specific.
 *
 * Request:  POST, Authorization: Bearer <token>, body: { goal: string }
 * Response 200: { questions: [{ question: string, options: string[] }] }
 * Errors:   400 (missing goal), 401 (auth), 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { generateClarify } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { goal } = (req.body ?? {}) as { goal?: unknown };
  if (typeof goal !== 'string' || goal.trim().length < 3) {
    return sendError(res, 400, 'A goal (min 3 chars) is required', false);
  }

  const result = await generateClarify(goal.trim());
  sendJson(res, result);
});
