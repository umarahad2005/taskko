/**
 * components/AdminLayout.tsx — admin shell: dark sidebar + content area + a top
 * bar action linking to the student app (FR-11.2 "Switch to student app").
 *
 * Renders the active section. Section state lives here so the sidebar and the
 * "Switch to student app" link stay in sync.
 */
import React, { useState } from 'react';
import { tokens as t } from '../lib/theme';
import { Icon } from './Icon';
import { Sidebar, type SectionKey } from './Sidebar';
import { DashboardSection } from './sections/DashboardSection';
import { UsersSection } from './sections/UsersSection';
import { ModerationSection } from './sections/ModerationSection';
import { AiInsightsSection } from './sections/AiInsightsSection';
import { RevenueSection } from './sections/RevenueSection';
import { SettingsSection } from './sections/SettingsSection';

interface AdminLayoutProps {
  adminName: string;
  adminEmail: string;
  onSignOut: () => void;
}

// The student app lives separately; override at build time if needed.
const STUDENT_APP_URL = process.env.NEXT_PUBLIC_STUDENT_APP_URL || '#';

export function AdminLayout({ adminName, adminEmail, onSignOut }: AdminLayoutProps) {
  const [tab, setTab] = useState<SectionKey>('dashboard');

  const sections: Record<SectionKey, React.ReactNode> = {
    dashboard: <DashboardSection />,
    users: <UsersSection />,
    moderation: <ModerationSection />,
    ai: <AiInsightsSection />,
    revenue: <RevenueSection />,
    settings: <SettingsSection />,
  };

  return (
    <div
      style={{
        display: 'flex',
        minHeight: '100vh',
        width: '100%',
        background: t.bg,
        fontFamily: t.fontUi,
        color: t.ink,
      }}
    >
      <Sidebar
        tab={tab}
        setTab={setTab}
        adminName={adminName}
        adminEmail={adminEmail}
        onSignOut={onSignOut}
      />

      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column' }}>
        {/* Slim global top bar with the "Switch to student app" link (FR-11.2) */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'flex-end',
            alignItems: 'center',
            gap: 10,
            padding: '10px 28px',
            background: t.surface,
            borderBottom: `1px solid ${t.line}`,
          }}
        >
          <a
            href={STUDENT_APP_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="tap"
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 7,
              border: `1px solid ${t.line}`,
              background: t.surfaceTint,
              color: t.primaryDeep,
              padding: '7px 14px',
              borderRadius: 10,
              fontSize: 12.5,
              fontWeight: 700,
              textDecoration: 'none',
            }}
          >
            <Icon name="external" size={14} /> Switch to student app
          </a>
        </div>

        <div style={{ flex: 1, overflow: 'auto' }}>{sections[tab]}</div>
      </div>
    </div>
  );
}

export default AdminLayout;
