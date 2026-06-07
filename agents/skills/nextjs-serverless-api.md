---
name: nextjs-serverless-api
description: Building the Taskko backend as Next.js serverless API routes on Vercel — routing, Firebase Admin token verification, CORS, env secrets, and warm-instance init.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Skill: Next.js Serverless API (Vercel)

The backend is **Next.js `/api` routes on Vercel**, co-located with the React admin app in one project (SRS §2.4, §6).

## Structure
```
admin/ (Next.js project, deployed to Vercel)
  pages/api/ai/{breakdown,regenerate,chat,nudge,mood-session}.ts
  pages/api/me.ts
  pages/api/admin/{metrics,users,moderation,ai-insights,settings}.ts
  lib/firebaseAdmin.ts   ← init once per warm instance
  lib/auth.ts            ← verifyIdToken middleware
  lib/gemini.ts          ← Gemini client + prompts
```

## Auth & security (NFR-2)
- Every route requires `Authorization: Bearer <Firebase ID token>`; verify via Firebase Admin SDK.
- Admin routes additionally require the **admin** custom claim.
- Initialize Firebase Admin **once** (guard against re-init on warm starts).
- Secrets (Gemini key, service account) are **Vercel env vars** — never in the client or repo.
- Set **CORS** to allow the Flutter app origin and the admin origin.

## Conventions
- JSON in/out; consistent error envelope `{ error, retryable }`.
- Keep handlers thin; business logic in `lib/`.
- Respect the serverless execution-time limit (bound Gemini work; see `gemini-ai-integration`).
