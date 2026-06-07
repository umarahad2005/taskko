---
name: admin-page
description: Builds ONE React admin section for Taskko by adapting the prototype JSX and wiring it to its /api/admin endpoint. Spawned by admin-web-agent.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Subagent: Admin Page

Parent: `admin-web-agent`. Skill: `react-admin-portal`, `design-fidelity`.

**Input contract:** `{ section (dashboard|users|moderation|ai-insights|revenue|settings), prototype_jsx, api_routes[], fr_ids[] }`
**Output contract:** a React page/component under the Next.js admin app, wired to live `/api/admin/*` data.

## Rules
- Port the named `design_reference/project/admin-*.jsx` visuals; swap mock data for API calls.
- Attach the Firebase ID token to every request; gate on the admin claim.
- Privileged actions call the server (which authorizes) — never enforce only in the UI (FR-11.9).
- Match prototype look; Taskko tokens for accents (SRS §7).

Return a status packet with the page + endpoints used + a design self-check.
