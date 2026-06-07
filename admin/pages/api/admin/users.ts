/**
 * /api/admin/users — user management (FR-11.4). Admin-only (FR-11.9).
 *
 * GET  ?filter=all|pro|free|flagged|suspended&q=<search>
 *      → { users: AdminUser[] }
 * POST body: { userId: string, action: 'suspend'|'reinstate'|'grant_points', points?: number }
 *      → { user: AdminUser }
 *
 * Errors: 400 (bad action), 401 (auth), 403 (not admin), 500 { error, retryable }
 *
 * TODO(M9): read/write the real `users/{uid}` Firestore documents.
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';

interface AdminUser {
  id: string;
  name: string;
  email: string;
  plan: 'free' | 'pro';
  rank: string;
  points: number;
  status: 'active' | 'flagged' | 'suspended';
}

const SAMPLE_USERS: AdminUser[] = [
  { id: 'u1', name: 'Sara Khan', email: 'sara@uni.edu', plan: 'pro', rank: 'Pro', points: 1240, status: 'active' },
  { id: 'u2', name: 'Ali Raza', email: 'ali@uni.edu', plan: 'free', rank: 'Elite', points: 2310, status: 'active' },
  { id: 'u3', name: 'Zara Ahmed', email: 'zara@uni.edu', plan: 'free', rank: 'Rookie', points: 480, status: 'flagged' },
  { id: 'u4', name: 'Bilal Toor', email: 'bilal@uni.edu', plan: 'pro', rank: 'Legend', points: 4120, status: 'suspended' },
];

const ACTIONS = new Set(['suspend', 'reinstate', 'grant_points']);

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET', 'POST'])) return;

  if (req.method === 'GET') {
    const filter = String(req.query.filter ?? 'all').toLowerCase();
    const q = String(req.query.q ?? '').toLowerCase().trim();
    let users = SAMPLE_USERS;
    if (filter !== 'all') {
      users = users.filter((u) => u.plan === filter || u.status === filter);
    }
    if (q) {
      users = users.filter((u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q));
    }
    return sendJson(res, { users, stub: true });
  }

  // POST — apply an action.
  const { userId, action, points } = (req.body ?? {}) as {
    userId?: string;
    action?: string;
    points?: number;
  };
  if (!userId || !action || !ACTIONS.has(action)) {
    return sendError(res, 400, 'Provide userId and a valid action', false);
  }
  const base = SAMPLE_USERS.find((u) => u.id === userId) ?? SAMPLE_USERS[0];
  const updated: AdminUser = {
    ...base,
    status: action === 'suspend' ? 'suspended' : action === 'reinstate' ? 'active' : base.status,
    points: action === 'grant_points' ? base.points + (Number(points) || 0) : base.points,
  };
  sendJson(res, { user: updated, stub: true });
});
