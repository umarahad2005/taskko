---
name: firestore-rules
description: Authors and tests Cloud Firestore Security Rules and the data-model shape for Taskko. Spawned by backend-agent / integration-release-agent.
tools: [Read, Write, Edit, Glob, Grep, Bash]
model: sonnet
---

# Subagent: Firestore Rules

Parent: `backend-agent` / `integration-release-agent`. Skill: `firebase-auth-firestore`.

**Input contract:** `{ collections[], admin_claim, ownership_model }`
**Output contract:** `firestore.rules` + a rules test (emulator) covering allow/deny cases.

## Rules (NFR-2)
- `users/{uid}/**` — read/write only when `request.auth.uid == uid`.
- `config/*` — read-only to clients.
- `moderation/*` and any cross-user read — require the **admin** custom claim.
- Default deny; explicit allows only.

Return a status packet listing rule coverage + tested allow/deny cases.
