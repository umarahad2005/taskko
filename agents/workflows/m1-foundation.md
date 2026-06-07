---
name: workflow-m1-foundation
description: M1 — Flutter project foundation: theme/tokens, reusable widget kit, navigation, app-level cubits, and the mock repository layer.
---

# Workflow M1 — Foundation

**Owner:** flutter-app-agent · **Depends on:** — · **Gates:** G-build, G-arch · **SRS:** §7, §2.5, §2.6

## Preconditions
Flutter SDK ready; `pubspec.yaml` exists (starter). Decisions locked: flutter_bloc, Android-only, mock-first.

## Steps
1. **Setup** (agent): add deps (`flutter_bloc`, `go_router`, `google_fonts`, `equatable`, mock/test deps); define folder structure (`features/`, `repositories/`, `theme/`, `widgets/`).
2. **Theme** (`ui-builder`): `app_colors.dart`, `app_typography.dart`, `app_theme.dart` from SRS §7 tokens.
3. **Widget kit** (`ui-builder` ×N, parallel): `BentoCard`, `PrimaryButton`, `SecondaryButton`, `StatPill`, `SectionHeader`, `TakoMascot`, `TabScaffold`.
4. **Navigation + app cubits** (`state-cubit`): `go_router` routes for all 8 screens + admin entry; app-level `AuthCubit`, `GamificationCubit`.
5. **Mock repos** (`repository` ×N, parallel): interfaces + mock impls for auth, tasks, gamification, plan, chat (seeded like the prototype).
6. **Gate** (qa-agent): `flutter analyze` clean; G-arch (no secrets, repos behind interfaces).

## Deliverables
Themed app shell that boots to a placeholder, navigable, with mock data wired and the widget kit ready.

## Exit criteria
G-build + G-arch pass; downstream milestones (M2, M7, M8) unblocked.
