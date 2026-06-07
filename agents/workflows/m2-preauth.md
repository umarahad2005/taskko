---
name: workflow-m2-preauth
description: M2 — Pre-auth flow: splash, 3-slide onboarding, sign up, and login with validation (mock auth).
---

# Workflow M2 — Pre-auth Flow

**Owner:** flutter-app-agent · **Depends on:** M1 · **Gates:** G-build, G-design, G-spec, G-test · **SRS:** FR-1, FR-2, FR-3

## Steps
1. **Cubits** (`state-cubit`, parallel): `OnboardingCubit`, `AuthCubit` (sign up/login/google/reset) on the mock auth repo — explicit loading/failure.
2. **Screens** (`ui-builder`, parallel — frames: splash, onboarding-1..3, signup, login):
   - Splash (auto-advance ~2.4s → onboarding/login per state) — FR-1.
   - Onboarding ×3 (dot indicator, Skip top-right, Next, Get started → Sign up) — FR-2.
   - Sign up (live validation, strength meter, show/hide, terms) — FR-3.1.
   - Login (forgot link, google) — FR-3.2/3.3; cross-links — FR-3.4.
3. **Tests** (`test-writer`): validation blocks bad input; auth failure shows inline error + keeps input.
4. **Gate** (qa-agent): `design-audit` on each screen vs frame; G-spec on FR-1/2/3.

## Exit criteria
New user can flow splash → onboarding → sign up/login → (mock) Home; all four gates pass.
