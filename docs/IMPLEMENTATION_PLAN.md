# Taskko — Phase 2 Implementation Plan (post-MVP)

**Status:** planning · **Date:** 2026-06-07
**Baseline:** M1–M9 shipped — full app on real Firebase/Firestore, real Gemini (free tier), admin on Vercel, focus timer + notifications + music + jokes + clarifying AI intake.
**Funding note:** everything stays **free** for now (no paywall, no per-user quotas, no billing). Monetization is parked in **M17 (deferred)** until post-funding. Cost/credit is explicitly *not* a constraint for this phase.

Milestones continue the existing numbering (M10+) and map to the agents in `agents/` (owner shown). Effort: **S** ≈ ½–1 day, **M** ≈ 2–3 days, **L** ≈ 4–6 days. Gates per `agents/master-orchestration.md` §4 (G-build/design/spec/test/arch).

---

## Recommended order
**M10 → M11 → M12** (habit loop: reminders + history + reflection) → **M13** (signature AI) → **M16** (real admin data) → **M14** (social) → **M15** (production hardening) → *M17 deferred (monetization)*.

---

## M10 — Scheduled reminders & nudges  ·  owner: flutter-app-agent · **M**
Turn one-time use into a daily habit. Builds on the existing `NotificationService`.
**Scope**
- Nightly **"streak about to break 🔥"** nudge (only if no task done today).
- Daily **"plan your day"** reminder (user-set time).
- **Break reminders** between focus sessions.
- A **Settings → Reminders** screen: toggles + time pickers, persisted.
**Packages:** `timezone` (already pulled in by flutter_local_notifications) + `flutter_timezone` (device tz); use `zonedSchedule`.
**Android:** request `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` (or use inexact for habit reminders to avoid the permission); `POST_NOTIFICATIONS` already handled.
**Data model:** `users/{uid}/settings/reminders` = `{ planDailyEnabled, planTime, streakSaverEnabled, breakRemindersEnabled }`.
**Files:** extend `services/notification_service.dart` (zonedSchedule + cancel), `features/settings/` (cubit + screen), reminder scheduling on app start / settings change.
**Acceptance:** toggles persist; a scheduled notification fires at the set time on device; streak-saver only fires when relevant.

## M11 — Session history & stats  ·  owner: flutter-app-agent · **L**
Make progress visible (drives motivation) and makes the weekly report fully real.
**Scope**
- Log every focus session to Firestore.
- **History screen**: focus-minutes **heatmap/calendar**, tasks done, points over time, **mood trend**.
- Real **weekly report** (Hub) computed from sessions, not estimates.
**Packages:** `fl_chart` (charts) or `table_calendar` (calendar/heatmap).
**Data model:** `users/{uid}/sessions/{id}` = `{ taskId, taskTitle, minutes, completed, moodAtStart, startedAt, endedAt }`.
**Files:** `repositories/.../session_repository*` (interface + firestore + mock), `features/history/` (cubit + screen + chart widgets); wire `FocusTimerScreen._complete()` to write a session; update `GamificationRepositoryFirestore.weeklyReport()` to read sessions.
**Acceptance:** completing a focus session creates a session doc; history screen renders real charts; weekly report numbers match logged sessions.

## M12 — Post-task reflection  ·  owner: flutter-app-agent · **S**
**Scope:** after completing a task/session, a 5-second reflection (emoji 😀😐😫 + optional one-line note) → stored, feeds stats and future AI tone.
**Data model:** add `reflection: { rating, note, at }` to the task/session doc.
**Files:** a `ReflectionSheet` (bottom sheet) shown from `FocusTimerScreen` done-state and/or Home task completion; write to Firestore.
**Acceptance:** reflection persists and appears in history.

## M13 — AI: "Plan my day" + Quiz generator  ·  owner: backend-agent + flutter-app-agent · **L**
Signature AI value for students.
**Scope**
- **Plan my day:** Gemini time-blocks today's tasks around available time + current mood → a schedule.
- **Quiz generator:** topic → multiple-choice quiz, taken in-app with scoring; results saved.
**Backend (redeploy):** `POST /api/ai/plan-day` `{ tasks[], availableMinutes, mood }` → `{ blocks: [{start,end,taskTitle}] }`; `POST /api/ai/quiz` `{ topic, count, difficulty }` → `{ questions: [{q, options[], answerIndex}] }`. Add prompts/parsers to `admin/lib/gemini.ts`; document in `API_CONTRACTS.md`.
**App:** "Plan my day" CTA on Home → schedule view; new **Quiz** feature (entry from Plan/Chat) — quiz screen, scoring, save to `users/{uid}/quizzes/{id}`. New repo methods behind `PlanRepository`/a `QuizRepository`.
**Acceptance:** Plan-my-day returns a sensible schedule; quiz generates, is takeable, scores, and persists.

## M14 — Real squad / social leaderboard  ·  owner: backend-agent + flutter-app-agent · **M**
Current Firestore rules are private-only, so a cross-user leaderboard needs a public surface.
**Scope**
- **Public profile** doc per user (`public_profiles/{uid}` = `{ name, points, rank, avatar }`) written by the owner on profile change, readable by any signed-in user (rules update + redeploy).
- **Friends/squad**: `users/{uid}/friends` or a `squads/{id}`; add-by-email or invite code.
- Real **leaderboard** query over `public_profiles` (or a squad's members); **group streak challenge** (optional).
**Files:** public-profile sync in `GamificationRepositoryFirestore` (mirror on points/mood change), `squad_repository`, update `leaderboard()` to query public profiles, Hub Squad UI for add-friend; **update + deploy `firestore.rules`**.
**Acceptance:** two real accounts appear on each other's leaderboard; ranking is correct; no private data leaks (rules tested).

## M15 — Production hardening  ·  owner: qa-agent + integration-release-agent · **M**
Make it submission/launch-ready.
**Scope**
- **Firebase Crashlytics** + **Analytics** (see crashes + real usage).
- **Firestore offline persistence** + list pagination.
- **CI:** GitHub Action — `flutter analyze` + `flutter test` on push; backend `tsc --noEmit`.
- **Polish:** consistent empty/loading/error states; **accessibility** (contrast, text scaling, semantics).
- **Release:** signed **release keystore** + its SHA in Firebase, Play Store listing assets, **privacy policy** page, app versioning.
- *(Optional, security not cost):* **Firebase App Check** so only the genuine app can call the API.
**Files:** add Crashlytics/Analytics init in `main.dart`; `.github/workflows/ci.yml`; `android/key.properties` + signing config; privacy-policy doc/route.
**Acceptance:** CI green on push; release APK signed; crash/analytics events visible; offline read works.

## M16 — Real admin data (remove all stubs)  ·  owner: backend-agent + admin-web-agent · **M**
Make the admin portal reflect reality (also an earlier request).
**Scope**
- **Users** from Firebase **Auth** (`listUsers`) merged with Firestore profiles; suspend/reinstate via `updateUser(disabled)`; grant-points writes Firestore.
- **Metrics** computed from real Auth/Firestore counts (total users, signups, rank distribution, active streaks).
- **Moderation** + **Settings** from Firestore collections.
- **AI Insights** backed by real **usage logging** (each Gemini call writes `aiLogs/{id}` with feature/latency/fallback) → aggregated.
- **Revenue** shown honestly as "not enabled" (free product) until M17.
**Files:** rewrite `admin/pages/api/admin/*` to use `adminAuth()`/`adminDb()`; add usage logging in `admin/lib/gemini.ts`; redeploy.
**Acceptance:** every admin section shows real data (or honest empty), no `stub:true` anywhere.

## M17 — Monetization (DEFERRED — post-funding)  ·  owner: backend + flutter · **L**
Parked per the funding decision. When revenue is wanted: Free/Pro tiers (SRS §11), per-feature gating, Lemon Squeezy billing, Pro-only report cards/badges, and per-user AI quotas. The data model already leaves a `plan` placeholder.

---

## Cross-cutting notes
- **Redeploys:** M13/M14/M16 change the backend (`admin/`) → push to GitHub, Vercel auto-redeploys. App-only milestones (M10/M11/M12) don't need a redeploy.
- **Each milestone:** keep `flutter analyze` clean, add a `bloc_test`/widget test for new cubits, and run the relevant quality gates before marking done on the board.
- **Sequencing:** M10–M12 are app-only and independent of the backend → fastest wins. M13/M16 share the Gemini/admin backend work.

## Suggested grouping for delivery
| Sprint | Milestones | Theme |
|---|---|---|
| 1 | M10, M11, M12 | Habit loop (reminders, history, reflection) |
| 2 | M13, M16 | Signature AI + real admin |
| 3 | M14, M15 | Social + production-ready |
| later | M17 | Monetization (after funding) |
