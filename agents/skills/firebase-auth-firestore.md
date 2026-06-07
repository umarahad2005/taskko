---
name: firebase-auth-firestore
description: Firebase Auth (email/password + Google) and Cloud Firestore data model, real-time reads, offline persistence, and Security Rules for Taskko.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Skill: Firebase Auth + Firestore

Covers the client side of SRS §2.1 (Flutter ↔ Firestore directly for everyday CRUD; Auth issues ID tokens).

## Auth (SRS FR-3.*)
- Email/password sign up + login, Google Sign-In, password reset, error mapping to inline messages.
- On first auth, create the `users/{uid}` profile; route to Home; if `isAdmin`, surface admin entry (FR-3.7).

## Firestore data model (SRS §7.1)
```
users/{uid} : name,email,avatar,rank,points,streak{days,shields},mood,isAdmin,plan,createdAt,lastActiveAt
users/{uid}/tasks/{id} : title,minutes,points,goalRef,status,date,completedAt,source,reflection?
users/{uid}/goals/{id} : text,createdAt,status,generatedTaskIds[]
users/{uid}/badges/{id} : key,title,unlockedAt
users/{uid}/sessions/{id} : start,end,taskIds,moodAtStart,breaksTaken
users/{uid}/chats/{id} : from,text,kind,actions[],ts
squads/{id} : name,memberUids[],createdAt
moderation/{id} : targetUid,reason,severity,status,createdAt
config/{ranks|badges|featureFlags}
```

## Rules (NFR-2)
- Security Rules: a user can read/write only their own `users/{uid}/**`; `config/*` read-only to clients; `moderation/*` and cross-user reads require the **admin** claim.
- Use real-time listeners for live points/streak/leaderboard; enable offline persistence (NFR-4).
- Never store the Gemini key or admin logic client-side — those live in the backend.
- Behind a `repository` interface so the mock impl can stand in until M9.
