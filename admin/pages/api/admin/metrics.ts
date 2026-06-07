/**
 * GET /api/admin/metrics — admin dashboard KPIs + aggregates (FR-11.3).
 *
 * Admin-only (admin custom claim required; FR-11.9). Returns the figures the
 * dashboard renders: KPI cards, an engagement series, rank distribution, top
 * goals, and a live activity feed.
 *
 * Request:  GET, Authorization: Bearer <admin token>
 * Response 200: AdminMetrics (see shape below)
 * Errors:   401 (auth), 403 (not admin), 500 { error, retryable }
 *
 * TODO(M9): replace the stub with real Firestore aggregate queries.
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET'])) return;

  sendJson(res, {
    kpis: {
      dau: 1284,
      signupsToday: 73,
      activeStreaks: 612,
      aiCallsToday: 4190,
      proConversions: 38,
      avgTasksPerUser: 4.7,
    },
    engagement: [
      { day: 'Mon', dau: 1100 },
      { day: 'Tue', dau: 1190 },
      { day: 'Wed', dau: 1240 },
      { day: 'Thu', dau: 1210 },
      { day: 'Fri', dau: 1284 },
      { day: 'Sat', dau: 980 },
      { day: 'Sun', dau: 1020 },
    ],
    rankDistribution: [
      { rank: 'Rookie', count: 540 },
      { rank: 'Pro', count: 410 },
      { rank: 'Elite', count: 240 },
      { rank: 'Legend', count: 94 },
    ],
    topGoals: [
      { goal: 'Midterm prep', users: 312 },
      { goal: 'Final project', users: 201 },
      { goal: 'Daily revision', users: 188 },
    ],
    activityFeed: [
      { type: 'signup', text: 'New student joined', at: 'just now' },
      { type: 'badge', text: 'Sara unlocked “5 streak”', at: '2m ago' },
      { type: 'ai', text: 'Goal broken down into 5 tasks', at: '4m ago' },
    ],
    stub: true,
  });
});
