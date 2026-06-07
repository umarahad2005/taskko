/**
 * lib/theme.ts — Taskko design tokens (SRS §7.2) for the admin web UI.
 *
 * Shared, typed colour/typography constants so every admin component pulls from
 * one source of truth. Values mirror the approved prototype exactly.
 */

export const tokens = {
  // Primary (sky blue)
  primary: '#1FB6F0',
  primaryDeep: '#0E8FC4',
  primarySoft: '#DDF3FE',

  // Energy / streak (peach)
  energy: '#FF8A65',
  energyDeep: '#F26B47',
  energySoft: '#FFE6DD',

  // Success / done (mint)
  mint: '#34D399',
  mintDeep: '#10B981',
  mintSoft: '#D6F5E6',

  // Accents
  gold: '#F5C544',
  rose: '#F472B6',
  lavender: '#C7B8FF',
  purple: '#A855F7',

  // Ink (text)
  ink: '#0F0F1A',
  ink2: '#2E2E3F',
  ink3: '#6B6B82',
  ink4: '#A8A8BC',

  // Lines / surface
  line: '#ECECF3',
  line2: '#DCDCE7',
  surface: '#FFFFFF',
  surfaceSoft: '#F4F6FA',
  surfaceTint: '#F7FBFD',
  bg: '#FAFBFD',

  // Dark sidebar (admin console)
  sidebarBg: '#0F1B26',
  sidebarText: '#E6F2F8',
  sidebarMuted: '#7BB3CB',
  sidebarLabel: '#5B7B8E',

  // Fonts (SRS §7.2)
  fontUi: "Manrope, system-ui, -apple-system, 'Segoe UI', sans-serif",
  fontDisplay: "Fraunces, Georgia, serif",
  fontMono: "'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, monospace",
} as const;

export type Tokens = typeof tokens;
