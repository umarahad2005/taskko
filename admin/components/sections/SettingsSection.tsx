/**
 * SettingsSection — feature-flag toggles + admin team (FR-11.8).
 * GET/PATCH /api/admin/settings.
 */
import React, { useEffect, useState } from 'react';
import { api, ApiError } from '../../lib/apiClient';
import { useApi } from '../../lib/useApi';
import type { AdminSettings } from '../../lib/adminTypes';
import { tokens as t } from '../../lib/theme';
import { AdminTopBar, AdminPanel, LoadingState, ErrorState } from '../ui';
import { Icon } from '../Icon';

// Human-readable labels for known flag keys (falls back to the raw key).
const FLAG_LABELS: Record<string, { label: string; desc: string }> = {
  aiBreakdownEnabled: { label: 'AI goal breakdown', desc: 'Let students break goals into tasks with Tako.' },
  socialSharingEnabled: { label: 'Social sharing', desc: 'Share report cards and badges to socials.' },
  moodCheckInEnabled: { label: 'Mood-aware sessions', desc: 'Mood picker rewrites the next session length.' },
  squadLeaderboardEnabled: { label: 'Squad leaderboards', desc: 'Show the weekly squad leaderboard in the Hub.' },
  maintenanceMode: { label: 'Maintenance mode', desc: 'Show a maintenance notice and pause writes.' },
};

const ROLE_TONE: Record<string, string> = { owner: t.primary, admin: t.energy };

export function SettingsSection() {
  const { data, loading, error, retryable, reload } = useApi<AdminSettings>(
    () => api.get<AdminSettings>('/api/admin/settings'),
    [],
  );

  const [flags, setFlags] = useState<Record<string, boolean>>({});
  const [saving, setSaving] = useState<string | null>(null);
  const [saveError, setSaveError] = useState<string | null>(null);

  useEffect(() => {
    if (data) setFlags(data.flags);
  }, [data]);

  async function toggle(key: string) {
    const next = { ...flags, [key]: !flags[key] };
    setFlags(next); // optimistic
    setSaving(key);
    setSaveError(null);
    try {
      const res = await api.patch<AdminSettings>('/api/admin/settings', { flags: { [key]: next[key] } });
      setFlags(res.flags);
    } catch (err) {
      setFlags(flags); // revert
      setSaveError(err instanceof ApiError ? err.message : 'Could not save flag');
    } finally {
      setSaving(null);
    }
  }

  return (
    <div>
      <AdminTopBar title="Settings" subtitle="Feature flags, default behaviour, and admin team" />
      <div style={{ padding: '18px 28px 28px' }}>
        {loading && <LoadingState label="Loading settings…" />}
        {error && !loading && <ErrorState message={error} retryable={retryable} onRetry={reload} />}

        {data && !loading && !error && (
          <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 14 }}>
            <AdminPanel title="Feature flags" subtitle="Toggles affect the live mobile app immediately">
              {saveError && (
                <div
                  style={{
                    fontSize: 12,
                    fontWeight: 700,
                    color: t.energyDeep,
                    background: t.energySoft,
                    padding: '8px 12px',
                    borderRadius: 8,
                    marginBottom: 8,
                  }}
                >
                  {saveError}
                </div>
              )}
              <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                {Object.keys(flags).map((key) => {
                  const meta = FLAG_LABELS[key] ?? { label: key, desc: '' };
                  const on = flags[key];
                  return (
                    <div
                      key={key}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 14,
                        padding: '12px 6px',
                        borderBottom: `1px solid ${t.surfaceSoft}`,
                      }}
                    >
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 13.5, fontWeight: 700, color: t.ink }}>{meta.label}</div>
                        {meta.desc && <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 1 }}>{meta.desc}</div>}
                      </div>
                      <button
                        onClick={() => toggle(key)}
                        disabled={saving === key}
                        aria-pressed={on}
                        style={{
                          width: 42,
                          height: 24,
                          borderRadius: 99,
                          background: on ? t.primary : t.line2,
                          border: 'none',
                          position: 'relative',
                          cursor: 'pointer',
                          transition: 'background .2s',
                          opacity: saving === key ? 0.6 : 1,
                          flexShrink: 0,
                        }}
                      >
                        <div
                          style={{
                            position: 'absolute',
                            top: 2,
                            left: on ? 20 : 2,
                            width: 20,
                            height: 20,
                            borderRadius: 99,
                            background: '#fff',
                            transition: 'left .2s',
                            boxShadow: '0 1px 3px rgba(0,0,0,0.15)',
                          }}
                        />
                      </button>
                    </div>
                  );
                })}
              </div>
            </AdminPanel>

            <AdminPanel title="Admin team" subtitle={`${data.adminTeam.length} member${data.adminTeam.length === 1 ? '' : 's'}`}>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {data.adminTeam.map((a) => {
                  const tone = ROLE_TONE[a.role] ?? t.purple;
                  return (
                    <div
                      key={a.email}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 10,
                        padding: '10px 12px',
                        borderRadius: 10,
                        background: t.surface,
                        border: `1px solid ${t.line}`,
                      }}
                    >
                      <div
                        style={{
                          width: 32,
                          height: 32,
                          borderRadius: 99,
                          background: `linear-gradient(135deg, ${tone}, ${tone}AA)`,
                          color: '#fff',
                          display: 'grid',
                          placeItems: 'center',
                          fontWeight: 800,
                          fontSize: 12,
                        }}
                      >
                        {a.email[0].toUpperCase()}
                      </div>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ fontSize: 12.5, fontWeight: 700, color: t.ink, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                          {a.email}
                        </div>
                      </div>
                      <span
                        style={{
                          fontSize: 11,
                          fontWeight: 700,
                          color: tone,
                          background: `${tone}15`,
                          padding: '3px 8px',
                          borderRadius: 99,
                          textTransform: 'capitalize',
                        }}
                      >
                        {a.role}
                      </span>
                    </div>
                  );
                })}
              </div>
              <button
                disabled
                title="Admin team editing arrives in M9"
                style={{
                  marginTop: 12,
                  width: '100%',
                  border: `1px dashed ${t.line2}`,
                  background: 'transparent',
                  color: t.ink3,
                  padding: 10,
                  borderRadius: 10,
                  fontSize: 12.5,
                  fontWeight: 700,
                  cursor: 'not-allowed',
                  display: 'inline-flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 6,
                  opacity: 0.7,
                }}
              >
                <Icon name="plus" size={14} /> Invite admin (M9)
              </button>
            </AdminPanel>
          </div>
        )}
      </div>
    </div>
  );
}

export default SettingsSection;
