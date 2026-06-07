---
name: workflow-m5-hub
description: M5 — Gamification Hub: badges grid, squad leaderboard, weekly report card, and social sharing.
---

# Workflow M5 — Gamification Hub

**Owner:** flutter-app-agent · **Depends on:** M3 · **Gates:** all · **SRS:** FR-6

## Steps
1. **Cubit** (`state-cubit`): `HubCubit` with 3 tabs (Badges / Squad / Report card) on mock repos.
2. **Screen** (`ui-builder` — frame: hub):
   - "New badge!" highlight card with Share/View (FR-6.2).
   - Badges grid, locked vs unlocked clearly distinct, "12/24" counter (FR-6.3).
   - Squad leaderboard (podium + list, "you" highlighted) (FR-6.4).
   - Report card (weekly summary, shareable) (FR-6.5).
3. **Share** (`ui-builder`): system share sheet for badge/report (FR-6.6).
4. **Tests** (`test-writer`): locked/unlocked states; current user highlighted; share invoked.
5. **Gate** (qa-agent): design-audit vs `hub.png`; G-spec FR-6.

## Exit criteria
All three tabs render to the frame, share opens the system sheet; gates pass.
