/**
 * AiInsightsSection — Gemini usage / cost / quality, stuck phrases, and a live
 * prompt feed (FR-11.6). GET /api/admin/ai-insights.
 */
import React from 'react';
import { api } from '../../lib/apiClient';
import { useApi } from '../../lib/useApi';
import type { AiInsights } from '../../lib/adminTypes';
import { tokens as t } from '../../lib/theme';
import { AdminTopBar, AdminPanel, StatCard, LoadingState, ErrorState, GhostButton } from '../ui';
import { Icon } from '../Icon';

const QUALITY_COLORS = [t.mintDeep, t.primary, t.gold, t.purple];

export function AiInsightsSection() {
  const { data, loading, error, retryable, reload } = useApi<AiInsights>(
    () => api.get<AiInsights>('/api/admin/ai-insights'),
    [],
  );

  return (
    <div>
      <AdminTopBar
        title="AI insights"
        subtitle="Gemini usage, Tako quality, and prompt patterns"
        actions={
          <GhostButton onClick={reload}>
            <Icon name="refresh" size={14} /> Refresh
          </GhostButton>
        }
      />
      <div style={{ padding: '18px 28px 28px', display: 'flex', flexDirection: 'column', gap: 18 }}>
        {loading && <LoadingState label="Loading AI insights…" />}
        {error && !loading && <ErrorState message={error} retryable={retryable} onRetry={reload} />}

        {data && !loading && !error && (
          <>
            {/* Usage / cost cards */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
              <StatCard label="Gemini calls today" value={data.usage.callsToday.toLocaleString()} delta="today" deltaTone="flat" accent={t.primary} />
              <StatCard label="Calls (7 days)" value={data.usage.calls7d.toLocaleString()} delta="7d" deltaTone="flat" accent="#5BCBF5" />
              <StatCard label="Avg latency" value={`${(data.usage.avgLatencyMs / 1000).toFixed(2)}s`} delta="per call" deltaTone="flat" accent={t.mint} />
              <StatCard
                label="Fallback rate"
                value={`${(data.usage.fallbackRate * 100).toFixed(1)}%`}
                delta="of calls"
                deltaTone={data.usage.fallbackRate > 0.05 ? 'down' : 'flat'}
                accent={t.energy}
              />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 14 }}>
              <StatCard label="Cost today" value={`$${data.costUsd.today.toFixed(2)}`} delta="estimated" deltaTone="flat" accent={t.energy} />
              <StatCard label="Cost this month" value={`$${data.costUsd.month.toFixed(2)}`} delta="month to date" deltaTone="flat" accent={t.purple} />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 14 }}>
              {/* Quality per feature */}
              <AdminPanel title="Tako quality by feature" subtitle="Good responses vs fallback rate">
                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                  {data.quality.map((qf, i) => (
                    <div key={qf.feature}>
                      <div
                        style={{
                          display: 'flex',
                          justifyContent: 'space-between',
                          fontSize: 12.5,
                          fontWeight: 700,
                          color: t.ink2,
                          marginBottom: 4,
                        }}
                      >
                        <span style={{ textTransform: 'capitalize' }}>{qf.feature}</span>
                        <span className="mono" style={{ color: t.ink3 }}>
                          {Math.round(qf.good * 100)}% good · {Math.round(qf.fallback * 100)}% fallback
                        </span>
                      </div>
                      <div style={{ height: 8, background: t.surfaceSoft, borderRadius: 99, overflow: 'hidden' }}>
                        <div
                          style={{
                            width: `${qf.good * 100}%`,
                            height: '100%',
                            background: QUALITY_COLORS[i % QUALITY_COLORS.length],
                            borderRadius: 99,
                          }}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </AdminPanel>

              {/* Stuck phrases */}
              <AdminPanel title="Where students get stuck" subtitle="Phrases triggering 'I'm stuck' nudges">
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {data.stuckPhrases.map((p, i) => (
                    <div
                      key={p}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 10,
                        padding: '8px 10px',
                        borderRadius: 9,
                        background: i === 0 ? '#FFF5EC' : 'transparent',
                      }}
                    >
                      <div className="mono" style={{ fontSize: 10.5, fontWeight: 800, color: t.ink4, width: 22 }}>
                        {String(i + 1).padStart(2, '0')}
                      </div>
                      <div className="mono" style={{ flex: 1, fontSize: 12.5, color: t.ink }}>
                        &ldquo;{p}&rdquo;
                      </div>
                    </div>
                  ))}
                </div>
              </AdminPanel>
            </div>

            {/* Recent prompts */}
            <AdminPanel
              title="Recent prompts"
              subtitle="Sampled live from anonymised users"
              action={
                <span style={{ fontSize: 11, fontWeight: 700, color: t.mintDeep, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                  <span style={{ width: 8, height: 8, borderRadius: 99, background: t.mintDeep }} /> Streaming
                </span>
              }
            >
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
                {data.recentPrompts.map((p, i) => (
                  <div
                    key={i}
                    style={{
                      background: t.surfaceTint,
                      border: `1px solid ${t.primarySoft}`,
                      borderRadius: 12,
                      padding: '10px 14px',
                    }}
                  >
                    <div
                      style={{
                        fontSize: 11,
                        fontWeight: 800,
                        color: t.primaryDeep,
                        letterSpacing: 0.4,
                        textTransform: 'uppercase',
                        marginBottom: 4,
                        display: 'flex',
                        justifyContent: 'space-between',
                      }}
                    >
                      <span>{p.feature}</span>
                      <span style={{ fontWeight: 600, color: t.ink4, letterSpacing: 0, textTransform: 'none' }}>{p.at}</span>
                    </div>
                    <div style={{ fontSize: 13, fontWeight: 700, color: t.ink }}>
                      {p.goal ?? p.message ?? '—'}
                    </div>
                  </div>
                ))}
              </div>
            </AdminPanel>
          </>
        )}
      </div>
    </div>
  );
}

export default AiInsightsSection;
