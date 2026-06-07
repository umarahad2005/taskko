/**
 * components/Icon.tsx — small inline SVG icon set used across the admin UI.
 *
 * Mirrors the prototype's `<Icon name=... size=... />` API so ported markup
 * works unchanged. Stroke-style icons (Feather-like) keep the visual language.
 */
import React from 'react';

export type IconName =
  | 'home'
  | 'users'
  | 'shield'
  | 'sparkles'
  | 'trophy'
  | 'edit'
  | 'back'
  | 'bell'
  | 'info'
  | 'search'
  | 'plus'
  | 'share'
  | 'close'
  | 'dots'
  | 'fire'
  | 'flag'
  | 'check'
  | 'chat'
  | 'medal'
  | 'refresh'
  | 'logout'
  | 'external';

interface IconProps {
  name: IconName;
  size?: number;
  color?: string;
  stroke?: number;
}

const PATHS: Record<IconName, React.ReactNode> = {
  home: <path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z" />,
  users: (
    <>
      <circle cx="9" cy="8" r="3.2" />
      <path d="M3.5 20a5.5 5.5 0 0 1 11 0" />
      <path d="M16 5.2a3 3 0 0 1 0 5.6M21 20a5 5 0 0 0-4-4.9" />
    </>
  ),
  shield: <path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z" />,
  sparkles: (
    <>
      <path d="M12 3l1.6 4.4L18 9l-4.4 1.6L12 15l-1.6-4.4L6 9l4.4-1.6z" />
      <path d="M18 14l.8 2.2L21 17l-2.2.8L18 20l-.8-2.2L15 17l2.2-.8z" />
    </>
  ),
  trophy: (
    <>
      <path d="M7 4h10v4a5 5 0 0 1-10 0z" />
      <path d="M7 5H4v2a3 3 0 0 0 3 3M17 5h3v2a3 3 0 0 1-3 3M9 20h6M12 13v4" />
    </>
  ),
  edit: <path d="M4 20h4L19 9l-4-4L4 16zM14 6l4 4" />,
  back: <path d="M15 18l-6-6 6-6" />,
  bell: <path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6M10 20a2 2 0 0 0 4 0" />,
  info: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 11v5M12 8h.01" />
    </>
  ),
  search: (
    <>
      <circle cx="11" cy="11" r="7" />
      <path d="m20 20-3.5-3.5" />
    </>
  ),
  plus: <path d="M12 5v14M5 12h14" />,
  share: <path d="M4 12v7a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1v-7M16 6l-4-4-4 4M12 2v13" />,
  close: <path d="M6 6l12 12M18 6 6 18" />,
  dots: (
    <>
      <circle cx="5" cy="12" r="1.4" />
      <circle cx="12" cy="12" r="1.4" />
      <circle cx="19" cy="12" r="1.4" />
    </>
  ),
  fire: <path d="M12 3c1 3-2 4-2 7a2 2 0 0 0 4 0c0-.5-.2-1-.4-1.4C16 11 17 13 17 15a5 5 0 0 1-10 0c0-4 3-5 5-12z" />,
  flag: <path d="M5 21V4M5 4h11l-2 4 2 4H5" />,
  check: <path d="M5 12l5 5L19 7" />,
  chat: <path d="M4 5h16v11H8l-4 4z" />,
  medal: (
    <>
      <circle cx="12" cy="14" r="5" />
      <path d="M9 9 7 3h10l-2 6" />
    </>
  ),
  refresh: <path d="M4 12a8 8 0 0 1 13.7-5.6L20 8M20 4v4h-4M20 12a8 8 0 0 1-13.7 5.6L4 16M4 20v-4h4" />,
  logout: <path d="M9 21H5a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h4M16 17l5-5-5-5M21 12H9" />,
  external: <path d="M14 4h6v6M20 4l-9 9M19 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h5" />,
};

export function Icon({ name, size = 18, color = 'currentColor', stroke = 1.9 }: IconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke={color}
      strokeWidth={stroke}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {PATHS[name]}
    </svg>
  );
}

export default Icon;
