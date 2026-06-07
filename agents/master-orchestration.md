---
name: master-orchestration
description: Real-time controller for the Taskko build — owns the dependency graph, live status board, agent/subagent assignment, quality gates, and handoffs across milestones M1–M9.
tools: [Agent, Workflow, Task, Read, Grep, Glob, Edit, Write]
model: opus
---

# Master Orchestration — Taskko Build Controller

The master is the single brain that decides **what runs now**, **who runs it**, and **whether it passed**. It does not write feature code itself; it assigns work to **agents**, who spawn **subagents**, and it integrates their reported state in real time.

Authoritative spec: `../docs/SRS.md`. Visual truth: `../design_reference/project/frames/`.

---

## 1. Roster under control

### Primary agents (`agents/`)
| Agent | Owns | SRS scope |
|---|---|---|
| `flutter-app-agent` | Flutter mobile client (all 8 phone screens) | FR-1…FR-10, §7, §8 |
| `backend-agent` | Next.js serverless API on Vercel + Gemini + Firebase Admin | §6, FR-5.3/7.2/9.1, NFR-2 |
| `admin-web-agent` | React admin portal on Vercel | FR-11.* |
| `integration-release-agent` | Real Firebase/Gemini wiring, seed data, APK, deploy | §2.1, Deliverables |
| `qa-agent` | Testing + design-fidelity audits (cross-cutting) | §10, NFR-1…9 |

### Subagents (`subagents/`)
`ui-builder` · `state-cubit` · `repository` · `firestore-rules` · `api-endpoint` · `ai-prompt` · `admin-page` · `test-writer` · `design-audit`

### Skills (`skills/`)
`flutter-ui-theming` · `bloc-state-management` · `firebase-auth-firestore` · `gemini-ai-integration` · `nextjs-serverless-api` · `react-admin-portal` · `design-fidelity` · `testing-qa`

---

## 2. Dependency graph (milestone DAG)

```
M1 Foundation ──┬──► M2 Pre-auth ──► M3 Home ──┬──► M4 Plan Studio ─┐
                │                               ├──► M5 Hub          ├─► M9 Integration
                │                               └──► M6 Tako Chat ───┤   + Release
                └──► M7 Backend (Vercel/Gemini) ────────────────────┤
                └──► M8 Admin Portal (React) ───────────────────────┘
```
Rules:
- **M1 blocks everything.** Nothing starts until the foundation gate passes.
- After M1, **M7 (backend)** and **M8 (admin)** may run **in parallel** with the app track (M2→M6) because the app uses the **mock repository layer** until M9 (per SRS §2.6).
- **M9** requires M2–M8 green and live Firebase/Gemini keys.

---

## 3. Real-time control loop

The master repeats this loop while any milestone is `in_progress`:

1. **Read board** → find milestones whose dependencies are all `done` and that are `ready`.
2. **Schedule** → for each runnable milestone, invoke its workflow (`workflows/mN-*.md`); independent milestones are launched **in parallel** (single dispatch, multiple agents).
3. **Assign** → the owning agent decomposes the milestone into subagent tasks with explicit input/output contracts.
4. **Monitor** → subagents return a **status packet** (see §5). The master updates the board; it never polls files it doesn't need.
5. **Unblock / block** → on a returned `blocked`, the master resolves the dependency (spawns the missing prerequisite or escalates to the user) before resuming.
6. **Gate** → when all of a milestone's tasks are `done`, run the milestone **quality gate** (§4). Pass → mark `done`, unblock dependents. Fail → reopen the failing task with the gate's findings.
7. **Escalate** → anything needing a human decision (keys, API quota, design ambiguity, scope change) is surfaced to the user immediately, not guessed.

Parallelism cap and fan-out are delegated to the `Workflow`/`Agent` tooling; the master only decides *what is independent*.

---

## 4. Quality gates (between milestones)

A milestone is `done` only when its gate passes:

| Gate | Checks |
|---|---|
| **G-build** | Code compiles / `flutter analyze` clean / no type errors. |
| **G-design** | `design-audit` subagent confirms screen matches `frames/*.png` within tolerance (tokens from SRS §7). |
| **G-spec** | Every FR in the milestone's scope is implemented and demoable (maps to SRS §10). |
| **G-test** | `qa-agent` ran the relevant widget/unit tests; criticals pass. |
| **G-arch** | No secrets in client; AI only via backend; Firestore access matches rules (NFR-2). |

Each workflow lists which gates apply.

---

## 5. Status packet (subagent → master)

Subagents end with a compact, structured result so the master can track state without re-reading the repo:
```json
{
  "task": "ui-builder: HomeScreen",
  "milestone": "M3",
  "status": "done | in_progress | blocked",
  "deliverables": ["lib/features/home/view/home_screen.dart"],
  "fr_covered": ["FR-4.1","FR-4.2","FR-4.5"],
  "gates": { "G-build": "pass", "G-design": "pass" },
  "blocked_on": null,
  "notes": "Mood card wired to MoodCubit; real session-tuning deferred to M6."
}
```

---

## 6. Live Status Board

> The master updates this table as work progresses. `▢ ready` · `▶ in_progress` · `✔ done` · `⛔ blocked`.

| Milestone | Owner agent | Status | Depends on | Gates | Notes |
|---|---|---|---|---|---|
| M1 Foundation | flutter-app-agent | ✔ done | — | G-build ✅, G-arch ✅ | theme + nav + mock repos shipped; `flutter analyze` clean, tests pass |
| M2 Pre-auth | flutter-app-agent | ✔ done | M1 | G-build ✅, G-design ✅, G-spec ✅, G-test ✅ | splash(dark)/onboarding×3/signup/login; 8 tests pass |
| M3 Home | flutter-app-agent | ✔ done | M2 | G-build ✅, G-design ✅, G-spec ✅, G-test ✅ | dashboard (streak/rank/mood/next-up/tasks) + points/rank loop; 10 tests pass |
| M4 Plan Studio | flutter-app-agent | ✔ done | M3 | G-build ✅, G-design ✅, G-spec ✅, G-test ✅ | goal→generate→editable review→commit-to-today; 13 tests pass; real Gemini in M9 |
| M5 Hub | flutter-app-agent | ✔ done | M3 | G-build ✅, G-design ✅, G-spec ✅, G-test ✅ | badges grid + new-badge + squad leaderboard + shareable report card (real share_plus); 15 tests pass |
| M6 Tako Chat | flutter-app-agent | ✔ done | M3 | G-build ✅, G-design ✅, G-spec ✅, G-test ✅ | chat bubbles + nudge cards w/ actions + quick prompts + typing + input; 17 tests pass; real Gemini in M9 |
| M7 Backend | backend-agent | ✔ done | M1 | G-build ✅ (tsc), G-arch ✅, G-spec ✅ | Next.js /api + Gemini in admin/; npm install + tsc clean; contracts in admin/API_CONTRACTS.md; live keys → M9 |
| M8 Admin Portal | admin-web-agent | ✔ done | M1 | G-build ✅ (tsc), G-design ✅, G-spec ✅ | React UI in admin/: login gate + 6 sections wired to /api/admin/*; npm install + tsc clean |
| M9 Integration+Release | integration-release-agent | ▶ in_progress | M2–M8, keys | all | DONE: NDK fixed + APK builds; FirebaseAuth wired; firestore.rules deployed; Gemini **confirmed live** (gemini-2.5-flash, key+billing on GCP taskko-498611); Plan/Chat HTTP repos wired behind `USE_BACKEND`. TODO: set backend `FIREBASE_SERVICE_ACCOUNT` (rotated) for token verify; run/deploy backend; seed admin claim; real Firestore tasks/profile repos |

---

## 7b. Phase 2 backlog — see `../docs/IMPLEMENTATION_PLAN.md`
Post-MVP, all free (monetization deferred). Sprint 1 (app-only): **M10 Reminders**, **M11 History/stats**, **M12 Reflection**. Sprint 2: **M13 AI plan-day+quiz**, **M16 Real admin data**. Sprint 3: **M14 Social**, **M15 Hardening**. **M17 Monetization** deferred (post-funding).
- **M10 Scheduled reminders ✔** — `services/notification_service.dart` (zonedSchedule + timezone), `repositories/settings_repository*` (Firestore prefs at `users/{uid}/settings/reminders`), `features/settings` (cubit+screen), opened from Profile. Android needed **core library desugaring** (`isCoreLibraryDesugaringEnabled=true` + `desugar_jdk_libs:2.1.4` in `android/app/build.gradle.kts`) for flutter_local_notifications.
- **M11 History/stats ✔** — `models/focus_session.dart`, `repositories/session_repository*`, `features/history` (cubit + screen, dependency-free 7-day bar chart). Focus completion logs a session.
- **M12 Reflection ✔** — 😫/😐/😀 rating at focus-session end, stored on the session.
- **Sprint 1 complete (M10–M12).** Next: Sprint 2 = M13 (AI plan-day+quiz, needs backend redeploy) + M16 (real admin data).

## 7. Escalation triggers (ask the user, don't assume)
- Firebase project / Gemini key / Vercel account access or quotas.
- Any visual ambiguity not resolvable from `frames/` + SRS §7.
- Scope changes (new screen, new feature) → append to SRS §12 first.
- Cost-bearing or irreversible actions (deploys, billing, data deletion).
