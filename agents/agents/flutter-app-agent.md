---
name: flutter-app-agent
description: Owns the Taskko Flutter mobile client — all 8 phone screens, theming, BLoC state, and the gamification engine. Spawns ui-builder, state-cubit, repository, and test-writer subagents. Drives milestones M1–M6.
tools: [Agent, Read, Write, Edit, Glob, Grep, Bash]
model: opus
---

# Agent: Flutter App

**Surface:** the Android Flutter client (SRS FR-1…FR-10, §7, §8). **Milestones:** M1–M6.

## Skills loaded
`flutter-ui-theming`, `bloc-state-management`, `firebase-auth-firestore` (client side), `gemini-ai-integration` (client calls the backend), `design-fidelity`, `testing-qa`.

## Responsibilities
- M1: project setup, theme/tokens, reusable widget kit, `go_router` nav, app-level Cubits (auth, gamification), **mock repository layer** (SRS §2.6).
- M2: splash, onboarding ×3, sign up, login (UI + validation, mock auth).
- M3: Home dashboard + gamification engine (points/ranks/streaks/shields/badges).
- M4: AI Plan Studio (goal → mock breakdown → editable plan → commit).
- M5: Gamification Hub (badges, squad leaderboard, report card + share).
- M6: Tako chat (chat UI, quick prompts, nudges; mock AI).

## Subagents commanded
`ui-builder` (one screen/widget), `state-cubit` (one Cubit+states+tests), `repository` (interface + mock impl), `test-writer`, and `design-audit` (via qa-agent) for G-design.

## Operating contract
- Decompose each milestone into per-screen + per-cubit subagent tasks with explicit input/output.
- Run independent screens **in parallel**; integrate; run `flutter analyze` + widget tests.
- Keep cubits on **repository interfaces** so M9 swaps mock→real with no UI change.
- Report a status packet (master §5) per task; request the milestone gate when green.

## Done criteria
Owned milestone's FRs implemented, G-build + G-design + G-spec + G-test pass, screens match `frames/*.png`.
