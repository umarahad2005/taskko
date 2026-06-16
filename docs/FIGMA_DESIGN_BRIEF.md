# Taskko — Complete Project & Design Brief (for Figma)

> Pixel-accurate specification of the **complete app — all 15 screens** — extracted
> directly from the implemented Flutter code (`lib/`), the theme tokens
> (`lib/theme/`), and the approved prototype (`design_reference/`). Every color
> is the exact hex that exists in the app.

**Core routes (15):**
1. Splash · 2. Onboarding (3 slides) · 3. Sign up · 4. Login · 5. Home ·
6. AI Plan Studio · 7. Gamification Hub · 8. Tako Chat · 9. Profile ·
10. Settings (Reminders) · 11. Focus Timer · 12. History · 13. Quiz ·
14. Plan My Day · 15. Admin Entry

**Figma frames (24 total — includes multi-step flows):**

| Flow | Frames in Figma |
|------|-----------------|
| Pre-auth | Splash · Onboarding 1–3 · Sign up · Login |
| Main tabs | Home · Plan Studio · Hub Badges · Hub Squad · Hub Report card · Tako Chat |
| Profile stack | Profile · Settings · History · Plan My Day · Admin Entry |
| **Quiz flow (4)** | Input (topic) → Generating → Taking → Result |
| **Focus flow (3)** | Setup (pick time) → Running (timer) → Done (joke + mood) |

---

## 1. What is Taskko?

**Taskko** is a Flutter mobile app — *"your AI productivity companion"* — the
MAD semester project (Riphah International University, Lahore). It fights the
student productivity crisis with three pillars:

1. **AI goal breakdown** — Gemini AI turns a typed goal ("Prep for CS-201
   midterm by Friday") into bite-sized tasks with minutes + points.
2. **Gamification** — points, ranks (Rookie → Pro → Elite → Legend), daily
   streaks, streak shields, milestone badges.
3. **Social accountability** — squad leaderboard, badge sharing, weekly
   report card.

Mascot/companion: **"Tako"** — an abstract gradient spark orb (original
branding, geometric shapes only). Stack: Flutter + Cubit, Firebase Auth +
Firestore, Gemini via Node API on Vercel, separate React admin portal.

**Reference frame: 402 × 874 px, portrait.** Screen gutter: **20 px**.

---

## 2. Design tokens (exact values from `lib/theme/`)

### 2.1 Colors

| Token | Hex | Use |
|-------|-----|-----|
| `primary` | `#1FB6F0` | Sky blue — brand, CTAs, active states |
| `primary2` | `#5BCBF5` | Gradient start |
| `primarySoft` | `#DDF3FE` | Soft blue fills, selected chips, pills |
| `primaryDeep` | `#0E8FC4` | Gradient end, dark-blue text on soft blue |
| `energy` | `#FF8A65` | Peach — streaks, avatar, spark |
| `energySoft` | `#FFE6DD` | Streak card fill |
| `mint` | `#34D399` | Success, done checkboxes, online dot |
| `mintSoft` | `#D6F5E6` | Break blocks |
| `gold` | `#F5C544` | 1st-place medal, fair password |
| `goldSoft` | `#FFF1C9` | Joke card fill |
| `rose` | `#F472B6` | Errors, destructive buttons (Sign out, Give up) |
| `lavender` | `#C7B8FF` | Drained mood, badge accent |
| `ink` | `#0F0F1A` | Primary text |
| `ink2` | `#2E2E3F` | Secondary text |
| `ink3` | `#6B6B82` | Tertiary text, labels, captions |
| `ink4` | `#A8A8BC` | Placeholders, disabled, inactive tabs |
| `line` | `#ECECF3` | Hairlines, locked badge fill, progress tracks |
| `line2` | `#DCDCE7` | Field/chip borders, disabled CTA fill |
| `surface` | `#FFFFFF` | Cards |
| `background` | `#F4F4FB` | Base background |
| `backgroundLilac` | `#F1F0FB` | BG gradient start |
| `backgroundMint` | `#EAF7F1` | BG gradient end |
| `splashTop` | `#1B2140` | Splash gradient start |
| `splashBottom` | `#0E1124` | Splash gradient end |
| `google` | `#4285F4` | Google "G" glyph only |

### 2.2 Gradients

| Name | Direction | Stops |
|------|-----------|-------|
| App background (`bgGradient`) | top-left → bottom-right | `#F1F0FB` → `#EAF7F1` |
| Primary CTA / logo | top-left → bottom-right | `#5BCBF5` → `#0E8FC4` |
| Energy / streak | top-left → bottom-right | `#FFB199` → `#FF8A65` |
| Splash backdrop | top → bottom | `#1B2140` → `#0E1124` |
| Auth screens | top → bottom | `#E7F4FD` @ 0% → `#F4F4FB` @ 45% |

### 2.3 Alpha overlays used in the app

| Usage | Base | Alpha |
|-------|------|-------|
| Streak bar (unlit) | `#FF8A65` | 25% |
| Rank progress track | `#1FB6F0` | 20% |
| Filled secondary button bg | `#1FB6F0` | 12% |
| StatPill bg | accent | 12% |
| Nudge card border | `#1FB6F0` | 40% |
| "Skip" button on Next-Up card | `#FFFFFF` | 18% |
| Badge medallion gradient | accent 85% → 100% |
| Badge medallion shadow | accent | 35% |
| Splash logo glow | `#1FB6F0` | 45% (blur 48, spread 4) |
| Splash tagline / loading | white | 70% / 60% / 24% |

### 2.4 Typography (Google Fonts)

| Family | Role | Notes |
|--------|------|-------|
| **Manrope** | UI / body / labels | w400–800 |
| **Fraunces** | Display / headlines | w700, line-height 1.1 |
| **JetBrains Mono** | Points, timers, stats, times | w700 |

Text scale: Display 34/28/24 Fraunces · Headline 20 w800 · Title 18/16 w700 ·
Body 15/14 w500 (`#2E2E3F`/`#6B6B82`) · Label 14 w700 · Label-sm 12 w700.
Section headers: UPPERCASE Manrope 11–12 w800 `#6B6B82`, letter-spacing 1.1.

### 2.5 Radii, spacing, shadows

| Token | Value |
|-------|-------|
| Radius sm / md / card / lg / pill | 12 / 16 / **24** / 28 / 999 |
| Spacing xs→xxxl | 4 / 8 / 12 / 16 / 20 / 24 / 32 |
| Gutter | 20 |
| **BentoCard shadow** | `rgba(20,60,90,0.08)`, blur 24, offset (0, 10) |
| Bottom nav shadow | `rgba(20,60,90,0.10)`, blur 24, offset (0, 8) |
| Badge medallion shadow | accent @ 35%, blur 16, offset (0, 6) |

---

## 3. Shared components (build as Figma components)

### TaskkoLogo
- Mark (size S): squircle S×S, radius **S×0.32**, primary gradient fill;
  white `check_rounded` icon at S×0.62; peach `#FF8A65` spark circle S×0.26
  offset −S×0.06 top-right.
- Wordmark: "taskko", Manrope 22 w800, `#0F0F1A` (white on dark), 10 gap.
- Sizes used: 96 (splash), 72 (login hero), 52 (signup hero), 30 (auth header), 28 (home/onboarding header).

### TakoMascot
- Frame S × (S×1.12). Antenna: `#FF8A65` circle S×0.16 top-center.
- Body: S×S squircle radius S×0.34, gradient `#5BCBF5` → mood color.
- Eyes: 2 white pills S×0.112 × S×0.16, gap S×0.16.
- Mood colors: Focused `#1FB6F0` · Fired up `#FF8A65` · Chill `#34D399` · Drained `#C7B8FF`.
- Sizes used: 72 (loading), 64 (onboarding), 44 (hub), 40 (mood card), 34 (chat header), 26 (chat bubbles).

### PrimaryButton
- H **54**, radius **28**, full width. Fill primary gradient; disabled = flat `#DCDCE7`.
- Label Manrope 16 w700 white; optional 20px white icon, 8 gap.

### SecondaryButton
- H **54**, radius **28**, pad-H 20.
- Outline: transparent + 1px `#DCDCE7` border, label = accent (default `#1FB6F0`, rose `#F472B6` for destructive).
- Filled: accent @ 12% bg, no border.

### BentoCard
- White (or token fill / gradient), radius **24**, pad **20** (12 for tiles), shadow above. No border.

### Text field (global)
- White fill, radius **24**, pad 16/16; border 1px `#DCDCE7`, focused 1.6px `#1FB6F0`.
- Input Manrope 15 w600 `#0F0F1A`; hint Manrope 14 w500 `#A8A8BC`.
- Label above: Manrope 13 w700 `#2E2E3F`, 6 gap.

### Bottom tab bar (TabScaffold)
- Floating pill: margins 16/16/12, pad-V 8, white, radius **28**, nav shadow.
- 4 tabs: Home `home_rounded` · Plan `adjust_rounded` · Hub `emoji_events_rounded` · Tako `auto_awesome_rounded`.
- Icon 24, label Manrope 11 w700, 2 gap. Active `#1FB6F0`, inactive `#A8A8BC`.

### StatPill
- Pad 12/6, pill radius, accent @ 12% bg; optional 14px icon; JetBrains Mono 12 label in accent.

### Selection chip (durations / quiz options / clarify answers)
- Pill radius. Selected: `#1FB6F0` fill, white Manrope 13–14 w700.
- Unselected: white fill, 1px `#DCDCE7` border, `#2E2E3F` label.

### Google SocialButton · AuthDivider · PasswordStrengthBar
- Google: H 54, white, 1px `#DCDCE7`, radius 24; "G" Manrope 18 w800 `#4285F4`; "Continue with Google" Manrope 15 w700 `#0F0F1A`.
- Divider: `#DCDCE7` lines + UPPERCASE Manrope 11 w800 `#A8A8BC` ls-0.8 center label.
- Strength bar: 3 segments H 4 radius 99, 6 gap; weak `#FF8A65` / fair `#F5C544` / strong `#34D399`; unlit `#DCDCE7`; label Manrope 11 w700 same color.

---

## 4. Screen-by-screen specification (all 15)

### 4.1 Splash
- **BG:** vertical gradient `#1B2140` → `#0E1124`. Decorative blobs: 220px `#1FB6F0` @ 18% (top: −60, right: −50); 200px `#FF8A65` @ 12% (bottom: −70, left: −60).
- **Center:** logo 96 with glow (`#1FB6F0` 45%, blur 48) → 24 gap → "taskko" Fraunces 40 white → 8 → "your AI productivity companion" Manrope 14 w500 white-70.
- **Bottom (56 up):** progress track 120×3 white-24, white fill; 12 gap; "loading…" Manrope 12 w600 white-60.

### 4.2 Onboarding (3 slides)
- **BG:** auth gradient (`#E7F4FD` → `#F4F4FB` @ 45%).
- **Top bar (pad 20/8):** logo 28 + wordmark left; "Skip" Manrope 14 w700 `#6B6B82` right.
- **Footer (pad 20, 16 bottom):** dots — active 22×6 `#0F0F1A`, inactive 6×6 `#DCDCE7`, radius 99, 6 gap; counter "1/3" JetBrains Mono 13 `#6B6B82` right. Below 16: PrimaryButton "Next" / "Get started" + `arrow_forward_rounded`.
- **Each slide (gutter 20):** title Fraunces 30 `#0F0F1A`, 12 gap, body Manrope 15 w500 `#6B6B82` lh 1.5.
  - **Slide 1 "Big goals, broken down."** — Tako 64 focused (right) → BentoCard pad 16: "GOAL" Manrope 10 w800 `#1FB6F0` / "Prep CS-201 midterm" Manrope 16 w700 → 3 mini task rows (pad 12, white, radius 24): 22×22 checkbox radius 7 (done `#34D399` + white check / undone white + 1px `#DCDCE7`), text Manrope 14 w600. Tasks: "Re-read chapters 5 & 6" (done), "Solve 10 problems", "Build a cheat sheet".
  - **Slide 2 "Show up, every day."** — Tako 64 firedUp → BentoCard energy gradient: "5" JetBrains Mono 48 white, "DAY STREAK" Manrope 12 w800 white, 5 white pills 26×8 → StatPill "Rank: Pro" + `emoji_events_rounded`.
  - **Slide 3 "Better with your squad."** — BentoCard leaderboard: rows pad 8 — rank circle 32 (Ali `#F5C544` 2,310 / You `#1FB6F0` 1,240 row bg `#DDF3FE` / Zara `#FF8A65` 980); name Manrope 15 w700; pts JetBrains Mono 13 `#6B6B82`.

### 4.3 Sign up
- **BG:** auth gradient. Scroll pad 20/12/20/24.
- Header logo 30 + wordmark → 24 → hero row: logo 52 + 12 gap + "Create your account" Fraunces 24 / "Set up your AI study buddy in 30 seconds." Manrope 13 w500 `#6B6B82` → 20 → Google button → 20 → divider "OR SIGN UP WITH EMAIL" → 16 → fields (16 gaps): Name (hint "Sara Khan"), Email (hint "sara@uni.edu"), Password (hint "At least 6 characters", eye toggle 20 `#A8A8BC`) + strength bar when typing → 16 → terms row: 28×28 checkbox (active `#1FB6F0`, radius 12) + "I agree to Taskko's **Terms** and **Privacy Policy**." (links Manrope 13 w700 `#1FB6F0`, rest w500 `#6B6B82`) → 16 → PrimaryButton "Create account" (disabled `#DCDCE7` until valid) → 16 → centered "Already on Taskko? **Log in**" (link w800 `#1FB6F0`).

### 4.4 Login
- **BG/pad:** same as Sign up.
- Header logo 30 → 32 → centered hero logo 72 → 16 → "Welcome back" Fraunces 28 centered → 4 → "Your streak's waiting." Manrope 14 w500 `#6B6B82` → 20 → Google → 20 → divider "OR" → 16 → Email field → 16 → Password field with trailing "Forgot?" Manrope 13 w700 `#1FB6F0` → 20 → PrimaryButton "Log in" → 12 → **Admin demo button**: H 48, 1px `#DCDCE7` border, radius 24, `shield_outlined` 16 `#6B6B82` + "Try as admin (demo)" Manrope 13 w700 `#2E2E3F` → 16 → "New here? **Create account**".

### 4.5 Home (tab 1)
- **BG:** bg gradient + bottom tab bar. List pad 20/8/20/24.
- **Header:** logo 28 + wordmark | (admins: black `#0F0F1A` pill `shield_rounded` 13 + "Admin" Manrope 12 w700 white) | 38px white circle `notifications_none_rounded` 20 `#2E2E3F` | 36px avatar `#FF8A65` initial "S" Manrope 15 w800 white.
- **Greeting (+16):** "THU · JUN 11" Manrope 12 w700 `#6B6B82` → "Morning, Sara 👋" Fraunces 30 → "You've got 3 tasks left today — let's go." Manrope 14 w500 `#6B6B82`.
- **Action row (+12):** 2 filled SecondaryButtons gap 12 — "Plan my day", "Quiz me".
- **Streak + Rank cards (+16, gap 12):**
  - Streak (fill `#FFE6DD`): `local_fire_department_rounded` 16 + "STREAK" Manrope 11 w800 `#FF8A65` → "5" Fraunces 40 + "days" Manrope 14 w700 `#6B6B82` → 5 bars H 6 (lit `#FF8A65`, unlit 25%) → `shield_rounded` 14 + "2 shields ready" Manrope 12 w600 `#6B6B82`.
  - Rank (fill `#DDF3FE`): `emoji_events_rounded` 16 + "RANK" `#0E8FC4` → "Pro" Fraunces 28 `#0E8FC4` + "1240 pts" JetBrains Mono 13 `#2E2E3F` → progress H 6 (`#1FB6F0` on 20% track, ~43%) → "320 pts to Elite" Manrope 12 w600 `#6B6B82`.
- **Mood card (+12, white):** "How are you feeling?" Manrope 17 w800 + "I'll tailor your session." 13 w500 `#6B6B82` + Tako 40 → 4 chips (pad 12/4, radius 24): 🔥 Fired up · 🎯 Focused · 🌿 Chill · 😮‍💨 Drained. Selected: `#DDF3FE` + 1.6px `#1FB6F0`, label 11 w700 `#0E8FC4`; unselected: white + 1px `#ECECF3`, label `#6B6B82`.
- **Next-up card (+12, primary gradient):** `bolt_rounded` 16 + "NEXT UP" 11 w800 white → "Draft sociology essay intro" Fraunces 22 white → meta `schedule_rounded` 14 + "25 min" 12 w700 white-70 · "+30 pts" JetBrains Mono 12 white · "· Essay due Friday" → buttons: "Start now" (white pill H 50, `play_arrow_rounded` 22 + 16 w800 `#0E8FC4`) + "Skip" (white @ 18%, 16 w700 white). All-done variant: `celebration_rounded` 28 + "All done for today! 🎉" Fraunces 20 white.
- **Today's tasks (+20):** header "TODAY'S TASKS" + "2/5 done · 40%" Manrope 13 w700 `#0E8FC4` → TaskTiles (pad 12, gap 8): checkbox 26×26 radius 8 (todo: white + 1.5px `#DCDCE7`; done: `#34D399` + 18 white check) + title Manrope 15 w700 (done: `#A8A8BC` strikethrough) + meta "⏱ 30m · CS-201 midterm" 12 w600 `#6B6B82` + "+40" JetBrains Mono 13 `#0E8FC4` (done `#A8A8BC`). Demo: notes/BST done; essay, flashcards, TA email todo.

### 4.6 AI Plan Studio (tab 2)
- **BG:** bg gradient + tab bar. Pad 20/8/20/16.
- **Title row:** `auto_awesome_rounded` 18 `#1FB6F0` + "AI Plan Studio" Manrope 18 w800.
- **Step indicator:** 3 segments (Goal · Break down · Customize): bar H 4 radius 99 — done/current `#1FB6F0`, future `#DCDCE7`; label Manrope 11 w700 — `#0E8FC4` / `#A8A8BC`.
- **Step 1 Goal:** "What's your goal?" Fraunces 26 → "Drop a big goal — Tako breaks it into bite-sized tasks." 14 w500 `#6B6B82` → multiline field (hint "e.g. Prep for CS-201 midterm by Friday") → bottom PrimaryButton "Break it down" + `auto_awesome_rounded` (disabled < 3 chars).
- **Step 2 Clarify:** "A few quick questions" Fraunces 24 → questions Manrope 15 w700 + chip wraps (selection chip spec) → PrimaryButton "Generate my plan" + link "Skip — just use my goal" 13 w700 `#6B6B82`.
- **Generating:** centered Tako 72 → "Breaking it down…" Fraunces 20 → "Tako is shaping your plan" 13 w500 `#6B6B82` → bar 120×4 `#1FB6F0` on `#ECECF3`.
- **Step 3 Review:** "YOUR PLAN" 11 w800 `#6B6B82` + goal Fraunces 20 + "Regen" pill (1px `#DCDCE7`, `refresh_rounded` 16 + 13 w700 `#2E2E3F`) → PlanTaskCards (pad 12, gap 8): index badge 30×30 radius 10 `#DDF3FE` w/ Manrope 14 w800 `#0E8FC4` + title 15 w700 + "⏱ 45m  +60 pts" JetBrains Mono 12 `#0E8FC4` + `edit_outlined` / `close_rounded` 18 `#6B6B82` → "Add a task" row (H 50, dashed-look 1px `#DCDCE7`, white 40%, `add_rounded`) → PrimaryButton "Add 6 tasks to today" + check. Edit sheet: white, top radius 28, "Edit task" Fraunces 20, fields, "Save".

### 4.7 Gamification Hub (tab 3)
- **Header (pad 20/8):** "Trophy room" Fraunces 28 + "Earn it, share it, lord it over your squad." 13 w500 `#6B6B82` + Tako 44 firedUp.
- **Segmented control:** white pill pad 4; segments pad-V 10 — selected `#0F0F1A` fill + white 13 w700; unselected `#6B6B82`. Tabs: Badges · Squad · Report card.
- **Badges tab:** NewBadgeCard (fill `#FFE6DD`): "NEW BADGE!" 11 w800 `#FF8A65` → "5 streak" Fraunces 22 → "Unlocked this morning" 12 w500 `#6B6B82` → Share btn (`#FF8A65` pill, `ios_share_rounded` 15 + 13 w700 white) + View (white pill, `#2E2E3F`); right: 64 medallion (accent gradient 85→100%, shadow 35%, emoji 🔥). Then "ALL BADGES" + "4/9" → grid 3-col, gap 12, ratio 0.82: BentoCard pad 12/8, medallion 52 (unlocked = accent gradient + emoji; locked = `#ECECF3` + `lock_rounded` 20 `#A8A8BC`), title 12 w700 (locked `#A8A8BC`). Accent cycle: `#FF8A65` `#1FB6F0` `#F5C544` `#34D399` `#F472B6` `#C7B8FF` `#0E8FC4`. Demo: 🔥 5 streak, ⭐ First win, 🌙 Night owl, ⚡ Speedrun unlocked; 🎧 🤝 🐦‍🔥 👑 🎓 locked.
- **Squad tab:** leader rows (BentoCard pad 12, gap 8): pos Manrope 15 w800 `#6B6B82` W 26 · avatar 32 (1st `#F5C544`, 2nd `#A8A8BC`, 3rd `#FF8A65`, else `#1FB6F0`) · name 15 w700 (you `#0E8FC4`, row bg `#DDF3FE`) · pts JetBrains Mono 13 `#2E2E3F`. Demo: Ali Raza 2310 / You 1240 / Zara Ahmed 980 / Bilal Toor 760 / Hina Sheikh 540.
- **Report tab:** hero card (primary gradient): "THIS WEEK" 11 w800 white-70 → "Your report card" Fraunces 24 white → stats ×3: "18" tasks done / "640" points / "5d" streak (value Fraunces 20 white, label 11 w600 white-70) → "7h 0m" focused / "CS-201 midterm" top goal. Below +16: Share button H 54 `#FF8A65` pill, `ios_share_rounded` 20 + "Share my week" 16 w800 white.

### 4.8 Tako Chat (tab 4)
- **Header (pad 20/8/20/12, 1px `#ECECF3` bottom):** Tako 34 + "Tako" Manrope 17 w800 + 8px `#34D399` online dot + "Your AI study buddy · focused mode" 12 w500 `#6B6B82` + `more_horiz_rounded` `#6B6B82`.
- **Bubbles (pad 20/12, gap 12, max-W 72%):** pad 16/12; radius 28 with 6 on sender corner (user: bottom-right; Tako: bottom-left). User: primary gradient + white 14 w500 lh 1.4. Tako: white + `#0F0F1A`; Tako 26 mascot left, 8 gap.
- **Nudge card:** pad 16, `#DDF3FE`, radius 28, 1px `#1FB6F0` @ 40%; `bolt_rounded` 14 + "NUDGE" 10 w800 `#0E8FC4`; body 14 w600 lh 1.4; action chips (primary gradient pill pad 16/9, 13 w700 white): "Start a session", "Remind me in 1h".
- **Typing bubble:** white radius 28 pad 16/14; 3 dots 7px `#A8A8BC`, gap 5.
- **Quick prompts (H 40 strip):** white pills 1px `#DCDCE7`, pad-H 16, 13 w600 `#2E2E3F`: "I'm stuck" · "Plan my evening" · "Motivate me" · "I want a break".
- **Input bar (pad 20/8/20/12):** pill field (hint "Message Tako…", pad 16/12) + 48px gradient circle `arrow_upward_rounded` white.
- Demo convo: Tako overdue-reading message → nudge "Your 5-day streak is alive 🔥…" → user "I'm stuck on the practice problems, can't focus" → Tako momentum reply.

### 4.9 Profile
- **BG:** bg gradient. Header: `arrow_back_rounded` + "Profile" Manrope 18 w800. List pad 20/8/20/24.
- Hero centered: avatar 88 `#FF8A65` initial Fraunces 34 white → 12 → name Fraunces 26 → email Manrope 13 w500 `#6B6B82` → 8 → mood pill `#DDF3FE` "🎯 Feeling focused" 12 w700 `#0E8FC4`.
- Stat grid 2×2 (BentoCards, gap 12): RANK → "Pro" Fraunces 22 `#1FB6F0` · POINTS → "1240" JetBrains Mono 22 `#0E8FC4` · STREAK → "7 d" Mono 22 `#FF8A65` · SHIELDS → "2" Mono 22 `#34D399`. Labels Manrope 11 w800 `#6B6B82`.
- Buttons (gap 12): "Session history" + "Reminders & notifications" (outline) · "Open admin portal" (filled, admin only) · "Sign out" (outline rose `#F472B6`).

### 4.10 Settings (Reminders)
- Header: back + "Reminders" 18 w800. Pad 20/8/20/24.
- Card 1 (pad 8/4): switch row "Daily plan reminder" 15 w700 + "A nudge each day to plan with Taskko" 12 w500 `#6B6B82`; ON track `#1FB6F0`. When ON: "Reminder time" 14 w600 + pill `#DDF3FE` "9:30 AM" JetBrains Mono 14 `#0E8FC4`.
- Card 2: "Streak saver" + "Evening nudge (8 PM) so you never break your streak 🔥"; ON track `#FF8A65`.
- Footer: "Break reminders appear automatically after each focus session." 12 w500 `#A8A8BC`.

### 4.11 Focus Timer (3 phases)
- **BG:** bg gradient, pad 20.
- **Setup:** `close_rounded` + "Focus session" 18 w800 → "NEXT UP" 11 w800 `#1FB6F0` → task title Fraunces 26 → "How long do you want to focus?" 14 w600 `#6B6B82` → duration chips (1/10/15/20/25/45 min; pad 20/12, selection chip spec, label 14 w700) → PrimaryButton "Start now" + `play_arrow_rounded`.
- **Running:** title Manrope 16 w700 top → ring 240×240 stroke 12 (`#1FB6F0` on `#ECECF3`) with "18:42" JetBrains Mono 48 + "stay with it"/"paused" 13 w600 `#6B6B82` → controls: "Pause"/"Resume" (filled) + "Give up" (outline `#F472B6`).
- **Done:** `celebration_rounded` 56 `#34D399` → "Session complete!" Fraunces 28 → "Mind-refresh music is playing 🎶 Take a breather." 14 w500 `#6B6B82` → joke card (`#FFF1C9`): "😄 A joke to refresh you" 12 w800 `#2E2E3F` + joke 15 w500 lh 1.4 → "How did that go?" 13 w700 `#6B6B82` → 3 emoji chips 52×52 circles 😫 😐 😀 (selected: `#DDF3FE` + 2px `#1FB6F0`) → PrimaryButton "Mark "…" done +50" + check → "Not yet — just stop the music" (outline).

### 4.12 History
- Header: back + "Your focus history" 18 w800. Pad 20/8/20/24.
- Stat cards ×2 (gap 12): "3h 45m" / "Total focus" and "12" / "Sessions" — value Fraunces 24 `#0E8FC4`, label 12 w600 `#6B6B82`.
- Chart card: "LAST 7 DAYS · focus minutes" 11 w800 `#6B6B82` → 130px chart, 7 bars (gradient fill, zero-day `#DCDCE7`, radius 6) + minute labels JetBrains Mono 10 + day letters M T W T F S S Manrope 11 w700 `#6B6B82`.
- "RECENT SESSIONS" → tiles (pad 12, gap 8): mood emoji 20 + title 14 w700 + "25 min · 11/6 14:30" 12 w500 `#6B6B82` + rating emoji 18. Empty: "No sessions yet — start a focus session!".

### 4.13 Quiz (4 phases)
- **Input:** `close_rounded` + "Quiz me" 18 w800 → "What do you want to be quizzed on?" Fraunces 24 → field (hint "e.g. Binary search trees") → "QUESTIONS" 11 w800 + chips 3/5/10 → "DIFFICULTY" + chips easy/medium/hard (pad 16/8, 13 w700) → PrimaryButton "Generate quiz" + `auto_awesome_rounded`.
- **Loading:** Tako 72 + "Writing your quiz…" Fraunces 20.
- **Taking:** "Question 2 of 5" 12 w700 `#6B6B82` → bar H 6 pill (`#1FB6F0`/`#ECECF3`) → question Fraunces 22 → options (pad 16, radius 24, gap 8; selected `#DDF3FE` + 1.6px `#1FB6F0`; text 15 w600) → "Next"/"See results" (disabled until selection).
- **Result:** "4/5" Fraunces 44 `#0E8FC4` centered + "You scored 80%" 14 w600 `#6B6B82` → review tiles: `check_circle_rounded` 18 `#34D399` / `cancel_rounded` 18 `#F472B6` + question 14 w700 + "Answer: O(log n)" 13 w700 `#34D399` (+ "You picked: O(n)" 12 w500 `#6B6B82`) → "New quiz" + `refresh_rounded`.

### 4.14 Plan My Day
- Header: back + "Your day, planned" 18 w800. List pad 20/12/20/24, gap 8.
- Block rows: time col W 92 "09:00–09:25" JetBrains Mono 12 `#6B6B82` + card pad 12 — task: white, `bolt_rounded` 16 `#1FB6F0`; break: `#D6F5E6`, `coffee_rounded` 16 `#34D399`; title 14 w700.
- States: loading spinner · error "Could not build a plan right now." + Retry · empty "Add some tasks first, then plan your day.".

### 4.15 Admin Entry
- Centered (pad 24): pill `#DDF3FE` "M8 · FR-11 · React on Vercel" JetBrains Mono 12 `#0E8FC4` → "Admin portal" Fraunces 26 → "Coming in this milestone." 14 w500 `#6B6B82` → SecondaryButton "Back to student app".

---

## 5. Material icons used (full list)

`check_rounded` `arrow_forward_rounded` `arrow_back_rounded` `close_rounded`
`visibility_rounded` `visibility_off_rounded` `shield_outlined` `shield_rounded`
`notifications_none_rounded` `local_fire_department_rounded` `emoji_events_rounded`
`bolt_rounded` `schedule_rounded` `play_arrow_rounded` `celebration_rounded`
`auto_awesome_rounded` `refresh_rounded` `add_rounded` `edit_outlined`
`ios_share_rounded` `lock_rounded` `more_horiz_rounded` `arrow_upward_rounded`
`check_circle_rounded` `cancel_rounded` `coffee_rounded` `home_rounded`
`adjust_rounded` `cloud_off_rounded`

---

## 6. Reference assets in this repo

| Asset | Where |
|-------|-------|
| Rendered PNGs of the original 8 screens (+ splash & onboarding) | `design_reference/project/frames/*.png` |
| Prototype source (exact CSS) | `design_reference/project/*.jsx`, `capture-frames.html` |
| Requirements + tokens | `docs/SRS.md` (§3, §7, §8) |
| Implemented theme (authoritative) | `lib/theme/app_colors.dart`, `app_typography.dart`, `app_radii.dart` |
| Screen code (source of this spec) | `lib/features/*/view/`, `lib/widgets/` |
| App icon | `assets/icon/taskko_icon*.png` |

## 7. Figma file structure

1. **Cover** — Taskko, team, course.
2. **Foundations** — color variables (§2.1), gradients, text styles (§2.4), radii/spacing, logo + Tako mascot.
3. **Components** — everything in §3 with variants (buttons, cards, chips, fields, tab bar, checkboxes, pills, bubbles, badges).
4. **Screens** — 402×874 frames. Row 1: pre-auth + main tabs + profile stack. Row 2 (y=950): Quiz Input → Generating → Result · Focus Setup → Done · Hub Squad · Hub Report card. Also: Focus Running + Quiz Taking on row 1.
5. **Prototype wiring** — splash → onboarding → signup ↔ login → home; tab bar links; Home → Quiz Input → Generating → Taking → Result; Home → Focus Setup → Running → Done; Hub tabs: Badges ↔ Squad ↔ Report card; Profile → Settings/History.
