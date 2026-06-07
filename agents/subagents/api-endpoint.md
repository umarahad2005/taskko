---
name: api-endpoint
description: Implements ONE Next.js serverless API route for Taskko, contract-first, with token/claim verification. Spawned by backend-agent.
tools: [Read, Write, Edit, Glob, Grep, Bash]
model: sonnet
---

# Subagent: API Endpoint

Parent: `backend-agent`. Skill: `nextjs-serverless-api`.

**Input contract:** `{ route, method, request_json, response_json, auth: token|admin, uses_gemini?: bool }`
**Output contract:** `pages/api/.../<route>.ts` + a route test.

## Rules
- Verify the Firebase ID token first; admin routes require the admin claim (NFR-2).
- Thin handler; logic in `lib/`. Standard error envelope `{ error, retryable }`.
- If `uses_gemini`, delegate prompt/parse to an `ai-prompt` subagent and bound work under the serverless limit.
- Publish the final request/response contract back to the parent for the client/admin to integrate.

Return a status packet with the route + contract + test result.
