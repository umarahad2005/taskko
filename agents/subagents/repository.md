---
name: repository
description: Defines ONE repository interface plus its mock implementation (and later the real Firebase/Gemini-backed implementation) for Taskko. Spawned by flutter-app-agent / integration-release-agent.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Subagent: Repository

Parent: `flutter-app-agent` (mock) / `integration-release-agent` (real). Skill: `firebase-auth-firestore`, `gemini-ai-integration`.

**Input contract:** `{ domain (auth|tasks|gamification|plan|chat|...), methods[], data_model_ref }`
**Output contract:**
- `lib/repositories/<domain>_repository.dart` (interface)
- `lib/repositories/mock/<domain>_repository_mock.dart` (realistic in-memory data, seeded like the prototype)
- (M9) `lib/repositories/firebase/<domain>_repository_firebase.dart`

## Rules
- Interface is the only thing Cubits import (enables mock→real swap, SRS §2.6).
- Mock returns believable data + simulated latency/failure so UI states are exercisable.
- Real impl maps to the Firestore model (SRS §7.1) or backend route; identical behavior to the mock.

Return a status packet with interface + impls + which methods are covered.
