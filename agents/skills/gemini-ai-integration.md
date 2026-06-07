---
name: gemini-ai-integration
description: Server-side Gemini integration for goal breakdown, Tako chat, nudges, and mood-aware sessions — prompts, structured parsing, fallbacks, and cost/latency handling.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Skill: Gemini AI Integration

Gemini is called **only from the Vercel backend** (SRS §2.1, NFR-2) — never from the client. Key is a server env secret.

## Endpoints that use Gemini (SRS §6)
- `POST /api/ai/breakdown` — goal → ordered tasks `[{title,minutes,points}]` (FR-5.3).
- `POST /api/ai/regenerate` — regenerate a plan (FR-5.5).
- `POST /api/ai/chat` — Tako reply given `{message, context}` (FR-7.2).
- `POST /api/ai/nudge` — contextual nudge/action card (FR-7.5).
- `POST /api/ai/mood-session` — mood-aware session suggestion (FR-9.1).

## Prompting
- System prompt frames Tako: supportive student study-buddy, concise, motivating, never preachy; honors mood (Drained → shorter/gentler).
- Pass user **context** (streak, points, rank, mood, pending tasks) so replies are grounded.
- For breakdown, instruct strict JSON output; validate/parse and reject malformed responses.

## Robustness (FR-5.4, FR-7.6, NFR-1/4)
- Timeouts bounded under the Vercel function limit; on failure return a friendly fallback + `retryable: true`.
- Keep prompt + output bounded to stay within serverless execution time; stream/Edge only if long chat needs it.
- Log usage/cost/quality signals for the admin **AI Insights** view (FR-11.6).
