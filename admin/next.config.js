/** @type {import('next').NextConfig} */
// Taskko backend + admin web (M8) on Vercel (SRS §2.4).
// Keep config minimal; API routes live under pages/api/*.
const nextConfig = {
  reactStrictMode: true,
  // Do not expose any server secrets to the client bundle (NFR-2).
  // Only NEXT_PUBLIC_* vars are inlined client-side. The admin UI (M8) uses the
  // NEXT_PUBLIC_FIREBASE_* keys, which are public by design (Firebase Web config);
  // the Gemini key and admin-claim enforcement stay strictly server-side.
};

module.exports = nextConfig;
