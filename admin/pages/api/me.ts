/**
 * GET /api/me — current user profile/claims bootstrap (SRS §6).
 *
 * Verifies the Firebase ID token and returns the caller's identity + claims so
 * the client can bootstrap (e.g. discover the admin flag for FR-3.7 / §3.11).
 *
 * Request:  GET, header Authorization: Bearer <Firebase ID token>. No body.
 * Response 200: { uid: string, email: string|null, name: string|null,
 *                 admin: boolean, claims: object }
 * Errors:   401 { error, retryable } (missing/expired/invalid token)
 */
import type { NextApiResponse } from 'next';
import { withAuth, isAdminClaim, type AuthedRequest } from '../../lib/auth';
import { methodGuard, sendJson } from '../../lib/http';

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET'])) return;

  const u = req.user;
  sendJson(res, {
    uid: u.uid,
    email: u.email ?? null,
    name: (u.name as string | undefined) ?? null,
    admin: isAdminClaim(u),
    claims: {
      // Surface only the custom claims that are safe and useful to the client.
      admin: u.admin ?? false,
      isAdmin: u.isAdmin ?? false,
    },
  });
});
