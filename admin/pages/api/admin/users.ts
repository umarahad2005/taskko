/**
 * /api/admin/users — real user management + CRUD (FR-11.4). Admin-only (FR-11.9).
 *
 * GET  ?filter=all|pro|free|flagged|suspended&q=<search> → { users: AdminUser[] }
 *      (Firebase Auth users merged with Firestore `users/{uid}` profiles)
 * POST { action, ... } → { user } | { deleted }
 *   - suspend | reinstate                         { userId }
 *   - grant_points                                { userId, points }
 *   - create   { name, email, password, points?, plan? }
 *   - update   { userId, name?, email?, points?, plan?, status? }
 *   - delete   { userId }
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

/** Re-read a single user (Auth + profile) into the AdminUser shape. */
async function buildOne(userId: string): Promise<AdminUser> {
  const u = await adminAuth().getUser(userId);
  const p = (await adminDb().collection('users').doc(userId).get()).data() ?? {};
  const pts = (p.points as number) ?? 0;
  return {
    id: u.uid,
    name: nameFor(p, u.displayName, u.email),
    email: u.email ?? '',
    plan: (p.plan as string) ?? 'free',
    rank: rankForPoints(pts),
    points: pts,
    status: u.disabled ? 'suspended' : ((p.flagged as boolean) ? 'flagged' : 'active'),
  };
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

  const body = (req.body ?? {}) as {
    userId?: string;
    action?: string;
    points?: number;
    name?: string;
    email?: string;
    password?: string;
    plan?: string;
    status?: string;
  };
  const action = body.action;
  if (!action) return sendError(res, 400, 'Provide an action', false);

  // --- Create -------------------------------------------------------------
  if (action === 'create') {
    const email = (body.email ?? '').trim();
    const password = body.password ?? '';
    const name = (body.name ?? '').trim();
    if (!email || !password) return sendError(res, 400, 'Provide an email and password', false);
    if (password.length < 6) return sendError(res, 400, 'Password must be at least 6 characters', false);
    let created;
    try {
      created = await adminAuth().createUser({
        email,
        password,
        displayName: name || undefined,
        emailVerified: false,
      });
    } catch (err) {
      const code = (err as { code?: string })?.code ?? '';
      if (code === 'auth/email-already-exists') return sendError(res, 409, 'That email is already in use', false);
      if (code === 'auth/invalid-email') return sendError(res, 400, 'That email address looks invalid', false);
      return sendError(res, 400, 'Could not create the account', false);
    }
    await adminDb().collection('users').doc(created.uid).set({
      name: name || email.split('@')[0],
      email,
      points: Number(body.points) || 0,
      plan: body.plan === 'pro' ? 'pro' : 'free',
      flagged: false,
      createdAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    return sendJson(res, { user: await buildOne(created.uid) }, 201);
  }

  // Everything below operates on an existing user.
  const userId = body.userId;
  if (!userId) return sendError(res, 400, 'Provide userId', false);

  // --- Delete -------------------------------------------------------------
  if (action === 'delete') {
    try {
      await adminAuth().deleteUser(userId);
    } catch (err) {
      const code = (err as { code?: string })?.code ?? '';
      if (code !== 'auth/user-not-found') return sendError(res, 400, 'Could not delete the account', false);
    }
    await adminDb().collection('users').doc(userId).delete().catch(() => {});
    return sendJson(res, { deleted: userId });
  }

  // --- Update -------------------------------------------------------------
  if (action === 'update') {
    const authPatch: Record<string, unknown> = {};
    const profilePatch: Record<string, unknown> = {};
    if (typeof body.name === 'string') {
      authPatch.displayName = body.name.trim();
      profilePatch.name = body.name.trim();
    }
    if (typeof body.email === 'string' && body.email.trim()) {
      authPatch.email = body.email.trim();
      profilePatch.email = body.email.trim();
    }
    if (typeof body.points === 'number') profilePatch.points = Number(body.points) || 0;
    if (typeof body.plan === 'string') profilePatch.plan = body.plan === 'pro' ? 'pro' : 'free';
    if (typeof body.status === 'string') {
      authPatch.disabled = body.status === 'suspended';
      profilePatch.flagged = body.status === 'flagged';
    }
    try {
      if (Object.keys(authPatch).length) await adminAuth().updateUser(userId, authPatch);
    } catch (err) {
      const code = (err as { code?: string })?.code ?? '';
      if (code === 'auth/email-already-exists') return sendError(res, 409, 'That email is already in use', false);
      if (code === 'auth/invalid-email') return sendError(res, 400, 'That email address looks invalid', false);
      return sendError(res, 400, 'Could not update the account', false);
    }
    if (Object.keys(profilePatch).length) {
      await adminDb().collection('users').doc(userId).set(profilePatch, { merge: true });
    }
    return sendJson(res, { user: await buildOne(userId) });
  }

  // --- Status / points actions -------------------------------------------
  if (action === 'suspend') {
    await adminAuth().updateUser(userId, { disabled: true });
  } else if (action === 'reinstate') {
    await adminAuth().updateUser(userId, { disabled: false });
    await adminDb().collection('users').doc(userId).set({ flagged: false }, { merge: true });
  } else if (action === 'grant_points') {
    await adminDb().collection('users').doc(userId).set({ points: FieldValue.increment(Number(body.points) || 0) }, { merge: true });
  } else {
    return sendError(res, 400, 'Unknown action', false);
  }

  sendJson(res, { user: await buildOne(userId) });
});
