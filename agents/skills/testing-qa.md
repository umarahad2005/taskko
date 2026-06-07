---
name: testing-qa
description: Testing strategy for Taskko — Flutter widget/unit/bloc tests, API route tests, and mapping tests to SRS acceptance criteria and quality gates.
tools: [Read, Write, Edit, Glob, Grep, Bash]
model: sonnet
---

# Skill: Testing & QA

Backs gates **G-build**, **G-test**, **G-spec**, **G-arch** (master §4) and SRS §10.

## Flutter
- **Unit/bloc tests** (`bloc_test`) for each Cubit: initial → loading → success/failure transitions, especially auth and AI flows (FR-5.4, FR-7.6).
- **Widget tests** for key screens: renders, primary CTA present, task-complete updates points (FR-4.7), validation blocks bad input (FR-3.1, FR-5.2).
- Repository tests against the **mock** impl so the suite runs without Firebase/Gemini.
- `flutter analyze` must be clean (G-build).

## Backend (Next.js /api)
- Route tests: rejects missing/expired token; admin routes reject non-admin (NFR-2); Gemini failures return `{error, retryable}` (FR-5.4).

## Acceptance mapping
Each milestone's exit criteria cite SRS §10 items; a milestone passes G-spec only when its FRs are demoable. The `qa-agent` records pass/fail per FR in its status packet.

## Demo readiness (Deliverables)
- Verify seeded demo data + student/admin accounts produce a clean viva flow.
- Verify APK installs and launches on the target emulator.
