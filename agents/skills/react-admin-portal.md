---
name: react-admin-portal
description: Building Taskko's React admin portal by adapting the existing prototype JSX — sections, layout, design fidelity, and wiring to the serverless API.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Skill: React Admin Portal

The admin portal is a **React app on Vercel** (SRS FR-11.*), adapted from the prototype's existing React source — a big head start.

## Reuse these prototype files
`../design_reference/project/admin-dashboard.jsx`, `admin-sidebar.jsx`, `admin-users.jsx`, `admin-rest.jsx`. Port their layout/visuals into the Next.js app; replace mock data with calls to `/api/admin/*`.

## Sections (FR-11.2…11.8)
- **Dashboard** — KPI cards (DAU, signups, active streaks, AI calls, conversions), engagement chart, rank distribution, top goals, live activity feed.
- **Users** — searchable/filterable table (All/Pro/Free/Flagged/Suspended) + profile drawer (suspend/reinstate, grant bonus points).
- **Moderation** — severity-filtered queue (dismiss/warn/suspend).
- **AI Insights** — Gemini usage/cost/quality, common "stuck" phrases, live prompt feed.
- **Revenue** — placeholder/analytics (no real billing this build).
- **Settings** — feature-flag toggles + admin-team management.

## Rules
- Dark sidebar + "Switch to student app" top-bar action (FR-11.2).
- Access gated by the **admin claim**; all actions authorized **server-side** (FR-11.9) — never trust the client.
- Match the prototype's look; reuse Taskko tokens (SRS §7) for accent colors.
- Auth via Firebase Web SDK; attach the ID token to every `/api` call.
