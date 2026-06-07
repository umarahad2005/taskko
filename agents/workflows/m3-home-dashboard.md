---
name: workflow-m3-home-dashboard
description: M3 — Home dashboard and the gamification engine: streak, rank, mood, "Next up", today's tasks, and points/streak/badge logic.
---

# Workflow M3 — Home / Dashboard + Gamification Engine

**Owner:** flutter-app-agent · **Depends on:** M2 · **Gates:** all · **SRS:** FR-4, FR-8, FR-9, §8

## Steps
1. **Engine** (`state-cubit`): `GamificationCubit` — award points, derive rank (Rookie→Pro→Elite→Legend), streak increment/break + shield auto-consume, badge auto-unlock (FR-8). `MoodCubit` (FR-9).
2. **Home cubit** (`state-cubit`): `HomeCubit` aggregating streak/rank/points/mood/next-up/today's tasks on mock repos.
3. **Screen** (`ui-builder` — frame: home): header, streak card, rank card, mood check-in, "Next up" hero CTA, today's tasks list with completion + immediate feedback (FR-4.1…4.8). TabScaffold active = Home.
4. **Feedback** (`ui-builder`): visual (+ haptic) on task done, points earned, rank-up, badge unlock (FR-4.7, FR-8.5, §8).
5. **Tests** (`test-writer`): completing a task updates points/progress; streak/shield logic; rank thresholds.
6. **Gate** (qa-agent): design-audit vs `home.png`; G-spec FR-4/8/9.

## Exit criteria
Home matches the frame, gamification engine correct + persisted (mock), feedback immediate; unblocks M4/M5/M6.
