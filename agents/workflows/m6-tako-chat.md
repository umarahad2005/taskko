---
name: workflow-m6-tako-chat
description: M6 — Tako AI chatbot: chat UI, quick-prompt chips, actionable nudge cards, typing indicator (mock AI until M9).
---

# Workflow M6 — Tako Chat

**Owner:** flutter-app-agent · **Depends on:** M3 · **Gates:** all · **SRS:** FR-7, FR-9.1

## Steps
1. **Cubit** (`state-cubit`): `ChatCubit` — message list, send, typing indicator, failure + retry (FR-7.3, 7.6).
2. **Repo** (`repository`): `chat` repo — mock replies picked by intent + user context (streak/points/mood/tasks); seeded conversation like the prototype. (Real impl calls `/api/ai/chat` at M9.)
3. **Screen** (`ui-builder` — frame: chat): bubbles (user/Tako + mascot), header with mode, quick-prompt chips (FR-7.4), inline nudge cards with action buttons (FR-7.5).
4. **Nudge actions** (`ui-builder`): "Start a session" / "Remind me in 1h" perform real actions.
5. **Tests** (`test-writer`): send → typing → reply; AI failure fallback; quick-prompt fires; nudge action runs.
6. **Gate** (qa-agent): design-audit vs `chat.png`; G-spec FR-7.

## Exit criteria
Conversational flow with quick prompts + actionable nudges to the frame; graceful AI failure; gates pass.
