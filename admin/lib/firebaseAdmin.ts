/**
 * lib/firebaseAdmin.ts — Firebase Admin SDK initialized ONCE per warm instance.
 *
 * SRS §2.1 / NFR-2: every serverless function verifies Firebase ID tokens via the
 * Admin SDK. On Vercel, warm instances persist module state between invocations,
 * so we guard against re-initialization with `getApps()`.
 *
 * The service account is read from the FIREBASE_SERVICE_ACCOUNT env var, which may
 * be either raw JSON or a base64-encoded JSON blob (both are accepted so it can be
 * pasted into the Vercel dashboard either way). The key is server-side only.
 */
import {
  cert,
  getApps,
  initializeApp,
  type App,
  type ServiceAccount,
} from 'firebase-admin/app';
import { getAuth, type Auth } from 'firebase-admin/auth';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';

let cachedApp: App | undefined;

/** Parse FIREBASE_SERVICE_ACCOUNT (raw JSON or base64) into a ServiceAccount. */
function loadServiceAccount(): ServiceAccount {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (!raw) {
    throw new Error(
      'FIREBASE_SERVICE_ACCOUNT is not set. Provide the Firebase service-account JSON (raw or base64).',
    );
  }

  let jsonText = raw.trim();
  // If it does not look like JSON, assume it is base64-encoded.
  if (!jsonText.startsWith('{')) {
    try {
      jsonText = Buffer.from(jsonText, 'base64').toString('utf8');
    } catch {
      throw new Error('FIREBASE_SERVICE_ACCOUNT could not be base64-decoded.');
    }
  }

  let parsed: Record<string, unknown>;
  try {
    parsed = JSON.parse(jsonText) as Record<string, unknown>;
  } catch {
    throw new Error('FIREBASE_SERVICE_ACCOUNT is not valid JSON.');
  }

  // Private keys pasted into env vars often have literal "\n" sequences; restore them.
  if (typeof parsed.private_key === 'string') {
    parsed.private_key = parsed.private_key.replace(/\\n/g, '\n');
  }

  return parsed as unknown as ServiceAccount;
}

/** Get the singleton Firebase Admin app, initializing it once if needed. */
export function getAdminApp(): App {
  if (cachedApp) return cachedApp;

  const existing = getApps();
  if (existing.length > 0) {
    cachedApp = existing[0];
    return cachedApp;
  }

  cachedApp = initializeApp({
    credential: cert(loadServiceAccount()),
  });
  return cachedApp;
}

/** Firebase Admin Auth instance (token verification, custom claims). */
export function adminAuth(): Auth {
  return getAuth(getAdminApp());
}

/** Firestore instance (used by admin routes from M9 onward). */
export function adminDb(): Firestore {
  return getFirestore(getAdminApp());
}
