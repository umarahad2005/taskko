/**
 * ModerationSection — severity-filtered queue with dismiss / warn / suspend
 * actions (FR-11.5). GET/POST /api/admin/moderation.
 */
import React, { useState } from 'react';
import { api, ApiError } from '../../lib/apiClient';
import { useApi } from '../../lib/useApi';
import type { ModerationItem, Severity, ModerationAction } from '../../lib/adminTypes';
import { tokens as t } from '../../lib/theme';
import { AdminTopBar, LoadingState, ErrorState, EmptyState } from '../ui';
import { Icon } from '../Icon';

const SEVERITY_TONE: Record<ModerationItem['severity'], string> = {
  high: t.energyDeep,
  medium: t.gold,
  low: t.mint,
};

const SEVERITY_SOFT: Record<ModerationItem['severity'], string> = {
  high: t.energySoft,
  medium: '#FFF5D1',
  low: t.mintSoft,
};

const FILTERS: { k: Severity; label: string }[] = [
  { k: 'all', label: 'All' },
  { k: 'high', label: 'High' },
  { k: 'medium', label: 'Medium' },
  { k: 'low', label: 'Low' },
];

const STATUS_LABEL: Record<ModerationItem['status'], string> = {
  open: 'Open',
  dismissed: 'Dismissed',
  warned: 'Warned',
  suspended: 'Suspended',
};

export function ModerationSection() {
  const [severity, setSeverity] = useState<Severity>('all');
  const { data, loading, error, retryable, reload } = useApi(
    () => api.get<{ items: ModerationItem[] }>('/api/admin/moderation', { severity }),
    [severity],
  );

  // Local overlay so a resolved item updates immediately after the POST.
  const [resolved, setResolved] = useState<Record<string, ModerationItem['status']>>({});
  const [busy, setBusy] = useState<string | null>(null);

  const items = (data?.items ?? []).map((i) =>
    resolved[i.id] ? { ...i, status: resolved[i.id] } : i,
  );

  async function act(item: ModerationItem, action: ModerationAction) {
    setBusy(item.id + action);
    try {
      const res = await api.post<{ item: ModerationItem }>('/api/admin/moderation', {
        itemId: item.id,
        action,
      });
      setResolved((r) => ({ ...r, [item.id]: res.item.status }));
    } catch (err) {
      const msg = err instanceof ApiError ? err.message : 'Action failed';
      // eslint-disable-next-line no-alert
      alert(msg);
    } finally {
      setBusy(null);
    }
  }

  const highCount = items.filter((i) => i.severity === 'high').length;

  return (
    <div>
      <AdminTopBar
        title="Moderation queue"
        subtitle={data ? `${items.length} items · ${highCount} high severity` : 'Review reported content'}
      />
      <div style={{ padding: '18px 28px 28px' }}>
        <div style={{ display: 'flex', gap: 6, marginBottom: 14 }}>
          {FILTERS.map((f) => {
            const active = severity === f.k;
            const tone = f.k === 'all' ? t.ink3 : SEVERITY_TONE[f.k as ModerationItem['severity']];
            return (
              <button
                key={f.k}
                onClick={() => setSeverity(f.k)}
                className="tap"
                style={{
                  border: active ? `1.5px solid ${tone}` : `1px solid ${t.line}`,
                  background: active ? `${tone}15` : t.surface,
                  color: active ? tone : t.ink2,
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

        {loading && <LoadingState label="Loading moderation queue…" />}
        {error && !loading && <ErrorState message={error} retryable={retryable} onRetry={reload} />}
        {!loading && !error && items.length === 0 && <EmptyState message="Queue is clear — nothing to review." />}

        {!loading && !error && items.length > 0 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {items.map((r) => {
              const tone = SEVERITY_TONE[r.severity];
              const isResolved = r.status !== 'open';
              return (
                <div
                  key={r.id}
                  style={{
                    background: t.surface,
                    border: `1px solid ${t.line}`,
                    borderRadius: 14,
                    padding: '14px 18px',
                    borderLeft: `4px solid ${tone}`,
                    opacity: isResolved ? 0.65 : 1,
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14 }}>
                    <div
                      style={{
                        width: 38,
                        height: 38,
                        borderRadius: 10,
                        background: SEVERITY_SOFT[r.severity],
                        color: tone,
                        display: 'grid',
                        placeItems: 'center',
                        flexShrink: 0,
                      }}
                    >
                      <Icon name="flag" size={18} />
                    </div>

                    <div style={{ flex: 1, minWidth: 0 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                        <span
                          style={{
                            fontSize: 10,
                            fontWeight: 800,
                            padding: '2px 7px',
                            borderRadius: 5,
                            background: tone,
                            color: '#fff',
                            letterSpacing: 0.4,
                            textTransform: 'uppercase',
                          }}
                        >
                          {r.severity}
                        </span>
                        <span style={{ fontSize: 11.5, color: t.ink3 }}>
                          target <b style={{ color: t.ink }}>{r.targetUser}</b>
                        </span>
                        {isResolved && (
                          <span
                            style={{
                              fontSize: 10.5,
                              fontWeight: 800,
                              color: t.mintDeep,
                              background: t.mintSoft,
                              padding: '2px 8px',
                              borderRadius: 99,
                              textTransform: 'uppercase',
                              letterSpacing: 0.4,
                            }}
                          >
                            {STATUS_LABEL[r.status]}
                          </span>
                        )}
                        <span className="mono" style={{ fontSize: 10.5, color: t.ink4, marginLeft: 'auto' }}>
                          {new Date(r.createdAt).toLocaleString()}
                        </span>
                      </div>
                      <div style={{ fontSize: 14, fontWeight: 700, color: t.ink, marginTop: 8 }}>{r.reason}</div>
                    </div>

                    {!isResolved && (
                      <div style={{ display: 'flex', gap: 6, flexShrink: 0 }}>
                        <button
                          disabled={busy === r.id + 'dismiss'}
                          onClick={() => act(r, 'dismiss')}
                          className="tap"
                          style={{
                            border: 'none',
                            background: t.mintDeep,
                            color: '#fff',
                            padding: '8px 14px',
                            borderRadius: 9,
                            fontSize: 12,
                            fontWeight: 700,
                            cursor: 'pointer',
                          }}
                        >
                          Dismiss
                        </button>
                        <button
                          disabled={busy === r.id + 'warn'}
                          onClick={() => act(r, 'warn')}
                          className="tap"
                          style={{
                            border: `1px solid ${t.line}`,
                            background: t.surface,
                            color: t.ink2,
                            padding: '8px 14px',
                            borderRadius: 9,
                            fontSize: 12,
                            fontWeight: 700,
                            cursor: 'pointer',
                          }}
                        >
                          Warn
                        </button>
                        <button
                          disabled={busy === r.id + 'suspend'}
                          onClick={() => act(r, 'suspend')}
                          className="tap"
                          style={{
                            border: `1px solid ${t.energyDeep}`,
                            background: t.energySoft,
                            color: t.energyDeep,
                            padding: '8px 14px',
                            borderRadius: 9,
                            fontSize: 12,
                            fontWeight: 700,
                            cursor: 'pointer',
                          }}
                        >
                          Suspend
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

export default ModerationSection;
