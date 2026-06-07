/**
 * components/Sidebar.tsx — dark left rail for the admin console (FR-11.2).
 *
 * Six sections + brand + signed-in admin card + sign-out. Ported from
 * design_reference/project/admin-sidebar.jsx (dark navy, sky-blue active state).
 */
import React from 'react';
import { tokens as t } from '../lib/theme';
import { Icon, type IconName } from './Icon';

export type SectionKey = 'dashboard' | 'users' | 'moderation' | 'ai' | 'revenue' | 'settings';

interface NavItem {
  k: SectionKey;
  label: string;
  icon: IconName;
  badge?: string | null;
}

export const ADMIN_NAV: NavItem[] = [
  { k: 'dashboard', label: 'Dashboard', icon: 'home' },
  { k: 'users', label: 'Users', icon: 'users' },
  { k: 'moderation', label: 'Moderation', icon: 'shield', badge: '7' },
  { k: 'ai', label: 'AI insights', icon: 'sparkles' },
  { k: 'revenue', label: 'Revenue', icon: 'trophy', badge: 'NEW' },
  { k: 'settings', label: 'Settings', icon: 'edit' },
];

interface SidebarProps {
  tab: SectionKey;
  setTab: (k: SectionKey) => void;
  adminName: string;
  adminEmail: string;
  onSignOut: () => void;
}

export function Sidebar({ tab, setTab, adminName, adminEmail, onSignOut }: SidebarProps) {
  return (
    <div
      style={{
        width: 240,
        flexShrink: 0,
        background: t.sidebarBg,
        color: t.sidebarText,
        padding: '22px 14px',
        display: 'flex',
        flexDirection: 'column',
        gap: 4,
        borderRight: '1px solid rgba(255,255,255,0.06)',
        height: '100vh',
        position: 'sticky',
        top: 0,
      }}
    >
      {/* Brand */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          padding: '4px 8px 18px',
          borderBottom: '1px solid rgba(255,255,255,0.06)',
          marginBottom: 10,
        }}
      >
        <div
          style={{
            width: 34,
            height: 34,
            borderRadius: 10,
            background: 'linear-gradient(135deg, #5BCBF5, #1FB6F0, #0A6FA8)',
            display: 'grid',
            placeItems: 'center',
            color: '#fff',
            fontWeight: 800,
            fontSize: 18,
            fontFamily: 'Georgia, serif',
            boxShadow: 'inset 0 1px 0 rgba(255,255,255,0.3)',
          }}
        >
          t
        </div>
        <div>
          <div className="display" style={{ fontWeight: 700, fontSize: 16, color: '#fff' }}>
            taskko
          </div>
          <div
            style={{
              fontSize: 10,
              color: t.sidebarMuted,
              fontWeight: 700,
              letterSpacing: 1,
              textTransform: 'uppercase',
            }}
          >
            Admin Console
          </div>
        </div>
      </div>

      <div
        style={{
          fontSize: 10,
          fontWeight: 800,
          color: t.sidebarLabel,
          letterSpacing: 1.4,
          textTransform: 'uppercase',
          padding: '6px 10px 4px',
        }}
      >
        Manage
      </div>

      {ADMIN_NAV.map((n) => {
        const active = tab === n.k;
        return (
          <button
            key={n.k}
            onClick={() => setTab(n.k)}
            className="tap"
            style={{
              border: 'none',
              textAlign: 'left',
              cursor: 'pointer',
              background: active
                ? 'linear-gradient(90deg, rgba(31,182,240,0.18), rgba(31,182,240,0.05))'
                : 'transparent',
              color: active ? '#fff' : '#B4CCD8',
              padding: '10px 12px',
              borderRadius: 10,
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              fontWeight: active ? 700 : 600,
              fontSize: 13.5,
              position: 'relative',
            }}
          >
            {active && (
              <div
                style={{
                  position: 'absolute',
                  left: -14,
                  top: 8,
                  bottom: 8,
                  width: 3,
                  borderRadius: 99,
                  background: t.primary,
                }}
              />
            )}
            <span style={{ color: active ? t.primary : t.sidebarMuted, display: 'inline-flex' }}>
              <Icon name={n.icon} size={17} stroke={1.8} />
            </span>
            <span style={{ flex: 1 }}>{n.label}</span>
            {n.badge && (
              <span
                style={{
                  fontSize: 10,
                  fontWeight: 800,
                  padding: '2px 7px',
                  borderRadius: 99,
                  background:
                    n.badge === 'NEW'
                      ? t.energy
                      : n.k === 'moderation'
                      ? t.energyDeep
                      : 'rgba(91,203,245,0.18)',
                  color: n.badge === 'NEW' || n.k === 'moderation' ? '#fff' : '#5BCBF5',
                  letterSpacing: 0.4,
                }}
              >
                {n.badge}
              </span>
            )}
          </button>
        );
      })}

      <div style={{ flex: 1 }} />

      {/* Admin user card */}
      <div
        style={{
          padding: '10px 12px',
          borderRadius: 12,
          background: 'rgba(255,255,255,0.04)',
          border: '1px solid rgba(255,255,255,0.06)',
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          marginBottom: 8,
        }}
      >
        <div
          style={{
            width: 32,
            height: 32,
            borderRadius: 99,
            background: 'linear-gradient(135deg, #FFD7BC, #FF8A65)',
            display: 'grid',
            placeItems: 'center',
            color: '#fff',
            fontWeight: 800,
            fontSize: 13,
          }}
        >
          {(adminName || adminEmail || 'A')[0].toUpperCase()}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              fontSize: 12.5,
              fontWeight: 700,
              color: '#fff',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {adminName || adminEmail}
          </div>
          <div style={{ fontSize: 10.5, color: t.sidebarMuted, display: 'flex', alignItems: 'center', gap: 4 }}>
            <span style={{ width: 6, height: 6, borderRadius: 99, background: t.mint }} /> Admin
          </div>
        </div>
      </div>

      <button
        onClick={onSignOut}
        className="tap"
        style={{
          border: '1px solid rgba(255,255,255,0.1)',
          background: 'transparent',
          color: t.sidebarMuted,
          padding: '9px 12px',
          borderRadius: 10,
          fontWeight: 600,
          fontSize: 12,
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 6,
        }}
      >
        <Icon name="logout" size={14} /> Sign out
      </button>
    </div>
  );
}

export default Sidebar;
