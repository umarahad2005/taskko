---
name: design-fidelity
description: How to verify a built screen matches the approved Taskko prototype frames within tolerance — token checks, layout/hierarchy checks, and the audit report format.
tools: [Read, Glob, Grep]
model: sonnet
---

# Skill: Design Fidelity

Used by the `design-audit` subagent and the `qa-agent` to enforce gate **G-design**.

## Reference
- Rendered frames: `../design_reference/project/frames/{splash,onboarding-1..3,signup,login,home,plan,hub,chat}.png`.
- Tokens: SRS §7. Per-screen layout: SRS §3 (FR-*).

## Checklist (per screen)
1. **Tokens** — colors, fonts (Manrope/Fraunces/JetBrains Mono), radii (20–28px) match §7. No stray hex.
2. **Layout** — same regions in the same order/hierarchy as the frame (e.g. Home: header → streak+rank cards → mood → "Next up" hero → today's tasks → tab bar).
3. **Hierarchy & balance** — primary action is the visual focus (SRS §8); gamification doesn't overwhelm.
4. **States** — loading/empty/error present where the SRS requires (AI, auth).
5. **Copy & affordances** — buttons look clickable; labels match intent.

## Audit report (return this)
```json
{ "screen":"home", "match":"pass|minor|fail",
  "deltas":[{"region":"mood card","issue":"radius 16 vs 24","fr":"FR-4.4"}],
  "tokens_ok":true, "recommend":"adjust radius to 24" }
```
Tolerance: `minor` deltas (≤4px spacing, antialiasing) pass the gate; `fail` reopens the task.
