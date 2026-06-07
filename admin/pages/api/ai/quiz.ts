/**
 * POST /api/ai/quiz — generate a study quiz on a topic.
 *
 * Request: { topic: string, count?: number, difficulty?: 'easy'|'medium'|'hard' }
 * Response 200: { questions: [{ q, options[], answerIndex }] }
 * Errors: 400 (missing topic), 401, 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { generateQuiz } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { topic, count, difficulty } = (req.body ?? {}) as {
    topic?: unknown;
    count?: unknown;
    difficulty?: unknown;
  };
  if (typeof topic !== 'string' || topic.trim().length < 2) {
    return sendError(res, 400, 'A topic is required', false);
  }
  const n = Math.min(Math.max(Number(count) || 5, 3), 10);
  const diff = typeof difficulty === 'string' ? difficulty : 'medium';

  const result = await generateQuiz(topic.trim(), n, diff);
  sendJson(res, result);
});
