/**
 * /api/admin/users — real user management (FR-11.4). Admin-only (FR-11.9).
 *
 * GET  ?filter=all|pro|free|flagged|suspended&q=<search> → { users: AdminUser[] }
 *      (Firebase Auth users merged with Firestore `users/{uid}` profiles)
 * POST { userId, action: 'suspend'|'reinstate'|'grant_points', points? } → { user }
 */
import type { NextApiResponse } from 'next';
import { FieldValue } from 'firebase-admin/firestore';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { adminAuth, adminDb } from '../../../lib/firebaseAdmin';

interface AdminUser {
  id: string;
  name: string;
  email: string;
  plan: string;
  rank: string;
  points: number;
  status: 'active' | 'flagged' | 'suspended';
}

function rankForPoints(p: number): string {
  if (p >= 3000) return 'Legend';
  if (p >= 1560) return 'Elite';
  if (p >= 1000) return 'Pro';
  return 'Rookie';
}

function nameFor(p: Record<string, unknown>, displayName?: string, email?: string): string {
  return (p.name as string) || displayName || (email?.split('@')[0] ?? 'Student');
}

async function buildUsers(): Promise<AdminUser[]> {
  const [list, profilesSnap] = await Promise.all([
    adminAuth().listUsers(1000),
    adminDb().collection('users').get(),
  ]);
  const profiles = new Map<string, Record<string, unknown>>();
  profilesSnap.forEach((d) => profiles.set(d.id, d.data()));
  return list.users.map((u) => {
    const p = profiles.get(u.uid) ?? {};
    const points = (p.points as number) ?? 0;
    return {
      id: u.uid,
      name: nameFor(p, u.displayName, u.email),
      email: u.email ?? '',
      plan: (p.plan as string) ?? 'free',
      rank: rankForPoints(points),
      points,
      status: u.disabled ? 'suspended' : ((p.flagged as boolean) ? 'flagged' : 'active'),
    };
  });
}

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET', 'POST'])) return;

  if (req.method === 'GET') {
    const filter = String(req.query.filter ?? 'all').toLowerCase();
    const q = String(req.query.q ?? '').toLowerCase().trim();
    let users = await buildUsers();
    if (filter !== 'all') users = users.filter((u) => u.plan === filter || u.status === filter);
    if (q) users = users.filter((u) => u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q));
    return sendJson(res, { users });
  }

  const { userId, action, points } = (req.body ?? {}) as {
    userId?: string;
    action?: string;
    points?: number;
  };
  if (!userId || !action) return sendError(res, 400, 'Provide userId and action', false);

  if (action === 'suspend') {
    await adminAuth().updateUser(userId, { disabled: true });
  } else if (action === 'reinstate') {
    await adminAuth().updateUser(userId, { disabled: false });
  } else if (action === 'grant_points') {
    await adminDb().collection('users').doc(userId).set({ points: FieldValue.increment(Number(points) || 0) }, { merge: true });
  } else {
    return sendError(res, 400, 'Unknown action', false);
  }

  const u = await adminAuth().getUser(userId);
  const p = (await adminDb().collection('users').doc(userId).get()).data() ?? {};
  const pts = (p.points as number) ?? 0;
  sendJson(res, {
    user: {
      id: u.uid,
      name: nameFor(p, u.displayName, u.email),
      email: u.email ?? '',
      plan: (p.plan as string) ?? 'free',
      rank: rankForPoints(pts),
      points: pts,
      status: u.disabled ? 'suspended' : 'active',
    } satisfies AdminUser,
  });
});
