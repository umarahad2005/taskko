# Software Requirements Specification (SRS)
## Taskko — Your AI Productivity Companion

| | |
|---|---|
| **Project** | Taskko (Mobile Application Development – MAD Project) |
| **Institution** | Riphah International University, Lahore |
| **Team** | Umar Ahad Uddin Ahmed Usmani (SAP 60199) · Muhammad Sharjeel (SAP 59385) |
| **Document** | Software Requirements Specification |
| **Version** | 1.2 (Draft for approval) |
| **Date** | 4 June 2026 |
| **Status** | Pending stakeholder approval |

> This SRS is the agreed baseline for development. It is based on the project proposal (`Taskko_Proposal.pptx`) and the approved hi-fi UI prototype (Claude Design handoff bundle, `capture-frames.html` + 8 phone screens + admin portal). Once approved, it governs scope; changes go through a change note appended to §12.

---

## 1. Introduction

### 1.1 Purpose
This document specifies the functional and non-functional requirements for **Taskko**, a cross-platform mobile application that helps students stay productive by combining **AI-powered goal breakdown**, **gamification**, and **social accountability**. It is intended to be detailed enough to drive design, implementation, and testing.

### 1.2 Intended Audience
- **Development team** — primary implementers (Flutter app, Node/Express API, Firebase/Gemini integration).
- **Course supervisor / evaluators** — to assess scope, feasibility, and completeness.
- **Future maintainers** — to extend the app (e.g., the monetization features deferred to §11).

### 1.3 Project Scope
Taskko targets the **student productivity crisis**: overwhelming goals, no accountability, no motivation loop, and burnout. The app:
- Breaks big goals into bite-sized, actionable tasks using AI (Gemini).
- Rewards progress through points, ranks (Rookie → Legend), milestone badges, daily streaks, and streak shields.
- Adds a social layer: badge sharing, weekly report cards, and squad leaderboards.
- Provides an AI companion ("Tako") for chat support and motivational nudges, plus a mood check-in that adapts the study session.
- Offers productivity tools: break reminders, post-task reflections, session history, and a stats dashboard.
- Includes a **web/desktop admin portal** for elevated users to manage users, moderation, AI insights, and app settings.

**In scope (this build):** all 8 phone screens, the admin portal, real Gemini AI via the backend, Firebase Auth + Firestore.
**Out of scope (this build):** real subscription billing / Lemon Squeezy and paid feature-gating, and the iOS build — see §11.

**Deliverables (this build):** a runnable **Android APK** (emulator/phone demo), the **React admin portal live on Vercel** backed by a **live Firebase** project, and **seeded demo data + ready-made student & admin accounts** for the viva.

### 1.4 Definitions, Acronyms & Abbreviations
| Term | Meaning |
|---|---|
| MAD | Mobile Application Development (the course) |
| Tako | The app's AI companion / mascot |
| Streak | Consecutive days with at least one completed task |
| Streak shield | A consumable that protects a streak from breaking on a missed day |
| Rank | Progression tier earned from points: Rookie → Pro → Elite → Legend |
| Squad | A group of friends/peers shown in the leaderboard |
| Report card | A weekly, shareable summary of the user's progress |
| Mood check-in | A quick emotional self-report that tunes the study session |
| FR / NFR | Functional / Non-Functional Requirement |
| Admin | A registered user granted elevated permissions (admin portal access) |

### 1.5 References
- Project proposal: `Taskko_Proposal.pptx` (problem, solution, feature list, competitor analysis, tech stack, monetization).
- UI prototype: design handoff bundle in `design_reference/` (`capture-frames.html`, `screens.jsx`, `auth.jsx`, `components.jsx`, admin `*.jsx`, rendered frames in `project/frames/`).
- Don Norman's design principles; Gestalt principles (HCI basis of the prototype).

---

## 2. Overall Description

### 2.1 Product Perspective
Taskko is a **new, self-contained product** (not a component of an existing system). It follows a **client → API → cloud** model:

The system has **three sides**: (1) the **Flutter** mobile client, (2) a single **Vercel** project that hosts *both* the **React admin web app** and the **Node serverless API** (`/api/*`), and (3) the managed services **Firebase** (Auth + Firestore) and **Gemini**.

```
   ┌─────────────────────────────┐         ┌─────────────────────────────┐
   │   Flutter App (Android/iOS)  │         │   Admin Web — React on        │
   │   8 phone screens + state    │         │   Vercel (dashboard/users…)   │
   └───────────────┬─────────────┘         └───────────────┬─────────────┘
                   │                                        │
   Firebase SDK (Auth + Firestore, real-time)      fetch + Firebase ID token
                   │                                        │
                   │        ┌───────────────────────────────┘
                   │        │  HTTPS (Bearer ID token)
        ┌──────────▼────────▼──────────────────────────────────────┐
        │   VERCEL  —  Node serverless functions  (/api/*)          │
        │   AI proxy (Gemini) · admin/privileged ops · token verify │
        │   + serves the React admin app from the same project      │
        └─────────┬───────────────────────────────────┬────────────┘
                  │ server-side key                    │ Admin SDK (verify token)
            ┌─────▼──────┐                  ┌───────────▼───────────────┐
            │ Gemini API │                  │ Firebase: Auth + Firestore │
            └────────────┘                  │ users·tasks·badges·streaks │
                                            └────────────────────────────┘
   Note: Flutter also reads/writes Firestore directly (under Security Rules) for everyday CRUD;
   it calls the Vercel API only for AI + privileged operations.
```

**Division of responsibility (decided with stakeholder):**
- **Flutter ↔ Firestore directly** for everyday CRUD and real-time data: tasks, completion, points, streaks, badges, leaderboard reads. Guarded by Firestore Security Rules.
- **Flutter / Admin ↔ Vercel serverless API** for anything that must not run on the client: **all Gemini calls** (API key stays server-side; lower perceived latency vs. direct device→Gemini and centralised prompt control), plus admin/privileged operations and aggregate analytics.
- **React admin app** is deployed on the **same Vercel project** as the serverless API and reuses the prototype's existing React admin components.
- **Firebase Auth** issues ID tokens; every serverless function verifies them via the Firebase Admin SDK (initialized once per warm instance).

### 2.2 Product Functions (summary)
1. Onboarding & authentication (splash, 3-slide tour, sign up, login, Google Sign-In).
2. Home dashboard (streak, rank, mood check-in, "Next up" CTA, today's tasks).
3. AI Plan Studio (goal → AI-generated step-by-step plan, editable, commit to today).
4. Gamification Hub (badges grid, squad leaderboard, weekly report card + sharing).
5. Tako AI chatbot (conversational support, quick prompts, actionable nudges).
6. Gamification engine (points, ranks, streaks, shields, badge unlocks, feedback).
7. Productivity tools (break reminders, post-task reflection, session history, stats).
8. Admin portal (dashboard KPIs, user management, moderation, AI insights, settings).

### 2.3 User Classes and Characteristics
| User class | Description | Key needs |
|---|---|---|
| **Student (primary)** | University students, mobile-first, motivation-seeking, easily overwhelmed. | Fast task start, clear progress, motivating but non-overwhelming UI. |
| **Admin** | A registered user with elevated permissions (a flag on their account). | Oversight: usage KPIs, user moderation, AI cost/quality, feature flags. |
| **Guest (transient)** | A user in the pre-auth flow (splash/onboarding). | Understand the app's value, sign up with minimal friction. |

### 2.4 Operating Environment
- **Mobile app:** Flutter (current stable SDK; Dart ≥ 3.x per `pubspec.yaml`), targeting **Android** for this build (iOS deferred — see §11; the design uses an iOS-style frame purely for visual reference). Phone form factor, portrait, ~402×874 logical reference frame.
- **Admin portal:** desktop web (wider aspect). Implemented as a **React app deployed on Vercel** (reuses the prototype's existing React admin components).
- **Backend:** **Node serverless functions on Vercel** (same project as the admin web app; e.g. Next.js API routes or a `/api` functions folder); HTTPS only.
- **Cloud services:** Firebase Authentication, Cloud Firestore, Google Gemini API.

### 2.5 Design & Implementation Constraints
- **Front-end:** Flutter + Material, custom theming to match the prototype's design tokens (§7).
- **State management:** `flutter_bloc` — **Cubit-first** (explicit loading/success/error states for async auth and AI calls), with full event-based BLoC only where event streams add value.
- **AI:** real **Gemini API**, always invoked **through the Node/Express server** (never directly from the client; the key is never shipped in the app).
- **Auth:** Firebase Auth (email/password + Google Sign-In).
- **Pixel fidelity:** the UI must match the approved prototype (colors, type, radii, spacing) — recreate the visual output natively, not copy prototype HTML structure.
- **Original branding:** the "Tako" mascot and Taskko logo are original (no copyrighted/branded UI).
- **No payments** in this build (no Lemon Squeezy SDK, no real billing).

### 2.6 Assumptions & Dependencies
- A funded/available **Gemini API key** exists and is stored as a server-side secret.
- A **Firebase project** is provisioned (Auth providers enabled, Firestore created).
- Devices/admins have internet connectivity for AI, auth, and sync; the app degrades gracefully offline for already-loaded data.
- This is a **free** project for the course — no revenue features required now.
- Firebase and Gemini are provisioned **later**; until then the app is built against a **repository/service abstraction with mock implementations**, so screens run immediately and the real Firebase/Gemini backends swap in without UI changes. Setup is guided step-by-step when keys are ready.

---

## 3. Functional Requirements

Requirements are grouped by feature. Each has an ID (`FR-x.y`) and a priority: **(M)** Must, **(S)** Should, **(C)** Could. Acceptance criteria are summarised in §10.

### 3.1 Splash & Branding (Screen: Splash)
- **FR-1.1 (M)** On launch the app shows a branded splash screen with the Taskko logo (gradient sky-blue squircle + checkmark + peach spark) on the brand background.
- **FR-1.2 (M)** The splash auto-advances after ≈2.4s to the next appropriate screen: onboarding (first launch), or the last route (returning authed user → Home; returning unauthed → Login).
- **FR-1.3 (S)** Splash performs silent startup work (auth state check, config load) while displayed.

### 3.2 Onboarding Tour (Screen: Onboarding ×3)
- **FR-2.1 (M)** Show a 3-slide tour: **Plan** (AI breakdown), **Streaks** (consistency), **Squad** (social). Each slide has an illustration, title, and supporting copy.
- **FR-2.2 (M)** An animated dot indicator shows progress (1/3, 2/3, 3/3).
- **FR-2.3 (M)** A **Skip** control is present top-right on every slide; **Next** advances; the final slide's primary CTA is **Get started**.
- **FR-2.4 (M)** Both **Skip** and **Get started** route to **Sign up**.
- **FR-2.5 (S)** The tour is shown only on first launch; thereafter it is bypassed (re-viewable from settings — Could).

### 3.3 Authentication (Screens: Sign up, Login)
- **FR-3.1 (M)** Users can **sign up** with name, email, and password; the form shows live validation, a password-strength meter, a show/hide toggle, and a terms checkbox (required to proceed).
- **FR-3.2 (M)** Users can **log in** with email + password, with an inline **Forgot password?** link.
- **FR-3.3 (M)** Both screens offer **Google Sign-In** (and Apple on iOS — S) via Firebase Auth.
- **FR-3.4 (M)** Cross-links: Sign up ↔ Login ("Already on Taskko? Log in" / "Create account").
- **FR-3.5 (M)** Successful auth creates/loads the user's Firestore profile and routes to **Home**.
- **FR-3.6 (M)** Auth errors (wrong password, email in use, network) are shown inline without losing entered data.
- **FR-3.7 (M)** If the authenticated account has the **admin** flag, the app surfaces an entry point to the admin portal (see §3.11).
- **FR-3.8 (S)** "Forgot password?" triggers a Firebase password-reset email.

### 3.4 Home / Dashboard (Screen: Home)
- **FR-4.1 (M)** Header shows the Taskko wordmark, a notifications bell, and the user avatar; a time-aware greeting ("Morning, {name}") and the count of tasks left today.
- **FR-4.2 (M)** **Streak card** (peach) shows current streak in days, a 5-day streak visualizer, and "{n} shields ready".
- **FR-4.3 (M)** **Rank card** (blue) shows current rank, total points, and a progress bar to the next rank ("{x} pts to {next}").
- **FR-4.4 (M)** **Mood check-in** card lets the user pick a mood (e.g., Fired up / Focused / Chill / Drained); the selection is highlighted and stored, and adjusts session suggestions (§3.9).
- **FR-4.5 (M)** **"Next up" hero CTA** prominently shows the next task (title, minutes, points, source goal) with **Start now** (primary) and **Skip** (secondary).
- **FR-4.6 (M)** **Today's tasks** list shows each task with a completion checkbox, title, duration, source goal, and points; a header shows "{done}/{total} done · {percent}%".
- **FR-4.7 (M)** Tapping a task checkbox toggles done with immediate visual (and haptic — S) feedback, updates points/progress, and contributes to streak logic.
- **FR-4.8 (M)** A bottom tab bar navigates Home · Plan · Hub · Tako.

### 3.5 AI Plan Studio (Screen: Plan)
- **FR-5.1 (M)** A 3-step flow: **Goal** (input) → **Break down** (AI generation) → **Customize** (review/edit), with a step progress indicator.
- **FR-5.2 (M)** The user enters a goal in natural language (e.g., "Prep for CS-201 midterm by Friday"). Input is validated (non-empty, sane length) to prevent errors.
- **FR-5.3 (M)** On submit, the app calls the **backend → Gemini** to generate an ordered list of bite-sized tasks, each with an estimated duration and point value.
- **FR-5.4 (M)** A generation/loading state is shown while waiting; errors (timeout, AI failure) show a retry option and never crash the flow.
- **FR-5.5 (M)** The generated plan is **editable**: edit a task, delete a task (×), add a task ("+ Add a task"), and **Regenerate** the whole plan.
- **FR-5.6 (M)** The user can **commit** the plan, adding its tasks into Today/their task list and persisting to Firestore.
- **FR-5.7 (S)** Session planning by available time: the user can indicate available minutes and the plan is scoped to fit.

### 3.6 Gamification Hub (Screen: Hub)
- **FR-6.1 (M)** Three tabs: **Badges**, **Squad**, **Report card**.
- **FR-6.2 (M)** A "New badge!" highlight card shows the most recently unlocked badge with **Share** and **View** actions.
- **FR-6.3 (M)** **Badges** grid shows all badges (e.g., 12/24) with unlocked vs. locked states clearly distinguished.
- **FR-6.4 (M)** **Squad** tab shows a leaderboard (podium + ranked list) with the current user highlighted.
- **FR-6.5 (M)** **Report card** tab shows a weekly summary (tasks done, points, streak, etc.) rendered as a shareable card.
- **FR-6.6 (M)** **Share** opens the system share sheet to post a badge or report card to social media / messaging (one-tap social accountability).
- **FR-6.7 (S)** Squad membership: add/find friends to form a squad (basic version; full social graph is C).

### 3.7 Tako AI Chatbot (Screen: Chat)
- **FR-7.1 (M)** A conversational interface with Tako: message bubbles (user right, Tako left with mascot), a header showing Tako's status and current mode (e.g., "focused mode").
- **FR-7.2 (M)** The user can send free-text messages; replies come from the **backend → Gemini**, contextualized with the user's state (streak, points, mood, pending tasks).
- **FR-7.3 (M)** A typing indicator shows while Tako is responding.
- **FR-7.4 (M)** **Quick-prompt chips** (e.g., "I'm stuck", "Plan my evening", "Motivate me", "I want a break") let the user start common conversations in one tap.
- **FR-7.5 (M)** **Nudge cards** appear inline with action buttons (e.g., "Start a session", "Remind me in 1h") that perform the corresponding action.
- **FR-7.6 (M)** AI failures show a friendly fallback message and a retry; the chat history is preserved.
- **FR-7.7 (S)** Chat history persists across sessions (Firestore).

### 3.8 Gamification Engine (cross-cutting)
- **FR-8.1 (M)** Completing a task awards its points; the user's total updates everywhere it is shown.
- **FR-8.2 (M)** **Ranks** are derived from total points: Rookie → Pro → Elite → Legend (thresholds defined in config); rank-ups produce celebratory feedback.
- **FR-8.3 (M)** **Streaks**: completing ≥1 task on a calendar day increments the streak; a missed day breaks it unless a **streak shield** is auto-consumed.
- **FR-8.4 (M)** **Streak shields** are earned via points/milestones and consumed automatically to protect a streak.
- **FR-8.5 (M)** **Milestone badges** auto-unlock when conditions are met (e.g., 5-day streak, first win, night owl, speedrun); unlocking shows feedback and appears in the Hub.
- **FR-8.6 (M)** All gamification state is persisted to Firestore and kept consistent across screens in real time.

### 3.9 Mood & Session Adaptation (cross-cutting)
- **FR-9.1 (M)** The selected mood (§3.4) influences suggested session length and Tako's tone (e.g., "Drained" → shorter tasks, gentler nudges).
- **FR-9.2 (S)** Mood is recorded over time for the stats dashboard.

### 3.10 Productivity Tools
- **FR-10.1 (S)** **Break reminders** between/after sessions (local notifications).
- **FR-10.2 (S)** **Post-task reflection** check-in after completing a task or session.
- **FR-10.3 (S)** **Session history** and a calendar view of past activity.
- **FR-10.4 (C)** **Monthly stats dashboard** (tasks, points, streaks, mood trends).
- **FR-10.5 (S)** Push/local **notifications** for nudges, reminders, and streak warnings.

### 3.11 Admin Portal (desktop/web)
- **FR-11.1 (M)** Accessible only to users whose account has the **admin** permission; reached via an admin entry point in the app (Home header chip / profile) or a dedicated admin route.
- **FR-11.2 (M)** Layout: dark sidebar with sections — **Dashboard, Users, Moderation, AI Insights, Revenue, Settings** — and a top bar with a "Switch to student app" action.
- **FR-11.3 (M)** **Dashboard:** KPI cards (e.g., DAU, signups, active streaks, AI calls, conversions), an engagement chart, rank distribution, top goals, and a live activity feed.
- **FR-11.4 (M)** **Users:** searchable/filterable user table (All / Pro / Free / Flagged / Suspended) with a profile drawer offering suspend/reinstate and grant-bonus-points actions.
- **FR-11.5 (M)** **Moderation:** a severity-filtered queue with dismiss / warn / suspend actions.
- **FR-11.6 (S)** **AI Insights:** Gemini usage/cost stats, Tako response-quality breakdown, common "stuck" phrases, live prompt feed.
- **FR-11.7 (C)** **Revenue:** placeholder/analytics view (no real billing this build — see §11).
- **FR-11.8 (S)** **Settings:** feature-flag toggles and admin-team management.
- **FR-11.9 (M)** All admin actions are authorized server-side (Express verifies the admin claim); no admin capability is enforced only on the client.

---

## 4. External Interface Requirements

### 4.1 User Interfaces
- Native Flutter screens recreating the approved prototype (see §7 for design tokens; rendered references in `design_reference/project/frames/`).
- Phone screens are portrait, single-column, bento-card layout; the admin portal is a multi-pane desktop layout.
- A persistent bottom tab bar (Home/Plan/Hub/Tako) inside the authenticated app.

### 4.2 Hardware Interfaces
- Standard smartphone sensors only: touchscreen, optional haptics for completion feedback, system notification facilities. No custom hardware.

### 4.3 Software Interfaces
- **Firebase Authentication** — email/password + Google (+ Apple on iOS). Client SDK on device; Admin SDK on server for token verification.
- **Cloud Firestore** — primary datastore; client reads/writes guarded by Security Rules; real-time listeners for live updates.
- **Node/Express REST API** — see §6; JSON over HTTPS; Bearer Firebase ID token on every request.
- **Google Gemini API** — invoked only by the server for goal breakdown, chat, nudges, and mood-aware suggestions.

### 4.4 Communication Interfaces
- All network traffic over **HTTPS/TLS**.
- App ↔ API: RESTful JSON.
- App ↔ Firestore: Firebase real-time protocol (websockets/streams via SDK).

---

## 5. Non-Functional Requirements

- **NFR-1 Performance:** Common screen interactions respond < 100 ms. AI goal-breakdown and chat responses target < 5 s (with a visible loading state); routing AI through the server keeps device-perceived latency consistent. App cold start to splash < 2 s on a mid-range device.
- **NFR-2 Security:** Gemini key and admin privileges live server-side only. Firestore Security Rules restrict each user to their own data; admin-only data requires the admin claim. All transport is TLS. No secrets in the client bundle.
- **NFR-3 Usability (HCI):** The UI must satisfy the HCI principles in §8 (visibility, affordances, feedback, constraints, bridging the gulfs; Gestalt grouping; clear visual hierarchy). High readability on mobile.
- **NFR-4 Reliability:** AI/network failures never crash a flow; they degrade to a retry + friendly message. Already-loaded data is viewable offline; writes queue/sync via Firestore offline persistence where feasible.
- **NFR-5 Scalability:** Stateless Express API (horizontally scalable); Firestore scales managed. Leaderboard/aggregate queries designed to avoid unbounded reads.
- **NFR-6 Maintainability:** Layered Flutter architecture (UI / state / repository / service), centralized theme/design tokens, and a documented API. Code matches surrounding conventions.
- **NFR-7 Portability:** Flutter codebase targeting Android this build (iOS deferred, no code changes expected to add it later); admin portal as a React web app on Vercel.
- **NFR-8 Accessibility (S):** Adequate color contrast, scalable text, and semantic labels for screen readers.
- **NFR-9 Privacy:** Only data needed for features is collected; mood and chat data are tied to the user and protected by the rules above.

---

## 6. Backend API (Node/Express) — Specification

The API is implemented as **Node serverless functions on Vercel** (co-located with the React admin app). All endpoints require `Authorization: Bearer <Firebase ID token>`; each function verifies it via the Firebase Admin SDK and rejects unauthenticated/expired tokens. Admin endpoints additionally require the admin custom claim. CORS allows the Flutter client and admin origins. (Endpoint shapes are indicative and may be refined during design without re-approval, provided behavior is preserved.)

| Method & Path | Purpose | Notes |
|---|---|---|
| `POST /ai/breakdown` | Goal → ordered task list (title, minutes, points). | Body: `{ goal, availableMinutes? }`. Calls Gemini. (FR-5.3) |
| `POST /ai/regenerate` | Regenerate a plan from the same/edited goal. | (FR-5.5) |
| `POST /ai/chat` | Tako chat reply, given message + user context. | Body: `{ message, context }`. (FR-7.2) |
| `POST /ai/nudge` | Generate a contextual nudge/action card. | (FR-7.5) |
| `POST /ai/mood-session` | Mood-aware session suggestion. | (FR-9.1) |
| `GET /me` | Current user profile/claims bootstrap. | |
| `GET /admin/metrics` | Dashboard KPIs + aggregates. | Admin only. (FR-11.3) |
| `GET /admin/users` | List/filter/search users. | Admin only. (FR-11.4) |
| `POST /admin/users/:id/action` | Suspend / reinstate / grant points. | Admin only. (FR-11.4) |
| `GET /admin/moderation` | Moderation queue. | Admin only. (FR-11.5) |
| `POST /admin/moderation/:id/action` | Dismiss / warn / suspend. | Admin only. |
| `GET /admin/ai-insights` | Gemini usage/cost/quality. | Admin only. (FR-11.6) |
| `GET /admin/settings` · `PATCH /admin/settings` | Feature flags & admin team. | Admin only. (FR-11.8) |

Everyday task/streak/points/badge CRUD is performed **client → Firestore directly** (not via this API) under Security Rules.

---

## 7. Data Model & Design Tokens

### 7.1 Firestore collections (indicative)
```
users/{uid}            → name, email, avatar, rank, points, streak{days,shields},
                         mood, isAdmin, createdAt, lastActiveAt, plan(free|pro)
users/{uid}/tasks/{id} → title, minutes, points, goalRef, status(todo|done),
                         date, completedAt, source(ai|manual), reflection?
users/{uid}/goals/{id} → text, createdAt, status, generatedTaskIds[]
users/{uid}/badges/{id}→ key, title, unlockedAt
users/{uid}/sessions/{id} → start, end, taskIds, moodAtStart, breaksTaken
users/{uid}/chats/{id} → from(me|tako), text, kind(text|nudge), actions[], ts
squads/{squadId}       → name, memberUids[], createdAt
leaderboard (derived)  → from users.points within a squad / global
moderation/{id}        → targetUid, reason, severity, status, createdAt
config/ranks, config/badges, config/featureFlags
```
*Field names finalize during design; security rules enforce per-user ownership and admin access.*

### 7.2 Design tokens (from the approved prototype — must match)
| Token | Value |
|---|---|
| Primary (sky blue) | `#1FB6F0` (deep `#0E8FC4`, soft `#DDF3FE`) |
| Energy / streak (peach) | `#FF8A65` (soft `#FFE6DD`) |
| Success / done (mint) | `#34D399` (soft `#D6F5E6`) |
| Gold | `#F5C544` · Rose `#F472B6` · Lavender `#C7B8FF` |
| Ink (text) | `#0F0F1A` / `#2E2E3F` / `#6B6B82` / `#A8A8BC` |
| Lines / surface | line `#ECECF3`, line-2 `#DCDCE7`, surface `#FFFFFF` |
| Background | mint + lilac tinted neutral |
| UI font | **Manrope** (400–800) |
| Display font | **Fraunces** (titles/headlines) |
| Numeric/stats font | **JetBrains Mono** |
| Corner radii | cards ~20–28px (bento style) |
| Reference frame | 402 × 874 logical px (phone) |
| Mascot | "Tako" — abstract gradient spark, multiple mood states |

---

## 8. HCI / UX Design Principles (required)
The design (rooted in the original HCI brief) must demonstrably apply:
- **Norman — Visibility & Affordances:** primary actions look clickable (filled "Start now"); interactive elements are obvious.
- **Norman — Mapping:** controls relate logically to effects (mood picker → session; checkbox → done).
- **Norman — Feedback:** immediate visual (and haptic) response on task completion, points earned, badge unlocks, rank-ups.
- **Norman — Constraints:** prevent input errors (goal/auth validation, disabled CTAs until valid).
- **Bridging the Gulf of Execution:** the "Next up" hero makes starting the next task effortless.
- **Bridging the Gulf of Evaluation:** streak/points/rank/progress are instantly readable without cognitive overload.
- **Gestalt:** proximity/similarity/closure group related tasks, stats, and chat messages (bento cards).
- **Visual hierarchy & balance:** the eye is directed to the next action; gamification is rewarding but doesn't overwhelm the core productivity focus.
- **Color & typography:** a motivating-yet-low-fatigue palette and highly readable mobile type (§7).

---

## 9. Assumptions, Risks & Mitigations
| Risk | Mitigation |
|---|---|
| Gemini latency/cost or downtime | Server-side calls, timeouts, loading states, retry, friendly fallbacks (NFR-4). |
| Firestore rules misconfiguration leaking data | Rules reviewed/tested; admin gated by server claim (NFR-2). |
| Scope creep (8 screens + admin + AI + backend) | Priorities (M/S/C); ship M first, then S, then C. |
| Platform scope | Android only this build; iOS deferred (avoids a Mac/Xcode dependency). |
| Vercel serverless execution-time limit on long AI responses | Keep prompts/outputs bounded; use streaming/Edge functions for long chat if needed; cold starts are negligible vs. Gemini latency. |
| Offline use | Firestore offline persistence; cached reads; queued writes. |

---

## 10. Acceptance Criteria (high level)
The build is accepted when, for the **Must (M)** requirements:
1. A new user can complete splash → onboarding → sign up (incl. Google) → land on Home.
2. Home shows live streak, rank, points, mood, "Next up", and today's tasks; completing a task updates points/progress with feedback.
3. AI Plan Studio turns a typed goal into an editable AI-generated plan (via backend/Gemini) and commits it to Today.
4. The Hub shows badges (locked/unlocked), squad leaderboard with the user highlighted, and a shareable weekly report card; Share opens the system sheet.
5. Tako chat returns contextual Gemini replies with typing indicator, quick prompts, and actionable nudges; failures degrade gracefully.
6. Gamification engine correctly awards points, advances ranks, maintains streaks/shields, and unlocks badges, persisted in Firestore.
7. An admin user reaches the admin portal and can view the dashboard and manage users/moderation; admin actions are authorized server-side.
8. The UI matches the approved design tokens (§7) and satisfies the HCI checklist (§8).
9. All secrets are server-side; no Gemini key or admin enforcement in the client; all traffic is HTTPS.

---

## 11. Out of Scope / Future Work
- **Monetization:** Free vs Pro tier billing, **Lemon Squeezy** integration, paid feature-gating (e.g., 3 AI breakdowns/day for Free), and "exclusive" Pro badges/report cards. The data model leaves a `plan` field placeholder so this can be added later without migration.
- **iOS build** — deferred; the single Flutter codebase is expected to target it later with minimal changes.
- **B2B / university licensing** and **in-app badge packs**.
- Full social graph (friend requests, squad creation/management at scale) beyond a basic leaderboard.
- Advanced analytics and the admin **Revenue** section's real figures.

---

## 12. Change Log
| Version | Date | Author | Notes |
|---|---|---|---|
| 1.0 | 2026-06-04 | Team Taskko | Initial draft for stakeholder approval. |
| 1.1 | 2026-06-04 | Team Taskko | Admin portal = React on Vercel; backend = Node serverless functions on Vercel (same project). Three-tier model clarified. |
| 1.2 | 2026-06-04 | Team Taskko | State mgmt = flutter_bloc (Cubit-first); Vercel stack = Next.js; Android-only (iOS deferred); mock-first dev against repo abstraction; deliverables = APK + live admin/Firebase + seeded demo data & accounts. |
| 1.3 | 2026-06-06 | Team Taskko | AI engine = **Gemini via Vertex AI** (GCP, service-account auth, no API key, billed to GCP credits) instead of the AI Studio key. NDK pinned to r27d (27.3.13750724). Setup steps in `docs/SETUP.md`. |

---

### Approval
- [ ] **Stakeholder approval** — once you approve (or request edits), this becomes the development baseline and we proceed to implementation (theming, navigation/state scaffolding, then screen-by-screen build starting with the Must requirements).
