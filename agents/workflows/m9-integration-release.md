---
name: workflow-m9-integration-release
description: M9 — Final integration and release: swap mock repos for real Firebase/Gemini, deploy rules + admin/API to Vercel, seed demo data + accounts, build APK, smoke-test.
---

# Workflow M9 — Integration & Release

**Owner:** integration-release-agent · **Depends on:** M2–M8 green + live keys · **Gates:** all · **SRS:** Deliverables, §2.1, §10

## Preconditions (user-provided — escalate if missing)
Firebase project (Auth providers + Firestore), Gemini API key, Vercel account. Confirm before any cost-bearing/irreversible step (master §7).

## Steps
1. **Provision guide** (agent): walk the user through Firebase + Gemini + Vercel env setup.
2. **Real repos** (`repository`, parallel): Firebase/Gemini-backed impls for auth, tasks, gamification, plan (→`/api/ai/breakdown`), chat (→`/api/ai/chat`). Flip DI from mock → real (no UI change).
3. **Rules deploy** (`firestore-rules`): deploy + verify `firestore.rules`.
4. **Deploy** (agent): push Next.js admin+API to **Vercel**; set env secrets; verify CORS + token flow end-to-end.
5. **Seed** (agent): demo data (tasks/streaks/badges/leaderboard) + **student & admin demo accounts** for the viva.
6. **APK** (agent): build the Android release APK; install + smoke-test full flow on the emulator.
7. **Gate** (qa-agent): all gates end-to-end against SRS §10; design-audit spot-check; G-arch final pass.

## Exit criteria
Live admin on Vercel + live Firebase, real Gemini answering, seeded demo accounts working, installable APK; every SRS §10 acceptance item demoable. **Release-ready.**
