// Grant the Firebase `admin` custom claim to a user (SRS FR-3.7 / FR-11.9).
//
// Usage (from the admin/ folder):
//   node scripts/set-admin-claim.mjs admin@taskko.app --key serviceAccount.json
// or with the service account in an env var:
//   FIREBASE_SERVICE_ACCOUNT='{...json...}' node scripts/set-admin-claim.mjs admin@taskko.app
//
// The target user must already exist (sign them up once in the app first).
// After granting, they must sign OUT and back IN so their ID token picks up the claim.
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync } from 'node:fs';

function loadServiceAccount() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (raw) {
    let text = raw.trim();
    if (!text.startsWith('{')) text = Buffer.from(text, 'base64').toString('utf8');
    return JSON.parse(text);
  }
  const keyIdx = process.argv.indexOf('--key');
  const path = keyIdx !== -1 ? process.argv[keyIdx + 1] : 'serviceAccount.json';
  return JSON.parse(readFileSync(path, 'utf8'));
}

const email = process.argv.slice(2).find((a) => a.includes('@'));
if (!email) {
  console.error('Usage: node scripts/set-admin-claim.mjs <email> [--key serviceAccount.json]');
  process.exit(1);
}

const sa = loadServiceAccount();
if (typeof sa.private_key === 'string') sa.private_key = sa.private_key.replace(/\\n/g, '\n');

initializeApp({ credential: cert(sa) });
const auth = getAuth();
const user = await auth.getUserByEmail(email);
await auth.setCustomUserClaims(user.uid, { admin: true });
console.log(`Granted admin claim to ${email} (uid ${user.uid}).`);
console.log('They must sign out and back in to refresh the token.');
process.exit(0);
