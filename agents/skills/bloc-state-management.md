---
name: bloc-state-management
description: Taskko's state-management conventions using flutter_bloc (Cubit-first) — folder structure, state shapes, async loading/error handling, and DI.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Skill: BLoC State Management (Cubit-first)

Per SRS §2.5 the app uses `flutter_bloc`, **Cubit-first**, with full event-based BLoC only where event streams add value.

## Folder structure (feature-first)
```
lib/features/<feature>/
  cubit/<feature>_cubit.dart
  cubit/<feature>_state.dart
  view/<feature>_screen.dart
  widgets/...
lib/repositories/<x>_repository.dart   ← interface
lib/repositories/mock/<x>_repository_mock.dart
lib/repositories/firebase/<x>_repository_firebase.dart
```

## State shape (explicit async)
Use a sealed/union state or a status enum so every async surface renders loading/success/error cleanly:
```dart
enum Status { initial, loading, success, failure }
class XState {
  final Status status; final XData? data; final String? error;
}
```
- AI calls (breakdown, chat) and auth **must** expose `loading` + `failure` with retry (SRS FR-5.4, FR-7.6, NFR-4).

## Rules
- Cubits depend on **repository interfaces**, never on Firebase/HTTP directly (enables mock→real swap, SRS §2.6).
- Provide repositories + cubits via `RepositoryProvider` / `BlocProvider` at app root; inject the mock or real impl by build flavor/env.
- Keep UI dumb: `BlocBuilder`/`BlocListener`; side-effects (navigation, snackbars, haptics) in listeners.
- One Cubit per feature surface; shared cross-feature state (auth, gamification) lives in app-level Cubits.
