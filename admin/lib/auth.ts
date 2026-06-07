/**
 * lib/auth.ts — Firebase ID token verification + route wrappers (NFR-2).
 *
 * Every API route requires `Authorization: Bearer <Firebase ID token>`.
 * - withAuth:  verifies the token; rejects missing/expired/invalid with a JSON
 *              error envelope; injects the decoded user onto the request.
 * - withAdmin: additionally requires the `admin` custom claim (FR-11.9).
 *
 * Admin enforcement is strictly server-side — the client never decides admin
 * capability (SRS §3.11 / NFR-2).
 */
import type { NextApiRequest, NextApiResponse } from 'next';
import type { DecodedIdToken } from 'firebase-admin/auth';
import { adminAuth } from './firebaseAdmin';
import { applyCors } from './cors';
import { sendError, withErrorEnvelope } from './http';

/** Authenticated request: decoded token is attached after verification. */
export interface AuthedRequest extends NextApiRequest {
  user: DecodedIdToken;
}

export type AuthedHandler = (
  req: AuthedRequest,
  res: NextApiResponse,
) => Promise<unknown> | unknown;

/** Extract a bearer token from the Authorization header. */
function extractBearer(req: NextApiRequest): string | null {
  const header = req.headers.authorization ?? '';
  const match = /^Bearer\s+(.+)$/i.exec(header);
  return match ? match[1].trim() : null;
}

/**
 * Verify a raw Firebase ID token and return the decoded claims.
 * Throws on invalid/expired tokens (caller maps to a 401).
 */
export async function verifyIdToken(token: string): Promise<DecodedIdToken> {
  // checkRevoked=false keeps verification fast; flip to true if revocation matters.
  return adminAuth().verifyIdToken(token, false);
}

/** Is this decoded token an admin? Accepts `admin` claim or legacy `isAdmin`. */
export function isAdminClaim(decoded: DecodedIdToken): boolean {
  return decoded.admin === true || decoded.isAdmin === true;
}

/**
 * Wrap a handler so it: applies CORS, verifies the bearer token, and injects
 * `req.user`. Unauthenticated/expired requests get a 401 JSON envelope.
 */
export function withAuth(handler: AuthedHandler) {
  return withErrorEnvelope(async (req: NextApiRequest, res: NextApiResponse) => {
    if (applyCors(req, res)) return; // preflight handled

    const token = extractBearer(req);
    if (!token) {
      return sendError(res, 401, 'Missing or malformed Authorization header', false);
    }

    let decoded: DecodedIdToken;
    try {
      decoded = await verifyIdToken(token);
    } catch (err) {
      const expired = (err as { code?: string })?.code === 'auth/id-token-expired';
      return sendError(
        res,
        401,
        expired ? 'ID token expired' : 'Invalid ID token',
        expired, // expired tokens are retryable after refresh
      );
    }

    (req as AuthedRequest).user = decoded;
    return handler(req as AuthedRequest, res);
  });
}

/**
 * Like withAuth, but additionally requires the admin custom claim (FR-11.9).
 * Non-admins receive a 403 JSON envelope.
 */
export function withAdmin(handler: AuthedHandler) {
  return withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
    if (!isAdminClaim(req.user)) {
      return sendError(res, 403, 'Admin privileges required', false);
    }
    return handler(req, res);
  });
}
