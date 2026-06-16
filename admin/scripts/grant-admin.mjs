/**
 * grant-admin.mjs — one-time bootstrap: give an account the `admin` custom claim
 * so it can use the admin console (in-app + web). Admin is enforced server-side
 * via this claim (SRS §3.11 / NFR-2), so it must be set with the Admin SDK.
 *
 * Usage (from the `admin/` folder):
 *   # service account via env (same value as the Vercel FIREBASE_SERVICE_ACCOUNT):
 *   FIREBASE_SERVICE_ACCOUNT="$(cat serviceAccount.json)" node scripts/grant-admin.mjs admin@taskko.app
 *
 *   # or drop a serviceAccount.json next to this script / in admin/ and run:
 *   node scripts/grant-admin.mjs admin@taskko.app
 *
 * After running, the user must sign out and back in (or refresh their ID token)
 * for the new claim to take effect on the client.
 */
import admin from 'firebase-admin';
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const email = process.argv[2] ?? 'admin@taskko.app';

function loadServiceAccount() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (raw && raw.trim()) {
    let text = raw.trim();
    if (!text.startsWith('{')) text = Buffer.from(text, 'base64').toString('utf8');
    const parsed = JSON.parse(text);
    if (typeof parsed.private_key === 'string') parsed.private_key = parsed.private_key.replace(/\\n/g, '\n');
    return parsed;
  }
  // Fall back to a local serviceAccount.json (admin/ or admin/scripts/).
  for (const p of [join(__dirname, '..', 'serviceAccount.json'), join(__dirname, 'serviceAccount.json')]) {
    if (existsSync(p)) return JSON.parse(readFileSync(p, 'utf8'));
  }
  throw new Error(
    'No credentials. Set FIREBASE_SERVICE_ACCOUNT (raw JSON or base64) or place serviceAccount.json in admin/.',
  );
}

async function main() {
  admin.initializeApp({ credential: admin.credential.cert(loadServiceAccount()) });
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { admin: true });
  // eslint-disable-next-line no-console
  console.log(`✓ Granted admin to ${email} (uid: ${user.uid}). Sign out and back in to refresh the token.`);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('✗ Failed:', err.message);
  process.exit(1);
});
