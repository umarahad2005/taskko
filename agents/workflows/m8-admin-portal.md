---
name: workflow-m8-admin-portal
description: M8 — React admin portal on Vercel: six sections adapted from prototype JSX, wired to the serverless API behind the admin claim. Runs parallel to the app track.
---

# Workflow M8 — Admin Portal (React)

**Owner:** admin-web-agent · **Depends on:** M1 (consumes M7 contracts) · **Gates:** G-build, G-design, G-spec · **SRS:** FR-11.* · **Parallel with M2–M6**

## Steps
1. **Shell** (agent): admin layout in the Next.js app — dark sidebar (6 sections) + top bar "Switch to student app"; Firebase Web auth + admin-claim guard (FR-11.1/11.2/11.9).
2. **Sections** (`admin-page`, parallel — adapt `design_reference/project/admin-*.jsx`):
   - Dashboard (KPIs, engagement chart, rank distribution, top goals, activity feed) — FR-11.3.
   - Users (filterable table + profile drawer: suspend/reinstate/grant points) — FR-11.4.
   - Moderation (severity queue: dismiss/warn/suspend) — FR-11.5.
   - AI Insights (Gemini cost/quality, stuck phrases, prompt feed) — FR-11.6.
   - Revenue (placeholder) — FR-11.7.
   - Settings (feature flags + admin team) — FR-11.8.
3. **Wire** to `/api/admin/*` (token on every call); mock data only until M7 contracts/live data exist.
4. **Gate** (qa-agent): design-audit vs prototype admin; G-spec FR-11.

## Exit criteria
Admin login → dashboard → manage user/moderation works behind the admin claim; sections match the prototype; gates pass.
