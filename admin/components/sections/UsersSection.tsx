/**
 * UsersSection — filterable user table + profile drawer with suspend / reinstate
 * / grant-points actions (FR-11.4). GET/POST /api/admin/users.
 */
import React, { useState } from 'react';
import { api, ApiError } from '../../lib/apiClient';
import { useApi } from '../../lib/useApi';
import type { AdminUser, UserFilter, UserAction } from '../../lib/adminTypes';
import { tokens as t } from '../../lib/theme';
import { AdminTopBar, AdminPanel, LoadingState, ErrorState, EmptyState } from '../ui';
import { Icon } from '../Icon';

const FILTERS: { k: UserFilter; label: string; tone?: string }[] = [
  { k: 'all', label: 'All' },
  { k: 'pro', label: 'Pro tier', tone: t.primary },
  { k: 'free', label: 'Free tier' },
  { k: 'flagged', label: 'Flagged', tone: t.energyDeep },
  { k: 'suspended', label: 'Suspended', tone: t.purple },
];

const STATUS_COLOR: Record<AdminUser['status'], string> = {
  active: t.mintDeep,
  flagged: t.energyDeep,
  suspended: t.energyDeep,
};

export function UsersSection() {
  const [filter, setFilter] = useState<UserFilter>('all');
  const [q, setQ] = useState('');
  const [selected, setSelected] = useState<AdminUser | null>(null);

  const { data, loading, error, retryable, reload } = useApi(
    () => api.get<{ users: AdminUser[] }>('/api/admin/users', { filter, q: q || undefined }),
    [filter, q],
  );

  const users = data?.users ?? [];

  // Keep the drawer's selection in sync if the list reloads.
  const selectedLive = selected ? users.find((u) => u.id === selected.id) ?? selected : null;

  async function runAction(user: AdminUser, action: UserAction, points?: number) {
    try {
      const res = await api.post<{ user: AdminUser }>('/api/admin/users', {
        userId: user.id,
        action,
        points,
      });
      setSelected(res.user);
      reload();
    } catch (err) {
      const msg = err instanceof ApiError ? err.message : 'Action failed';
      // eslint-disable-next-line no-alert
      alert(msg);
    }
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100%' }}>
      <AdminTopBar
        title="Users"
        subtitle={data ? `${users.length.toLocaleString()} shown · filter "${filter}"` : 'Manage student accounts'}
        actions={
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              background: t.surfaceSoft,
              borderRadius: 10,
              padding: '8px 12px',
              border: `1px solid ${t.line}`,
              minWidth: 260,
            }}
          >
            <Icon name="search" size={15} color={t.ink4} />
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search name or email…"
              style={{
                border: 'none',
                outline: 'none',
                background: 'transparent',
                fontSize: 12.5,
                color: t.ink,
                flex: 1,
              }}
            />
          </div>
        }
      />

      <div style={{ padding: '18px 28px 28px', flex: 1 }}>
        {/* Filter chips */}
        <div style={{ display: 'flex', gap: 6, marginBottom: 14, flexWrap: 'wrap' }}>
          {FILTERS.map((f) => {
            const active = filter === f.k;
            return (
              <button
                key={f.k}
                onClick={() => setFilter(f.k)}
                className="tap"
                style={{
                  border: active ? `1.5px solid ${t.primary}` : `1px solid ${t.line}`,
                  background: active ? t.primarySoft : t.surface,
                  color: active ? t.primaryDeep : t.ink2,
                  padding: '7px 14px',
                  borderRadius: 99,
                  fontSize: 12.5,
                  fontWeight: 700,
                  cursor: 'pointer',
                }}
              >
                {f.label}
              </button>
            );
          })}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: selectedLive ? '1fr 320px' : '1fr', gap: 14 }}>
          <AdminPanel padding={0}>
            {loading && <LoadingState label="Loading users…" />}
            {error && !loading && <ErrorState message={error} retryable={retryable} onRetry={reload} />}
            {!loading && !error && users.length === 0 && <EmptyState message="No users match this filter." />}
            {!loading && !error && users.length > 0 && (
              <div style={{ maxHeight: 640, overflow: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
                  <thead>
                    <tr style={{ background: '#FAFBFD', position: 'sticky', top: 0 }}>
                      {['Student', 'Rank', 'Points', 'Plan', 'Status', ''].map((h) => (
                        <th
                          key={h}
                          style={{
                            textAlign: 'left',
                            padding: '10px 14px',
                            fontSize: 10.5,
                            fontWeight: 800,
                            color: t.ink3,
                            letterSpacing: 0.6,
                            textTransform: 'uppercase',
                            borderBottom: `1px solid ${t.line}`,
                          }}
                        >
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {users.map((u) => {
                      const isSel = selectedLive?.id === u.id;
                      return (
                        <tr
                          key={u.id}
                          onClick={() => setSelected(u)}
                          style={{
                            cursor: 'pointer',
                            background: isSel ? t.surfaceTint : 'transparent',
                            borderLeft: isSel ? `3px solid ${t.primary}` : '3px solid transparent',
                          }}
                        >
                          <td style={{ padding: '10px 14px', borderBottom: `1px solid ${t.surfaceSoft}` }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                              <div
                                style={{
                                  width: 30,
                                  height: 30,
                                  borderRadius: 99,
                                  background: 'linear-gradient(135deg,#FFD7BC,#FF8A65)',
                                  color: '#fff',
                                  display: 'grid',
                                  placeItems: 'center',
                                  fontWeight: 800,
                                  fontSize: 12,
                                }}
                              >
                                {u.name[0]?.toUpperCase()}
                              </div>
                              <div>
                                <div style={{ fontWeight: 700, color: t.ink }}>{u.name}</div>
                                <div style={{ fontSize: 11, color: t.ink3 }}>{u.email}</div>
                              </div>
                            </div>
                          </td>
                          <td style={{ padding: '10px 14px', borderBottom: `1px solid ${t.surfaceSoft}` }}>
                            <span
                              style={{
                                fontSize: 11,
                                fontWeight: 800,
                                color: t.primaryDeep,
                                background: t.primarySoft,
                                padding: '2px 7px',
                                borderRadius: 99,
                              }}
                            >
                              {u.rank}
                            </span>
                          </td>
                          <td
                            className="mono"
                            style={{ padding: '10px 14px', borderBottom: `1px solid ${t.surfaceSoft}`, fontWeight: 700, color: t.ink }}
                          >
                            {u.points.toLocaleString()}
                          </td>
                          <td style={{ padding: '10px 14px', borderBottom: `1px solid ${t.surfaceSoft}` }}>
                            {u.plan === 'pro' ? (
                              <span
                                style={{
                                  fontSize: 11,
                                  fontWeight: 800,
                                  color: '#fff',
                                  background: 'linear-gradient(135deg,#FF8A65,#F26B47)',
                                  padding: '3px 8px',
                                  borderRadius: 6,
                                }}
                              >
                                PRO
                              </span>
                            ) : (
                              <span style={{ fontSize: 11, fontWeight: 700, color: t.ink3, background: t.surfaceSoft, padding: '3px 8px', borderRadius: 6 }}>
                                Free
                              </span>
                            )}
                          </td>
                          <td style={{ padding: '10px 14px', borderBottom: `1px solid ${t.surfaceSoft}` }}>
                            <span
                              style={{
                                fontSize: 11.5,
                                fontWeight: 700,
                                display: 'inline-flex',
                                alignItems: 'center',
                                gap: 5,
                                color: STATUS_COLOR[u.status],
                                textTransform: 'capitalize',
                              }}
                            >
                              <span style={{ width: 7, height: 7, borderRadius: 99, background: 'currentColor' }} />
                              {u.status}
                            </span>
                          </td>
                          <td style={{ padding: '10px 14px', borderBottom: `1px solid ${t.surfaceSoft}`, textAlign: 'right' }}>
                            <Icon name="dots" size={16} color={t.ink4} />
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </AdminPanel>

          {selectedLive && (
            <UserDetailDrawer
              user={selectedLive}
              onClose={() => setSelected(null)}
              onAction={runAction}
            />
          )}
        </div>
      </div>
    </div>
  );
}

function UserDetailDrawer({
  user,
  onClose,
  onAction,
}: {
  user: AdminUser;
  onClose: () => void;
  onAction: (user: AdminUser, action: UserAction, points?: number) => void | Promise<void>;
}) {
  const [busy, setBusy] = useState<UserAction | null>(null);

  async function fire(action: UserAction, points?: number) {
    setBusy(action);
    await onAction(user, action, points);
    setBusy(null);
  }

  return (
    <div
      style={{
        background: t.surface,
        border: `1px solid ${t.line}`,
        borderRadius: 16,
        padding: 18,
        position: 'sticky',
        top: 24,
        alignSelf: 'start',
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 14 }}>
        <div style={{ fontSize: 10.5, fontWeight: 800, color: t.primaryDeep, letterSpacing: 0.6, textTransform: 'uppercase' }}>
          User profile
        </div>
        <button
          onClick={onClose}
          style={{
            border: 'none',
            background: t.surfaceSoft,
            width: 28,
            height: 28,
            borderRadius: 99,
            display: 'grid',
            placeItems: 'center',
            cursor: 'pointer',
          }}
        >
          <Icon name="close" size={14} color={t.ink3} />
        </button>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', marginBottom: 14 }}>
        <div
          style={{
            width: 64,
            height: 64,
            borderRadius: 99,
            background: 'linear-gradient(135deg,#FFD7BC,#FF8A65)',
            color: '#fff',
            display: 'grid',
            placeItems: 'center',
            fontWeight: 800,
            fontSize: 24,
            boxShadow: '0 8px 20px -8px rgba(255,138,101,0.55)',
          }}
        >
          {user.name[0]?.toUpperCase()}
        </div>
        <div className="display" style={{ fontWeight: 700, fontSize: 20, color: t.ink, marginTop: 8 }}>
          {user.name}
        </div>
        <div style={{ fontSize: 12, color: t.ink3, marginTop: 1 }}>{user.email}</div>
        <div
          style={{
            marginTop: 8,
            display: 'inline-flex',
            alignItems: 'center',
            gap: 4,
            background: t.primarySoft,
            color: t.primaryDeep,
            padding: '3px 10px',
            borderRadius: 99,
            fontSize: 11,
            fontWeight: 800,
          }}
        >
          <Icon name="trophy" size={11} /> {user.rank} · {user.points.toLocaleString()} pts
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 14 }}>
        {[
          { l: 'Plan', v: user.plan, c: t.primary },
          { l: 'Status', v: user.status, c: STATUS_COLOR[user.status] },
        ].map((s) => (
          <div key={s.l} style={{ background: t.surfaceTint, borderRadius: 10, padding: '8px 10px' }}>
            <div style={{ fontSize: 10, fontWeight: 800, color: t.ink3, letterSpacing: 0.4, textTransform: 'uppercase' }}>
              {s.l}
            </div>
            <div style={{ fontSize: 14, fontWeight: 800, color: s.c, marginTop: 1, textTransform: 'capitalize' }}>{s.v}</div>
          </div>
        ))}
      </div>

      <div style={{ borderTop: `1px solid ${t.line}`, marginTop: 4, paddingTop: 12, display: 'flex', flexDirection: 'column', gap: 6 }}>
        <button
          disabled={!!busy}
          onClick={() => fire('grant_points', 100)}
          className="tap"
          style={{
            border: `1px solid ${t.line}`,
            background: t.surface,
            color: t.ink,
            padding: '9px 12px',
            borderRadius: 10,
            fontSize: 12.5,
            fontWeight: 700,
            cursor: 'pointer',
          }}
        >
          {busy === 'grant_points' ? 'Granting…' : 'Grant 100 bonus pts'}
        </button>
        {user.status === 'suspended' ? (
          <button
            disabled={!!busy}
            onClick={() => fire('reinstate')}
            className="tap"
            style={{
              border: 'none',
              background: t.mintDeep,
              color: '#fff',
              padding: '9px 12px',
              borderRadius: 10,
              fontSize: 12.5,
              fontWeight: 700,
              cursor: 'pointer',
            }}
          >
            {busy === 'reinstate' ? 'Reinstating…' : 'Reinstate account'}
          </button>
        ) : (
          <button
            disabled={!!busy}
            onClick={() => fire('suspend')}
            className="tap"
            style={{
              border: `1px solid ${t.energyDeep}`,
              background: t.energySoft,
              color: t.energyDeep,
              padding: '9px 12px',
              borderRadius: 10,
              fontSize: 12.5,
              fontWeight: 700,
              cursor: 'pointer',
            }}
          >
            {busy === 'suspend' ? 'Suspending…' : 'Suspend account'}
          </button>
        )}
      </div>
    </div>
  );
}

export default UsersSection;
