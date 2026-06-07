---
name: flutter-ui-theming
description: How to build Taskko's Flutter UI and theme to match the approved prototype — design tokens, typography, bento cards, and reusable widgets.
tools: [Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Skill: Flutter UI & Theming

Turns SRS §7 design tokens and the `frames/*.png` into a Flutter theme + reusable widget kit.

## Design tokens (SRS §7 — authoritative)
- **Colors:** primary `#1FB6F0` (deep `#0E8FC4`, soft `#DDF3FE`), energy/streak `#FF8A65` (soft `#FFE6DD`), success/mint `#34D399` (soft `#D6F5E6`), gold `#F5C544`, rose `#F472B6`, lavender `#C7B8FF`. Ink `#0F0F1A / #2E2E3F / #6B6B82 / #A8A8BC`. Line `#ECECF3 / #DCDCE7`, surface `#FFFFFF`. Background = mint+lilac tinted neutral.
- **Type:** Manrope (UI, 400–800), Fraunces (display/headlines), JetBrains Mono (stats/timers/points). Add via `google_fonts` or bundled assets in `pubspec.yaml`.
- **Radii:** bento cards ~20–28px. **Reference frame:** 402×874 logical px.

## What to produce
- `lib/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart` (a single `ThemeData` + a `TaskkoTokens` extension).
- Reusable widgets in `lib/widgets/`: `BentoCard`, `PrimaryButton`, `SecondaryButton`, `StatPill`, `SectionHeader`, `TakoMascot` (abstract gradient spark, mood-driven), `TabScaffold` (bottom nav Home/Plan/Hub/Tako).
- Light mode only (per project decision); English-only.

## Rules
- Pull every color/size from tokens — **no magic hex** in screens.
- Match spacing/hierarchy from the frame, not the prototype's HTML structure.
- Mascot/logo are original (no copyrighted assets).
- Verify against `design_reference/project/frames/<screen>.png` via the `design-fidelity` skill.
