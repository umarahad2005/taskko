---
name: workflow-m4-plan-studio
description: M4 — AI Plan Studio: goal input → AI breakdown (mock until M9) → editable plan → commit to today.
---

# Workflow M4 — AI Plan Studio

**Owner:** flutter-app-agent · **Depends on:** M3 · **Gates:** all · **SRS:** FR-5

## Steps
1. **Cubit** (`state-cubit`): `PlanCubit` with 3-step flow (Goal → Break down → Customize), explicit loading/failure + retry (FR-5.1, 5.4).
2. **Repo** (`repository`): `plan` repo — mock breakdown returns believable tasks `[{title,minutes,points}]` with simulated latency/failure. (Real impl calls `/api/ai/breakdown` at M9.)
3. **Screen** (`ui-builder` — frame: plan): goal input with validation (FR-5.2), step indicator, generation/loading state, editable list (edit/delete/add), Regen, Commit-to-today (FR-5.3…5.7).
4. **Tests** (`test-writer`): empty/oversized goal blocked; AI failure shows retry; commit adds tasks to today.
5. **Gate** (qa-agent): design-audit vs `plan.png`; G-spec FR-5.

## Exit criteria
Typed goal → editable AI plan → committed tasks appear in Today; all gates pass. (Swaps to real Gemini in M9 with no UI change.)
