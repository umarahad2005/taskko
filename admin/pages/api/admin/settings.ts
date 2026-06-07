/**
 * /api/admin/settings — feature flags + admin team (FR-11.8). Admin-only.
 *
 * GET   → { flags: Record<string, boolean>, adminTeam: AdminMember[] }
 * PATCH body: { flags?: Record<string, boolean> } → echoes the merged settings
 *
 * Errors: 401, 403, 500 { error, retryable }
 * TODO(M9): persist to `config/featureFlags` and the admin team in Firestore.
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';

interface AdminMember {
  email: string;
  role: 'owner' | 'admin';
}

const DEFAULT_FLAGS: Record<string, boolean> = {
  aiBreakdownEnabled: true,
  socialSharingEnabled: true,
  moodCheckInEnabled: true,
  squadLeaderboardEnabled: true,
  maintenanceMode: false,
};

const ADMIN_TEAM: AdminMember[] = [
  { email: 'admin@taskko.app', role: 'owner' },
];

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET', 'PATCH'])) return;

  if (req.method === 'GET') {
    return sendJson(res, { flags: DEFAULT_FLAGS, adminTeam: ADMIN_TEAM, stub: true });
  }

  const { flags } = (req.body ?? {}) as { flags?: Record<string, boolean> };
  const merged = { ...DEFAULT_FLAGS, ...(flags ?? {}) };
  sendJson(res, { flags: merged, adminTeam: ADMIN_TEAM, stub: true });
});
