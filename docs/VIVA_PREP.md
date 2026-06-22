# Taskko — Complete Viva Preparation Guide

> **Project:** Taskko — *Your AI Productivity Companion* (Mobile Application Development project)
> **Institution:** Riphah International University, Lahore
> **Team:** Umar Ahad Uddin Ahmed Usmani (SAP 60199) · Muhammad Sharjeel (SAP 59385)
> **Stack:** Flutter (Android) · Firebase (Auth + Firestore) · Next.js serverless API on Vercel · Google Gemini (via LangChain)

This is an exhaustive study guide: what the app is, every technology and *why* it was chosen, the architecture, a file-by-file responsibility map, the backend, the data model, end-to-end feature flows, and a bank of likely viva questions with answers.

---

## 1. Elevator pitch (say this when asked "tell me about your project")

> "Taskko is an AI-powered student productivity app. A student types a big goal in plain English — say *'prepare for my CS-201 midterm by Friday'* — and our AI (Google Gemini) breaks it into small, time-boxed tasks. To keep students motivated we gamified it: points, ranks (Rookie → Legend), daily streaks with streak-shields, and milestone badges. There's an AI study-buddy chatbot called **Tako**, a focus timer, a mood check-in that adapts the session, and a weekly shareable report card. It's a **Flutter** Android app using **Firebase** for auth and the database, a **Next.js serverless backend on Vercel** that safely calls **Gemini** (so the API key never ships in the app), and a separate **React admin web console** for managing users, moderation, AI usage and feature flags."

**The problem it solves (from the SRS):** the student productivity crisis — overwhelming goals, no accountability, no motivation loop, and burnout. Taskko attacks all four: AI breaks goals down, gamification provides the motivation loop, social sharing adds accountability, and mood-adaptation fights burnout.

---

## 2. Technology stack — *what* and *why*

### Mobile app (Flutter / Dart)
| Technology | Why we chose it |
|---|---|
| **Flutter + Dart** | Single codebase, native performance, rich UI control to match our custom design. Targets Android this build (iOS deferred — same code runs later). |
| **flutter_bloc (Cubit)** | Predictable, testable state management with explicit loading/success/error states for async auth and AI calls. We use **Cubit** (simpler than full BLoC) because most flows are method-call driven, not event-stream driven. |
| **equatable** | Value-equality for state objects so `BlocBuilder` only rebuilds when state truly changes (performance + correctness). |
| **go_router** | Declarative, URL-style navigation with typed arguments — one central route table. |
| **google_fonts** | Loads our three brand fonts (Fraunces, Manrope, JetBrains Mono) at runtime without bundling font files. |
| **firebase_core / firebase_auth** | Account system: email/password + Google sign-in, password reset, email verification, session persistence. |
| **cloud_firestore** | Real-time NoSQL database for all everyday data (tasks, points, streaks, chat history, sessions). Offline persistence built in. |
| **google_sign_in** | Native Google account picker → exchanged for a Firebase credential. |
| **firebase_analytics** | Usage analytics (logs app-open and feeds the admin dashboard). |
| **firebase_crashlytics** | Automatic crash + error reporting (wired before `runApp`). |
| **http** | REST calls to our Vercel backend (AI + admin endpoints). |
| **image_picker** | "Scan a photo" — take/choose a photo of a syllabus and turn it into tasks (multimodal AI). |
| **flutter_local_notifications + timezone + flutter_timezone** | Local notifications for break reminders, daily plan reminders, streak-saver — scheduled at the correct local wall-clock time. |
| **audioplayers** | Plays calming/energising music during the post-focus break. |
| **share_plus** | Opens the OS share sheet to post badges / weekly report cards to social apps. |
| **flutter_local_notifications** | (see above) |

**Dev/build tooling:** `flutter_test`, `bloc_test`, `mocktail` (testing), `flutter_lints` (lint rules), `flutter_launcher_icons` (generates the Taskko launcher icon).

### Backend (Next.js on Vercel)
| Technology | Why |
|---|---|
| **Next.js (Pages Router) on Vercel** | One project hosts *both* the serverless API (`/api/*`) **and** the React admin web app. Serverless = no servers to manage, scales automatically. |
| **firebase-admin** | Server-side SDK to **verify Firebase ID tokens** and enforce the **admin custom claim**, and to read/write Firestore with elevated rights. |
| **@langchain/google-genai + @langchain/core** | LangChain wrapper around Google's Gemini API — clean message/prompt abstraction, easy model swapping and fallback. |
| **firebase (web SDK)** | Browser-side auth for the admin console (Google / email sign-in). |
| **react / react-dom** | The admin console UI. |
| **TypeScript** | Type-safe API contracts and components. |

### Cloud services
- **Firebase Authentication** — identities + ID tokens.
- **Cloud Firestore** — primary datastore (client reads/writes directly under Security Rules; server reads/writes via Admin SDK).
- **Google Gemini** — the AI engine (goal breakdown, chat, quiz, nudges, mood sessions, day planning), **only ever called from the server**.

---

## 3. System architecture (3-tier "client → API → cloud")

```
 ┌──────────────────────────┐        ┌───────────────────────────┐
 │  Flutter App (Android)    │        │  React Admin Web (Vercel)  │
 │  ~13 screens + state       │        │  dashboard / users / …     │
 └───────────┬──────────────┘        └─────────────┬─────────────┘
             │ Firebase SDK (Auth + Firestore, realtime)            │ fetch + Firebase ID token
             │                                                      │
             │            ┌─────────────────────────────────────────┘
             │            │  HTTPS, Authorization: Bearer <ID token>
     ┌───────▼────────────▼────────────────────────────────────────┐
     │  VERCEL — Next.js serverless functions (/api/*)              │
     │  • AI proxy → Gemini (key stays server-side)                │
     │  • admin/privileged ops · verifies tokens + admin claim     │
     │  • also serves the React admin app                          │
     └────────┬──────────────────────────────────┬────────────────┘
              │ GEMINI_API_KEY (server only)       │ Admin SDK (verify token, read/write)
        ┌─────▼──────┐                  ┌──────────▼───────────────┐
        │ Gemini API │                  │ Firebase: Auth + Firestore│
        └────────────┘                  └───────────────────────────┘
   The Flutter app ALSO reads/writes Firestore directly (under Security Rules)
   for everyday CRUD; it calls the Vercel API only for AI + admin work.
```

**Division of responsibility (important — examiners love this):**
- **Flutter ↔ Firestore directly** for everyday CRUD/real-time: tasks, completion, points, streaks, badges, chat history, sessions. Guarded by **Firestore Security Rules**.
- **Flutter / Admin ↔ Vercel API** for anything that must not run on the client: **all Gemini calls** (key secrecy + centralised prompts) and **admin/privileged operations**.
- **Why split it?** The Gemini API key must never ship inside the APK (anyone could extract it). Admin power must be enforced on the server, not trusted from the client.

---

## 4. The architecture patterns (headline talking points)

These four patterns are the backbone of the codebase and your strongest viva material.

### 4.1 Layered architecture
`UI (Widgets) → State (Cubits) → Repository (interfaces) → Data source (Firebase / HTTP / mock)`. Each layer only knows the layer directly below it through an abstraction.

### 4.2 BLoC / Cubit state management
- Every feature has a **Cubit** that holds an immutable **state** object (extends `Equatable`, has `copyWith`).
- A shared `enum ViewStatus { initial, loading, success, failure }` (in `lib/common/view_status.dart`) gives every async screen explicit loading/error UX.
- Widgets render with `BlocBuilder` (rebuild on state) and react to one-off events with `BlocListener`/`BlocConsumer` (navigation, snackbars).
- **Optimistic updates:** completing a task or sending a chat message updates the UI *before* the backend confirms, then reconciles — feels instant.

### 4.3 Repository pattern (the star of the show)
- Every data concern is an **`abstract interface class`** (e.g. `AuthRepository`, `TasksRepository`).
- Each interface has up to **three implementations**:
  1. **mock/** — in-memory, seeded, simulated latency (offline demos + unit/widget tests).
  2. **firebase/** — talks straight to Firestore/Firebase Auth.
  3. **backend/** — calls the Vercel HTTP API (for AI + admin, which need server secrets).
- The UI and Cubits depend **only on the interface**, never on Firebase or HTTP directly.

| Interface | mock | firebase | backend-HTTP |
|---|:--:|:--:|:--:|
| AuthRepository | ✓ | ✓ | — |
| TasksRepository | ✓ | ✓ | — |
| GamificationRepository | ✓ | ✓ | — |
| ChatHistoryRepository | ✓ | ✓ | — |
| SettingsRepository | ✓ | ✓ | — |
| SessionRepository | ✓ | ✓ | — |
| PlanRepository | ✓ | — | ✓ |
| ChatRepository | ✓ | — | ✓ |
| AiToolsRepository | ✓ | — | ✓ |
| AdminRepository | ✓ | — | ✓ |

**Why this design (memorise these benefits):** **Testability** (inject mocks, no network), **swap-ability** (change the backing store with no UI change → open/closed principle), **separation of concerns** (UI knows nothing about Firestore paths or HTTP), and **mock-first development** (screens ran before Firebase/Gemini existed).

### 4.4 Dependency Injection + compile-time flags
- `lib/app/app.dart` wires everything with **`MultiRepositoryProvider`** (repositories) and **`MultiBlocProvider`** (app-level cubits) from `flutter_bloc`. Cubits get their repositories via constructor injection (`ctx.read<AuthRepository>()`).
- **Three `--dart-define` flags** pick implementations at build time:
  - `USE_FIREBASE` (default `true`) → Firebase impls vs mocks.
  - `USE_BACKEND` (default `true`) → HTTP (real Gemini) vs mocks.
  - `BACKEND_URL` (default the Vercel URL) → server base URL.
- So `flutter build apk` gives the real app; `--dart-define=USE_FIREBASE=false --dart-define=USE_BACKEND=false` gives a fully working offline demo from seed data.

---

## 5. App startup sequence (`lib/main.dart`)

Order matters — everything observability-related is set up **before** `runApp`:
1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
3. **Offline-first Firestore:** `persistenceEnabled: true`, unlimited cache → app works without a connection.
4. **Crashlytics:** `FlutterError.onError` + `PlatformDispatcher.onError` route all crashes to Crashlytics.
5. **Analytics:** `logAppOpen()`.
6. `NotificationService.instance.init()` (channels + timezone).
7. `runApp(const TaskkoApp())`.

---

## 6. File-by-file responsibility map (Flutter app, `lib/`)

### 6.1 App shell & config
| File | Responsibility |
|---|---|
| `main.dart` | Entry point; Firebase init, Crashlytics/Analytics, offline cache, notifications, then `runApp`. |
| `firebase_options.dart` | FlutterFire-generated Firebase config (Android only; other platforms throw `UnsupportedError`). |
| `app/app.dart` | Root widget `TaskkoApp`; DI wiring of all repositories + app cubits; `MaterialApp.router`; the `useFirebase`/`useBackend` flags. |
| `app/router.dart` | Central `GoRouter` route table; typed args via `state.extra`; `initialLocation: '/splash'`. |
| `config/backend_config.dart` | `BackendConfig.baseUrl` from `BACKEND_URL` dart-define (default Vercel URL). |
| `common/validators.dart` | Email/name/password validators + password-strength heuristic. |
| `common/view_status.dart` | `ViewStatus { initial, loading, success, failure }` + helpers. |

**Route table:** `/splash`, `/onboarding`, `/signup`, `/login`, `/verify-email`, `/home`, `/plan`, `/hub`, `/chat`, `/admin`, `/profile`, `/profile/edit`, `/settings`, `/history`, `/quiz`, `/terms`, `/privacy`, `/planday`, `/focus`.

### 6.2 Theme / design system (`lib/theme/`)
| File | Responsibility |
|---|---|
| `app_colors.dart` | All colour tokens (sky-blue primary, peach energy, mint success, ink text scale, gradients). "No hard-coded hex anywhere else." |
| `app_radii.dart` | `AppSpacing` (4→32 + gutter) and `AppRadii` (card 24, pill 999, etc.). |
| `app_typography.dart` | Three-font system via google_fonts — **Fraunces** (display), **Manrope** (UI/body), **JetBrains Mono** (numbers/timers). |
| `app_theme.dart` | Builds the single Material-3 light `ThemeData`; Cupertino page transitions on both platforms; branded snackbar + input styles. |

### 6.3 Shared widgets (`lib/widgets/`)
`bento_card.dart` (the rounded card surface), `primary_button.dart` (gradient CTA with loading state), `secondary_button.dart`, `section_header.dart`, `stat_pill.dart` (mono stat chip), `tab_scaffold.dart` (the 4-tab bottom nav: Home/Plan/Hub/Tako), `tako_mascot.dart` (the mascot — pure vector shapes, mood-reactive), `taskko_logo.dart` (the brand mark — drawn, no image).

### 6.4 Services (`lib/services/`) — cross-cutting, all singletons / static
| File | Responsibility |
|---|---|
| `notification_service.dart` | Local notifications: immediate (focus done) + scheduled daily reminders; timezone-aware; two Android channels; every call try/caught so non-Android no-ops. |
| `music_service.dart` | Plays mood-based looping break music (audioplayers). |
| `joke_service.dart` | Fetches a joke for the break (http) with a built-in offline fallback. |
| `data_export_service.dart` | GDPR data export — gathers profile + tasks + sessions + chats into a JSON file and shares it. |

### 6.5 Models (`lib/models/`) — immutable value objects (Equatable + copyWith)
| Model | Represents |
|---|---|
| `app_user.dart` | The signed-in user: name, email, points, streakDays, shields, mood, isAdmin, emailVerified; derived `rank`, `pointsToNext`, `initials`. |
| `mood.dart` | Mood enum: firedUp / focused / chill / drained (each with label, emoji, colour). |
| `rank.dart` | Rank ladder: rookie(0) → pro(1000) → elite(1560) → legend(3000); `forPoints()`, `next`. |
| `task_item.dart` | A real task (title, minutes, points, goal, done). |
| `plan_task.dart` | An AI-proposed task before commit (no goal/done yet). |
| `day_block.dart` | A time block in a planned day (start, end, taskTitle, isBreak). |
| `quiz_question.dart` | A generated MCQ (question, options, answerIndex). |
| `clarify_question.dart` | A clarifying question Tako asks (question, options). |
| `chat_message.dart` | A chat message (from me/tako, text, kind text/nudge, actions). |
| `chat_session.dart` | A saved conversation (id, title, preview, updatedAt). |
| `focus_session.dart` | A completed focus session (taskTitle, minutes, mood, startedAt, rating). |
| `reminder_prefs.dart` | Reminder settings (planDaily, planHour/Minute, streakSaver) + toMap/fromMap. |
| `badge_item.dart` | A milestone badge (key, title, emoji, unlocked). |
| `leaderboard_entry.dart` | One leaderboard row (position, name, points, isYou). |
| `weekly_report.dart` | Weekly summary (tasksDone, points, focusMinutes, streakDays, topGoal) + shareText. |
| `admin_user.dart` | Admin-console user row (id, name, email, plan, rank, points, status) + fromJson. |
| `admin_metrics.dart` | Dashboard KPIs + RankCount/TopGoal/ActivityItem. |
| `admin_settings.dart` | Feature flags + admin team. |
| `ai_insights.dart` | Gemini usage/quality/prompt stats. |
| `moderation_item.dart` | A moderation-queue report (targetUser, reason, severity, status). |

### 6.6 Repositories (`lib/repositories/`)
**Interfaces** (top level): `auth_repository.dart`, `tasks_repository.dart`, `gamification_repository.dart`, `chat_history_repository.dart`, `settings_repository.dart`, `session_repository.dart`, `plan_repository.dart`, `chat_repository.dart`, `ai_tools_repository.dart`, `admin_repository.dart`.

**firebase/** (direct Firestore/Auth): `auth_repository_firebase.dart`, `tasks_repository_firestore.dart`, `gamification_repository_firestore.dart`, `chat_history_repository_firestore.dart`, `settings_repository_firestore.dart`, `session_repository_firestore.dart`.

**mock/** (in-memory + `seed.dart`): one per interface, seeded from `seed.dart` (demo student "Sara", admin, tasks, badges, leaderboard, chat).

**backend/** (HTTP clients): `ai_api_client.dart` + `admin_api_client.dart` (attach the Firebase ID token as `Bearer`), `plan_repository_http.dart`, `chat_repository_http.dart`, `ai_tools_repository_http.dart`, `admin_repository_http.dart`.

### 6.7 Cubits & feature screens
| Feature | Files | What it does |
|---|---|---|
| **Splash** | `features/splash/...` | Brand intro with explicit sine-wave animation; restores session then routes (authed→home/admin, unverified→verify, else onboarding). |
| **Onboarding** | `cubits/onboarding/...`, `features/onboarding/...` | 3-slide tour (Plan/Streaks/Squad); `OnboardingCubit` is a `Cubit<int>` (slide index). |
| **Auth** | `cubits/auth/...`, `features/auth/...` | `AuthCubit` + login/signup/verify-email screens + widgets (divider, labeled field, password-strength bar, social button). |
| **Home** | `features/home/...` | Dashboard: greeting, streak/rank cards, mood picker, "Next up" CTA, today's tasks; `HomeCubit` (tasks + gamification, optimistic toggles). |
| **Plan** | `features/plan/...` | AI Plan Studio (the core flow): goal → clarify → generate → review → commit; `PlanCubit` + `PlanStep` enum + animated step indicator. |
| **Plan My Day** | `features/planday/...` | Gemini time-blocks today's tasks (FutureBuilder, not a Cubit). |
| **Chat (Tako)** | `features/chat/...` | AI chat with persisted history; `ChatCubit` + history sheet (new/open/delete sessions). |
| **Focus** | `features/focus/...` | Countdown timer (Timer + setState), then notification + music + joke + rating; records a `FocusSession`; returns "done?" to Home. |
| **Hub** | `features/hub/...` | Gamification hub: badges grid, squad leaderboard, weekly report card (rasterised to an image for sharing). |
| **Quiz** | `features/quiz/...` | AI quiz: topic → generate → take → score; `QuizCubit` + `QuizStep` enum. |
| **History** | `features/history/...` | Focus history + 7-day bar chart (hand-drawn) + recent sessions. |
| **Profile** | `features/profile/...` | Profile (FutureBuilder) + Edit Profile (name/mood CRUD + change email/password + delete account). |
| **Settings** | `features/settings/...` | Reminder prefs; `SettingsCubit` schedules/cancels OS notifications on every change. |
| **Legal** | `features/legal/...` | One screen renders Terms (`/terms`) and Privacy (`/privacy`). |
| **Admin** | `features/admin/...` | In-app admin console: Dashboard, Users (+CRUD), Moderation, AI insights, Settings (`AdminCubit`). |
| **Gamification (app-level)** | `cubits/gamification/...` | Loads profile + badges for the whole app. |

---

## 7. Firestore data model (exact paths)

| Path | Contents |
|---|---|
| `users/{uid}` | Profile + gamification: name, email, points, streakDays, shields, mood, isAdmin, createdAt, lastActiveDate. |
| `public_profiles/{uid}` | Public mirror (name, points, rank) for the leaderboard. |
| `users/{uid}/tasks/{taskId}` | Tasks: title, minutes, points, goal, status, date (YYYY-MM-DD), completedAt. |
| `users/{uid}/sessions/{id}` | Focus sessions: taskTitle, minutes, mood, rating, startedAt. |
| `users/{uid}/settings/reminders` | Reminder prefs (single doc). |
| `users/{uid}/chatSessions/{id}` | Chat session meta: title, preview, updatedAt. |
| `users/{uid}/chatSessions/{id}/messages/{msgId}` | Messages subcollection: from, text, ts. |
| `config/featureFlags` | Admin feature-flag toggles. |
| `moderation/{id}` | Moderation reports (server-side). |
| `aiLogs/{id}` | Every Gemini call: feature, fallback, latencyMs, ts (feeds admin AI insights/metrics). |

**Firestore techniques worth naming:** atomic **transaction** for points+streak (`recordTaskCompletion`), **batch** writes (`addTasks`), `FieldValue.serverTimestamp()` for ordering, `SetOptions(merge: true)`, lazy doc creation, and the `public_profiles` mirror so leaderboards don't expose private user docs.

---

## 8. Backend (`admin/` — Next.js on Vercel)

### 8.1 Security core
- **`lib/auth.ts`** — `withAuth(handler)` verifies the `Authorization: Bearer <Firebase ID token>` using **firebase-admin** (`verifyIdToken`); missing/expired/invalid → 401. `withAdmin(handler)` additionally requires the **`admin` custom claim**, else **403**. Admin power is enforced **server-side only**; the client UI gate is cosmetic.
- **`lib/firebaseAdmin.ts`** — initialises the Admin SDK once per warm instance from a `FIREBASE_SERVICE_ACCOUNT` env var (raw JSON or base64).
- **`lib/http.ts`** — standard error envelope **`{ error, retryable }`**; `retryable` tells the client whether to show a Retry button.
- **`lib/cors.ts`** — CORS allow-list; native Flutter (no Origin) is always allowed, browsers must match `ALLOWED_ORIGINS`.

### 8.2 Gemini integration (`lib/gemini.ts`) — the AI brain
- Uses **`ChatGoogleGenerativeAI`** from `@langchain/google-genai` with `GEMINI_API_KEY` (server-only).
- **Model tiers:** "Pro" (structured work: breakdown, clarify, quiz, regenerate) and "Flash" (conversational: chat, nudge, mood-session, plan-day), each with a frontier model + a stable fallback model.
- **Shared persona** `TAKO_PERSONA` system prompt + a `contextBlock()` that injects the user's real stats; each feature has a `build*Prompt()` ending with an exact JSON shape.
- **Two-layer fallback (never hard-fail — NFR-4):** (1) if the frontier model errors, retry once on the fallback model; (2) if both fail, return a **hand-written deterministic fallback** (e.g. a generic 3-step plan referencing the real goal). Structured features with no sensible default return `[]`.
- **Parsing:** strips ```` ```json ```` fences, `JSON.parse`, then **clamps every field** (minutes 5–90, points 5–50, answerIndex in range) and skips invalid items.
- **`loadUserContext(uid)`** reads the user's profile + pending tasks so chat is grounded in real data.
- **`logUsage()`** fire-and-forget writes to **`aiLogs`** → powers the admin AI-insights page.

### 8.3 API endpoints
**AI routes** (`pages/api/ai/*`, all `withAuth` + POST, `maxDuration: 60`):
| Endpoint | Sends → / Returns ← | SRS |
|---|---|---|
| `/api/ai/breakdown` | `{goal, availableMinutes?}` → `{tasks[], fallback}` | FR-5.3 |
| `/api/ai/clarify` | `{goal}` → `{questions[]}` | FR-5.2 |
| `/api/ai/regenerate` | `{goal, avoid?[]}` → `{tasks[]}` | FR-5.5 |
| `/api/ai/chat` | `{message, context?}` → `{reply, fallback}` (merges server-loaded user context) | FR-7.2 |
| `/api/ai/nudge` | `{context?}` → `{nudge{text,actions[]}}` | FR-7.5 |
| `/api/ai/mood-session` | `{mood, context?}` → `{session{...}}` | FR-9.1 |
| `/api/ai/plan-day` | `{tasks[], availableMinutes, mood}` → `{blocks[]}` | M13 |
| `/api/ai/quiz` | `{topic, count?, difficulty?}` → `{questions[]}` | M13 |

**Admin routes** (`pages/api/admin/*`, all `withAdmin`):
- `/api/admin/metrics` (GET) — KPIs from Auth + Firestore + aiLogs counts.
- `/api/admin/users` (GET/POST) — list/filter/search + full **CRUD** (create/update/delete) + suspend/reinstate/grant_points.
- `/api/admin/moderation` (GET/POST) — queue + dismiss/warn/suspend.
- `/api/admin/settings` (GET/PATCH) — feature flags (`config/featureFlags`) + admin team.
- `/api/admin/ai-insights` (GET) — usage/quality/latency/fallback from `aiLogs`.
- `/api/me` (GET) — returns the caller's identity + `admin` flag (how the Flutter app discovers it's an admin).

### 8.4 React admin console
`pages/index.tsx` → `LoginGate` (Firebase web auth → checks admin claim) → `AdminLayout` (sidebar + sections). Six sections: **Dashboard, Users, Moderation, AI Insights, Revenue (static — no billing this build), Settings**. Each uses a `useApi()` hook + an `apiClient` that attaches the Firebase ID token; every request is re-verified by `withAdmin` on the server.

---

## 9. End-to-end feature flows (be ready to whiteboard these)

### A. Authentication + email verification
- **Email/password signup** → Firebase `createUserWithEmailAndPassword`, set display name, send verification email. New user is `emailVerified == false` → `AuthCubit._resolve` emits **`AuthStatus.unverified`** → router sends to `/verify-email`.
- **Verify screen** polls `refreshVerification()` (reloads the Firebase user). Once verified → routes to `/home`. "Resend email" and "use a different account" available.
- **Google sign-in** → native picker → Firebase credential. Google identities are `emailVerified == true`, so they resolve straight to **`authenticated`** and **skip the verification gate**.
- **Forgot password** → validates email → `sendPasswordResetEmail`.
- **AuthStatus enum:** `unknown · authenticating · authenticated · unverified · unauthenticated · failure`.
- **Session persistence:** `AuthCubit` subscribes to `authStateChanges()` so you stay logged in across restarts; the splash restores the session.

### B. AI Plan Studio (the core flow)
`PlanStep.input` (type goal) → **`generate()`** calls `clarify()`:
- questions returned → `PlanStep.clarify` (answer chips **or** the "Other…" free-text option) → **`submitClarify()`** (enriches goal with answers) or **`skipClarify()`**;
- none/clarify-fails → straight to breakdown.

→ **`_runBreakdown()`** calls `/api/ai/breakdown` → `PlanStep.review` (edit/add/delete tasks, **`regenerate()`** to re-roll) → **`commit()`** maps each `PlanTask` → `TaskItem` and writes to Firestore → success snackbar → Home. Photo path: **`generateFromImage()`** jumps input → generating → review. The animated 3-bar header pulses while generating and fills when each stage settles.

### C. Tako chat
`load()` reopens the latest session (or a fresh greeting). **`send(text)`** appends the user message + typing indicator (optimistic), persists it, calls `/api/ai/chat` (with the user's real context), appends Tako's reply, persists it; on failure shows a friendly fallback. History sheet lists sessions and lets you start/open/delete conversations (Firestore `chatSessions` + `messages` subcollection).

### D. Gamification engine
Completing a task runs a Firestore **transaction**: add the task's points (subtract on un-complete, floored at 0); increment the **streak** once per calendar day (`lastActiveDate == yesterday` → +1, else reset to 1). **Rank** derives from points (Rookie→Legend). **Badges** are derived from real stats (first win, 5-day streak, Pro/Elite/Legend thresholds). A `public_profiles` mirror feeds the leaderboard.

### E. Focus timer
Pick minutes → 1-second `Timer.periodic` countdown (pause/resume) → at zero: system notification + mood music + a joke + an optional 1–3 reflection rating → records a `FocusSession` and returns "done?" to Home, which completes the task and awards points if true.

### F. Admin user CRUD
The admin console (web **and** in-app) calls `/api/admin/users` with an `action` discriminator: `create` (Auth `createUser` + profile doc), `update` (Auth + profile patch), `delete` (Auth + profile), plus `suspend`/`reinstate`/`grant_points`. All gated by `withAdmin` (server-verified `admin` claim).

---

## 10. Security model (be confident here)
1. **Secrets never on the client** — the Gemini key lives only in the Vercel server env; the app calls our API, never Gemini directly.
2. **Token-based auth** — every API request carries the Firebase **ID token**; the server verifies it with firebase-admin.
3. **Admin = server-verified custom claim** — `withAdmin` returns 403 without it; the client UI gate is cosmetic only (defence in depth).
4. **Firestore Security Rules** independently restrict each user to their own `users/{uid}` data and gate admin-only data — so direct client access is safe too.
5. **HTTPS/TLS** everywhere; standard `{error, retryable}` envelope; `withErrorEnvelope` ensures a thrown error never crashes a function.

---

## 11. SRS requirement → code map (quick reference)
- **FR-1 Splash** → `features/splash`. **FR-2 Onboarding** → `features/onboarding`.
- **FR-3 Auth** → `cubits/auth`, `features/auth` (+ Google, verification, forgot-password).
- **FR-4 Home dashboard** → `features/home`. **FR-5 Plan Studio** → `features/plan` + `/api/ai/breakdown|clarify|regenerate`.
- **FR-6 Hub (badges/squad/report)** → `features/hub`. **FR-7 Tako chat** → `features/chat` + `/api/ai/chat`.
- **FR-8 Gamification engine** → `gamification_repository_firestore` (points/streak/rank/badges).
- **FR-9 Mood/session adaptation** → mood picker + `/api/ai/mood-session`.
- **FR-10 Productivity tools** → `features/focus`, `features/history`, `features/settings` + `NotificationService`.
- **FR-11 Admin portal** → `admin/` web + `features/admin` in-app + `/api/admin/*`.
- **NFR-2 Security** → §10 above. **NFR-4 Reliability** → two-layer AI fallback + offline Firestore.

---

## 12. HCI / UX principles applied (the SRS requires this — likely asked)
- **Visibility & affordance** — the gradient "Start now" / "Break it down" buttons clearly look tappable.
- **Mapping** — mood picker → session; checkbox → done.
- **Feedback** — instant visual response on task completion, points, badge unlocks, rank-ups; animated step indicator and typing dots.
- **Constraints** — disabled CTAs until input is valid (goal length, terms checkbox), inline validation prevents errors.
- **Gulf of execution** — the "Next up" hero makes starting the next task one tap.
- **Gulf of evaluation** — streak/points/rank are instantly readable.
- **Gestalt** — bento cards group related info (proximity/similarity).

---

## 13. Likely viva questions & model answers

**Q: Why Flutter and not native Android?**
One codebase, fast development, pixel-perfect custom UI, and the same code can target iOS later with minimal change.

**Q: Why Cubit instead of full BLoC?**
Cubit is simpler — you call methods that emit states. Most of our flows are request/response (login, breakdown, send message), which don't benefit from event streams. We still get explicit loading/success/error states and testability.

**Q: What is the repository pattern and why use it?**
An abstraction layer between the app and data sources. Each data concern is an interface with mock/Firebase/HTTP implementations. It gives testability (mock injection), swap-ability (change backend with no UI change), and clean separation. We even built and demoed the whole app on mocks before Firebase/Gemini were ready.

**Q: How do you keep the Gemini API key safe?**
It only exists in the Vercel server environment. The app calls *our* endpoints; the server calls Gemini. The key is never in the APK.

**Q: How does admin authorization work?**
The user gets an `admin` **custom claim** on their Firebase account. Every admin API is wrapped in `withAdmin`, which verifies the ID token and checks that claim server-side — returns 403 otherwise. The client only *shows/hides* admin UI; it never decides access. Firestore Rules enforce the same claim for direct database access.

**Q: How does the AI breakdown actually work end-to-end?**
The app POSTs the goal (with the Firebase token) to `/api/ai/breakdown`. The server builds a prompt with Tako's persona + the user's context, calls Gemini through LangChain, parses and clamps the JSON into tasks, and returns them. If Gemini fails, it falls back to a second model, and if that fails, a hand-written plan — so the flow never crashes. The app then lets the user edit and commit the tasks to Firestore.

**Q: What happens offline?**
Firestore offline persistence serves already-loaded data and queues writes. AI features show a friendly retry. The whole app can also run on mock data (no network) for demos.

**Q: How is the email verification compulsory for email/password but not Google?**
After signup the user is `emailVerified == false`, so `AuthCubit._resolve` returns `unverified` and routes to the verify screen until they confirm. Google accounts come back `emailVerified == true`, so they're authenticated immediately and skip the gate.

**Q: Why a separate Next.js backend if you also use Firestore directly?**
Two reasons: (1) AI calls must hide the Gemini key and centralise prompts — that has to be server-side; (2) admin/privileged operations must be authorised on the server. Everyday CRUD goes straight to Firestore (under Rules) for real-time speed.

**Q: How do you test it?**
Cubit/unit tests with `bloc_test` + `mocktail`, and widget tests that inject mock repositories (no Firebase/network). The mock-first architecture makes this trivial.

**Q: What state does each layer hold?**
UI is stateless-ish (rebuilds from Cubit state); Cubits hold immutable `Equatable` state with `ViewStatus`; repositories are stateless data access; Firestore/the backend hold persistent state.

---

## 14. Honest caveats (good to know if pressed)
- The release **APK is debug-signed** (no production keystore configured) — fine for sideloading/demo, not for Play Store.
- The newest admin **user-CRUD** + Moderation/AI-insights/Settings tabs call the Vercel backend; they only work after the backend is **redeployed** with those routes.
- A multimodal `/api/ai/extract-tasks` route is referenced/implemented in `gemini.ts` but the route file isn't present in the repo — the "scan a photo" path depends on it being deployed.
- **Payments/Pro tier are out of scope** this build (the `plan` field is a placeholder for future billing).
- SRS mentions Gemini via Vertex AI as the intended path; the implemented code uses the Gemini API key through LangChain's `google-genai` — explain it as "Gemini, called only from the server."

---

## 15. One-line summaries to memorise
- **Architecture:** UI → Cubit → Repository interface → (mock | Firebase | HTTP), chosen by `dart-define` flags, injected with `flutter_bloc` providers.
- **Why repository pattern:** testability, swap-ability, separation of concerns, mock-first dev.
- **Why a backend:** hide the Gemini key + enforce admin server-side.
- **Security:** Firebase ID token on every request + server-verified `admin` claim + Firestore Rules + HTTPS.
- **Reliability:** two-layer AI fallback + offline Firestore persistence → a flow never crashes.
- **Design:** centralised tokens (colours/typography/spacing) + bento cards + three-font system + original Tako mascot.
