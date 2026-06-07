# Taskko API Contracts (Vercel serverless)

All endpoints are Next.js serverless functions under `admin/pages/api/`. Every
request requires `Authorization: Bearer <Firebase ID token>`; admin routes also
require the `admin` custom claim. Errors use `{ "error": string, "retryable": boolean }`.
Base URL in production = the Vercel deployment origin (e.g. `https://taskko.vercel.app`).

> The Flutter app calls only the **AI** routes (and `/me`); everyday CRUD goes
> straight to Firestore. The admin web app calls the **admin** routes.

## Auth & profile
| Method | Path | Body | 200 response | FR |
|---|---|---|---|---|
| GET | `/api/me` | — | `{ uid, email, name?, isAdmin }` | — |

## AI (Gemini, server-side)
| Method | Path | Body | 200 response | FR |
|---|---|---|---|---|
| POST | `/api/ai/clarify` | `{ goal: string }` | `{ questions: [{question, options[]}] }` (empty if goal is specific) | FR-5.2 |
| POST | `/api/ai/breakdown` | `{ goal: string, availableMinutes?: number }` | `{ tasks: [{title,minutes,points}], fallback: bool }` | FR-5.3 |
| POST | `/api/ai/regenerate` | `{ goal: string, availableMinutes?: number, avoid?: string[] }` | `{ tasks: [...], fallback: bool }` | FR-5.5 |
| POST | `/api/ai/chat` | `{ message: string, context?: UserContext }` | `{ reply: string, fallback: bool }` | FR-7.2 |
| POST | `/api/ai/nudge` | `{ context?: UserContext }` | `{ nudge: {text, actions:[{label,action}]}, fallback: bool }` | FR-7.5 |
| POST | `/api/ai/mood-session` | `{ mood: string, context?: UserContext }` | `{ session: {suggestedMinutes,taskCount,tone,message}, fallback: bool }` | FR-9.1 |
| POST | `/api/ai/plan-day` | `{ tasks:[{title,minutes}], availableMinutes, mood }` | `{ blocks:[{start,end,taskTitle}] }` | M13 |
| POST | `/api/ai/quiz` | `{ topic, count?, difficulty? }` | `{ questions:[{q,options[],answerIndex}] }` | M13 |

`UserContext = { name?, rank?, points?, streakDays?, shields?, mood?, pendingTasks?[] }`

## Admin (admin claim required)
| Method | Path | Body / query | 200 response | FR |
|---|---|---|---|---|
| GET | `/api/admin/metrics` | — | KPIs, engagement[], rankDistribution[], topGoals[], activityFeed[] | FR-11.3 |
| GET | `/api/admin/users` | `?filter=all|pro|free|flagged|suspended&q=` | `{ users: AdminUser[] }` | FR-11.4 |
| POST | `/api/admin/users` | `{ userId, action: suspend|reinstate|grant_points, points? }` | `{ user: AdminUser }` | FR-11.4 |
| GET | `/api/admin/moderation` | `?severity=all|low|medium|high` | `{ items: ModerationItem[] }` | FR-11.5 |
| POST | `/api/admin/moderation` | `{ itemId, action: dismiss|warn|suspend }` | `{ item }` | FR-11.5 |
| GET | `/api/admin/ai-insights` | — | usage, costUsd, quality[], stuckPhrases[], recentPrompts[] | FR-11.6 |
| GET | `/api/admin/settings` | — | `{ flags, adminTeam }` | FR-11.8 |
| PATCH | `/api/admin/settings` | `{ flags?: Record<string,bool> }` | `{ flags, adminTeam }` | FR-11.8 |

**Note:** admin routes currently return clearly-marked `stub: true` data. M9 swaps
these for real Firestore reads/writes (the auth/claim enforcement is already real).
