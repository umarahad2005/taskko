/**
 * POST /api/ai/plan-day — time-block today's tasks (FR-10 / AI planning).
 *
 * Request: { tasks: [{title, minutes}], availableMinutes: number, mood: string }
 * Response 200: { blocks: [{ start, end, taskTitle }] }
 * Errors: 400, 401, 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';
import { generatePlanDay } from '../../../lib/gemini';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const body = (req.body ?? {}) as {
    tasks?: unknown;
    availableMinutes?: unknown;
    mood?: unknown;
  };
  const tasks = Array.isArray(body.tasks)
    ? body.tasks
        .filter((t): t is Record<string, unknown> => typeof t === 'object' && t !== null)
        .map((t) => ({
          title: typeof t.title === 'string' ? t.title : 'Task',
          minutes: Number(t.minutes) || 25,
        }))
    : [];
  const availableMinutes = Number(body.availableMinutes) || 120;
  const mood = typeof body.mood === 'string' ? body.mood : 'focused';

  const result = await generatePlanDay(tasks, availableMinutes, mood);
  sendJson(res, result);
});
