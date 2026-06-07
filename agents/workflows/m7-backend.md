---
name: workflow-m7-backend
description: M7 — Next.js serverless backend on Vercel: AI routes (Gemini), admin routes, Firebase Admin token verification. Runs parallel to the app track.
---

# Workflow M7 — Backend (Vercel / Gemini)

**Owner:** backend-agent · **Depends on:** M1 · **Gates:** G-build, G-arch, G-spec, G-test · **SRS:** §6, NFR-2 · **Parallel with M2–M6**

## Steps
1. **Scaffold** (agent): Next.js project (shared with admin), `lib/firebaseAdmin.ts` (init-once), `lib/auth.ts` (verifyIdToken + admin claim), `lib/gemini.ts`, CORS.
2. **AI prompts** (`ai-prompt`, parallel): breakdown, chat, nudge, mood-session prompts + parsers.
3. **AI routes** (`api-endpoint`, parallel): `/api/ai/{breakdown,regenerate,chat,nudge,mood-session}` (FR-5.3/5.5/7.2/7.5/9.1).
4. **Core/admin routes** (`api-endpoint`, parallel): `/api/me`; `/api/admin/{metrics,users,moderation,ai-insights,settings}` — admin-claim guarded (FR-11.*).
5. **Rules** (`firestore-rules`): author + emulator-test `firestore.rules`.
6. **Tests** (`test-writer`): missing/expired token rejected; non-admin rejected on admin routes; Gemini failure → `{error, retryable}`.
7. **Publish contracts** to flutter-app-agent + admin-web-agent.

## Exit criteria
All routes implemented, guarded, tested; contracts published; G-arch (no client secrets) passes. (Live keys wired in M9.)
