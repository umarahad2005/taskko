/**
 * /api/admin/settings — real feature flags + admin team (FR-11.8). Admin-only.
 * Flags live in Firestore `config/featureFlags`; the admin team is derived from
 * Firebase Auth users carrying the `admin` custom claim.
 *
 * GET   → { flags, adminTeam }
 * PATCH { flags } → merged { flags, adminTeam }
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';
import { adminAuth, adminDb } from '../../../lib/firebaseAdmin';

const DEFAULT_FLAGS: Record<string, boolean> = {
  aiBreakdownEnabled: true,
  socialSharingEnabled: true,
  moodCheckInEnabled: true,
  squadLeaderboardEnabled: true,
  maintenanceMode: false,
};

const _flagsDoc = () => adminDb().doc('config/featureFlags');

async function adminTeam(): Promise<{ email: string; role: string }[]> {
  const list = await adminAuth().listUsers(1000);
  return list.users
    .filter((u) => u.customClaims?.admin === true || u.customClaims?.isAdmin === true)
    .map((u) => ({ email: u.email ?? u.uid, role: 'admin' }));
}

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET', 'PATCH'])) return;

  if (req.method === 'PATCH') {
    const { flags } = (req.body ?? {}) as { flags?: Record<string, boolean> };
    if (flags && typeof flags === 'object') {
      await _flagsDoc().set(flags, { merge: true });
    }
  }

  const snap = await _flagsDoc().get();
  const flags = { ...DEFAULT_FLAGS, ...(snap.data() ?? {}) };
  sendJson(res, { flags, adminTeam: await adminTeam() });
});
