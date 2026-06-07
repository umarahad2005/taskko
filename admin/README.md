# Taskko — Backend + Admin (Next.js on Vercel)

This is the **middle tier** of Taskko (SRS §2.1): one Next.js project on Vercel
that hosts both the serverless **API** (`pages/api/*`) and — from M8 — the React
**admin portal**. It owns the Gemini key and verifies Firebase ID tokens; the key
and admin enforcement never reach the client (NFR-2).

## What's here (M7)
- `lib/firebaseAdmin.ts` — Firebase Admin init (once per warm instance).
- `lib/auth.ts` — `verifyIdToken`, `withAuth`, `withAdmin` (admin claim).
- `lib/gemini.ts` — Gemini client + per-feature prompts/parsers/fallbacks.
- `lib/http.ts`, `lib/cors.ts` — error envelope + CORS helpers.
- `pages/api/ai/*` — breakdown, regenerate, chat, nudge, mood-session.
- `pages/api/admin/*` — metrics, users, moderation, ai-insights, settings (stubbed data; auth is real).
- `pages/api/me.ts` — profile/claims bootstrap.
- `firestore.rules` — Security Rules (deploy to Firebase).
- `API_CONTRACTS.md` — request/response shapes for the app + admin UI.

## Admin web UI (M8)
The same Next.js project also serves the **React admin console** (SRS FR-11.*),
adapted from the approved prototype (`design_reference/project/admin-*.jsx`).

- **Entry:** `pages/index.tsx` → `components/LoginGate.tsx` (loaded client-side).
- **Auth:** Firebase **Web** SDK (`lib/firebaseClient.ts`). Sign in with Google or
  email/password; the console only renders when the `admin` custom claim is
  present. This is **UX only** — every `/api/admin/*` call is independently
  authorized server-side via the admin claim (FR-11.9).
- **API client:** `lib/apiClient.ts` attaches `Authorization: Bearer <ID token>`
  to every request and parses the `{ error, retryable }` envelope.
- **Shell:** `components/AdminLayout.tsx` + `components/Sidebar.tsx` — dark left
  sidebar (6 sections) and a "Switch to student app" top-bar link (FR-11.2).
- **Sections** (`components/sections/*`): Dashboard (FR-11.3), Users (FR-11.4),
  Moderation (FR-11.5), AI Insights (FR-11.6), Revenue (placeholder, FR-11.7),
  Settings (FR-11.8). All wired to `/api/admin/*`.
- **Design tokens:** `lib/theme.ts` + `styles/globals.css` (SRS §7.2 — Manrope /
  Fraunces / JetBrains Mono; accents `#1FB6F0`, `#FF8A65`, `#34D399`, …).

### Required client env vars (admin UI)
Add these to `.env.local` (and to Vercel project settings). They are **public**
by design — `NEXT_PUBLIC_*` is inlined into the browser bundle and contains no
secrets (the Gemini key and admin enforcement stay server-side, NFR-2):

```
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
# optional:
NEXT_PUBLIC_STUDENT_APP_URL=https://app.taskko.app
```

Grant an admin the claim from a trusted context, e.g.:
`admin.auth().setCustomUserClaims(uid, { admin: true })`.

## Setup
1. `npm install` (adds the `firebase` web SDK used by the admin UI)
2. Copy `.env.example` → `.env.local` and fill:
   - `GEMINI_API_KEY` — Google AI Studio key.
   - `FIREBASE_SERVICE_ACCOUNT` — service-account JSON (stringified).
   - `ALLOWED_ORIGINS` — comma-separated client origins (Flutter app / admin).
   - optional `GEMINI_MODEL` (default `gemini-1.5-flash`).
3. `npm run dev` → http://localhost:3000
4. `npm run typecheck` to type-check; `npm run build` for a production build.

## Deploy (M9)
- Push to Vercel; set the same env vars as Vercel project secrets.
- Deploy `firestore.rules` to Firebase (`firebase deploy --only firestore:rules`).

## Status
M7 scaffolds the API and security; **live keys are wired in M9**. Admin endpoints
return `stub: true` payloads until M9 connects them to Firestore.
