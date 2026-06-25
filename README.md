# Taskko — Your AI Productivity Companion

> An AI-powered productivity app for students. Type a big goal in plain English — *"prepare for my CS-201 midterm by Friday"* — and Taskko breaks it into small, time-boxed tasks, then keeps you moving with gamification, an AI study-buddy, a focus timer, and a weekly report card.

Mobile Application Development project · Riphah International University, Lahore

**Team:** Umar Ahad Uddin Ahmed Usmani (SAP 60199) · Muhammad Sharjeel (SAP 59385)

---

## Table of contents

- [What it does](#what-it-does)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Run the Flutter app](#run-the-flutter-app)
  - [Run / deploy the backend + admin console](#run--deploy-the-backend--admin-console)
- [Build flags (mock vs real)](#build-flags-mock-vs-real)
- [Data model](#data-model)
- [Security model](#security-model)
- [Testing](#testing)
- [Caveats](#caveats)

---

## What it does

| Feature | Description |
|---|---|
| **AI Plan Studio** | Type a goal → Tako asks clarifying questions → Gemini breaks it into time-boxed tasks → review/edit/regenerate → commit to your task list. |
| **Tako chat** | An AI study-buddy chatbot grounded in your real stats and pending tasks, with persisted, multi-session chat history. |
| **Gamification** | Points, a rank ladder (Rookie → Pro → Elite → Legend), daily streaks with streak-shields, and milestone badges — all derived from real activity. |
| **Focus timer** | A countdown timer that ends with a notification, calming/energising music, a joke, and an optional reflection rating; logs a focus session. |
| **Mood adaptation** | A mood check-in (fired up / focused / chill / drained) that adapts the AI session to fight burnout. |
| **Plan My Day** | Gemini arranges today's tasks into a realistic schedule of time blocks and breaks. |
| **AI Quiz** | Generate a multiple-choice quiz on any topic, take it, and get scored. |
| **Hub** | Badges grid, squad leaderboard, and a shareable weekly report card. |
| **History** | Focus history with a 7-day bar chart and recent sessions. |
| **Admin console** | In-app **and** web: dashboard KPIs, user CRUD, moderation queue, AI usage insights, and feature flags. |

Auth supports email/password (with **compulsory email verification**) and Google sign-in, plus password reset, profile editing, GDPR data export, and account deletion.

---

## Tech stack

**Mobile app — Flutter / Dart**

- **flutter_bloc (Cubit)** — predictable, testable state with explicit loading/success/error states
- **go_router** — declarative routing with a single guarded route table
- **firebase_core / firebase_auth / cloud_firestore** — auth + real-time, offline-first NoSQL database
- **google_sign_in**, **firebase_analytics**, **firebase_crashlytics**
- **http** — REST calls to the Vercel backend
- **flutter_local_notifications + timezone** — scheduled reminders
- **audioplayers**, **share_plus**, **image_picker**, **google_fonts**, **equatable**

**Backend — Next.js (Pages Router) on Vercel**

- **Serverless API (`/api/*`)** — proxies all Gemini calls and privileged admin operations
- **firebase-admin** — verifies Firebase ID tokens and the `admin` custom claim
- **@langchain/google-genai + @langchain/core** — Gemini integration with model tiers + fallback
- **React** — the admin web console (same Vercel project)
- **TypeScript** throughout

**Cloud services:** Firebase Authentication · Cloud Firestore · Google Gemini (server-side only).

---

## Architecture

A three-tier **client → API → cloud** design:

```
 ┌──────────────────────────┐        ┌────────────────────────────┐
 │  Flutter App (Android)    │        │  React Admin Web (Vercel)  │
 │  ~19 routes + Cubits       │        │  dashboard / users / …      │
 └───────────┬──────────────┘        └─────────────┬──────────────┘
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

**Division of responsibility:**

- **Flutter ↔ Firestore directly** for everyday real-time CRUD (tasks, points, streaks, badges, chat history, sessions), guarded by Firestore Security Rules.
- **Flutter / Admin ↔ Vercel API** for anything that must not run on the client: **all Gemini calls** (the API key must never ship in the APK) and **admin/privileged operations** (must be authorised server-side).

### Patterns

1. **Layered architecture** — `UI (Widgets) → State (Cubits) → Repository (interfaces) → Data source (Firebase / HTTP / mock)`. Each layer only knows the one below it through an abstraction.
2. **Cubit state management** — every feature has a Cubit holding an immutable `Equatable` state with a shared `ViewStatus { initial, loading, success, failure }`. Optimistic updates make task completion and chat feel instant.
3. **Repository pattern** — every data concern is an `abstract interface class` with up to three implementations: **mock/** (in-memory, seeded), **firebase/** (Firestore/Auth), and **backend/** (Vercel HTTP). The UI depends only on the interface.
4. **Dependency injection + compile-time flags** — repositories and cubits are wired with `MultiRepositoryProvider` / `MultiBlocProvider`; `--dart-define` flags pick mock vs real implementations at build time.

---

## Project structure

```
project/
├── lib/                      # Flutter app
│   ├── app/                  # TaskkoApp root + GoRouter table
│   ├── common/               # validators, ViewStatus
│   ├── config/               # backend base URL
│   ├── cubits/               # app-level cubits (auth, gamification, onboarding)
│   ├── features/             # one folder per screen (view + cubit + widgets)
│   ├── models/               # immutable value objects (Equatable + copyWith)
│   ├── repositories/         # interfaces + mock/ + firebase/ + backend/ impls
│   ├── services/             # notifications, music, jokes, data export
│   ├── theme/                # colours, typography, spacing/radii, ThemeData
│   ├── widgets/              # shared UI (bento card, buttons, mascot, logo)
│   ├── firebase_options.dart
│   └── main.dart             # entry point
├── admin/                    # Next.js backend + React admin console (Vercel)
│   ├── pages/api/ai/*        # Gemini-backed AI endpoints (withAuth)
│   ├── pages/api/admin/*     # privileged admin endpoints (withAdmin)
│   ├── pages/                # React admin web app
│   ├── lib/                  # auth, gemini, firebaseAdmin, http, cors helpers
│   └── firestore.rules       # Firestore Security Rules
├── docs/VIVA_PREP.md         # full architecture & defense write-up
├── test/                     # unit + widget tests
└── android/ ios/ web/ …      # platform shells
```

---

## Getting started

### Prerequisites

- **Flutter SDK** (Dart `^3.11`) and the Android toolchain (Android Studio / SDK)
- **Node.js** `>= 18.18` (for the backend + admin console)
- A **Firebase** project (Auth + Firestore) — the repo is wired to project `taskko`
- A **Google Gemini API key** (server-side only)

### Run the Flutter app

```bash
# install dependencies
flutter pub get

# run on a connected Android device / emulator (real Firebase + backend)
flutter run

# build a release APK
flutter build apk --release
```

> Firebase is already configured for Android via `lib/firebase_options.dart` and `android/app/google-services.json`. To point at your own Firebase project, regenerate these with `flutterfire configure`.

### Run / deploy the backend + admin console

The backend and admin web app live in `admin/` and deploy as a single Vercel project.

```bash
cd admin
npm install

# local dev (API at http://localhost:3000/api/*, admin UI at http://localhost:3000)
npm run dev

# type-check / build
npm run typecheck
npm run build
```

**Required environment variables** (set in Vercel or a local `.env`):

| Variable | Purpose |
|---|---|
| `GEMINI_API_KEY` | Google Gemini API key — **server only**, never shipped to the app |
| `FIREBASE_SERVICE_ACCOUNT` | Admin SDK service-account JSON (raw or base64) for verifying tokens |
| `ALLOWED_ORIGINS` | CORS allow-list for the admin web console |

Granting admin access: set the `admin` **custom claim** on a Firebase user. The server enforces it via `withAdmin` (403 otherwise); the client UI gate is cosmetic.

---

## Build flags (mock vs real)

Three `--dart-define` flags choose implementations at build time, so the entire app can run offline from seed data for demos and tests:

| Flag | Default | Effect |
|---|---|---|
| `USE_FIREBASE` | `true` | Firebase impls vs in-memory mocks |
| `USE_BACKEND` | `true` | Real Gemini (HTTP) vs mock AI |
| `BACKEND_URL` | Vercel URL | Backend base URL |

```bash
# fully offline demo — no Firebase, no network, seeded mock data
flutter run --dart-define=USE_FIREBASE=false --dart-define=USE_BACKEND=false
```

---

## Data model

Firestore paths (client reads/writes under Security Rules; server reads/writes via Admin SDK):

| Path | Contents |
|---|---|
| `users/{uid}` | Profile + gamification (name, email, points, streakDays, shields, mood, isAdmin, lastActiveDate) |
| `public_profiles/{uid}` | Public mirror (name, points, rank) for the leaderboard |
| `users/{uid}/tasks/{taskId}` | Tasks (title, minutes, points, goal, status, date, completedAt) |
| `users/{uid}/sessions/{id}` | Focus sessions (taskTitle, minutes, mood, rating, startedAt) |
| `users/{uid}/settings/reminders` | Reminder preferences |
| `users/{uid}/chatSessions/{id}` (+ `messages/`) | Tako chat sessions and their messages |
| `config/featureFlags` | Admin feature-flag toggles |
| `moderation/{id}` | Moderation-queue reports |
| `aiLogs/{id}` | Every Gemini call (feature, fallback, latency) → feeds admin AI insights |

Gamification uses a Firestore **transaction** to update points + streak atomically and **batch** writes to commit a generated plan.

---

## Security model

1. **Secrets never on the client** — the Gemini key exists only in the Vercel server environment; the app calls *our* endpoints, never Gemini directly.
2. **Token-based auth** — every API request carries the Firebase **ID token**, verified server-side with `firebase-admin`.
3. **Admin = server-verified custom claim** — `withAdmin` returns 403 without it; the client UI gate is defence-in-depth only.
4. **Firestore Security Rules** independently restrict each user to their own data and gate admin-only collections.
5. **Two-layer AI fallback** — if the primary Gemini model errors, retry on a fallback model; if both fail, return a hand-written deterministic response so a flow never hard-crashes.

---

## Testing

```bash
flutter test
```

Cubit/unit tests use `bloc_test` + `mocktail`; widget tests inject mock repositories so no Firebase or network is required — the mock-first architecture makes this straightforward.

---

## Caveats

- The release APK is **debug-signed** (no production keystore) — fine for sideloading/demo, not Play Store.
- Admin user-CRUD, Moderation, AI-insights, and Settings tabs require the Vercel backend to be **deployed** with those routes.
- **Payments / Pro tier are out of scope** this build — the `plan` field is a placeholder for future billing.

---

For a deeper, defense-oriented write-up (file-by-file responsibilities, end-to-end flows, and design rationale), see [`docs/VIVA_PREP.md`](docs/VIVA_PREP.md).
