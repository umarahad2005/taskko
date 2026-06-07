/**
 * GET /api/admin/ai-insights — Gemini usage / cost / quality (FR-11.6).
 * Admin-only (FR-11.9).
 *
 * Response 200: AiInsights (usage, cost, quality breakdown, "stuck" phrases,
 *               recent prompt feed).
 * Errors: 401, 403, 500 { error, retryable }
 *
 * TODO(M9): aggregate from the usage/quality signals logged in lib/gemini.ts.
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET'])) return;

  sendJson(res, {
    usage: { callsToday: 4190, calls7d: 26110, avgLatencyMs: 1820, fallbackRate: 0.031 },
    costUsd: { today: 2.14, month: 41.8 },
    quality: [
      { feature: 'breakdown', good: 0.92, fallback: 0.04 },
      { feature: 'chat', good: 0.95, fallback: 0.02 },
      { feature: 'nudge', good: 0.97, fallback: 0.01 },
      { feature: 'mood-session', good: 0.9, fallback: 0.05 },
    ],
    stuckPhrases: ["can't focus", 'too much to do', 'i keep procrastinating', 'overwhelmed'],
    recentPrompts: [
      { feature: 'breakdown', goal: 'Prep CS-201 midterm by Friday', at: '1m ago' },
      { feature: 'chat', message: "I'm stuck on the practice problems", at: '3m ago' },
    ],
    stub: true,
  });
});
