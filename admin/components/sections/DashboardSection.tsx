/**
 * DashboardSection — KPI cards, engagement chart, rank distribution, top goals,
 * activity feed (FR-11.3). Data from GET /api/admin/metrics.
 */
import React from 'react';
import { api } from '../../lib/apiClient';
import { useApi } from '../../lib/useApi';
import type { AdminMetrics } from '../../lib/adminTypes';
import { tokens as t } from '../../lib/theme';
import { AdminTopBar, AdminPanel, StatCard, LoadingState, ErrorState } from '../ui';
import { Icon, type IconName } from '../Icon';

const RANK_COLORS: Record<string, string> = {
  Rookie: '#A8A8BC',
  Pro: t.primary,
  Elite: t.energy,
  Master: t.gold,
  Legend: t.purple,
};

const FEED_ICON: Record<string, { icon: IconName; tone: string }> = {
  signup: { icon: 'users', tone: t.primary },
  badge: { icon: 'medal', tone: t.energy },
  ai: { icon: 'sparkles', tone: t.mintDeep },
  upgrade: { icon: 'trophy', tone: t.primary },
  report: { icon: 'flag', tone: t.energyDeep },
};

function EngagementChart({ series }: { series: { day: string; dau: number }[] }) {
  const values = series.map((s) => s.dau);
  const max = Math.max(...values, 1);
  const W = 600;
  const H = 220;
  const P = 30;
  const xs = (i: number) => P + (i / Math.max(series.length - 1, 1)) * (W - P * 2);
  const ys = (v: number) => H - P - (v / max) * (H - P * 2);
  const dpath = values.map((v, i) => `${i ? 'L' : 'M'} ${xs(i)} ${ys(v)}`).join(' ');
  const darea = dpath + ` L ${xs(values.length - 1)} ${H - P} L ${xs(0)} ${H - P} Z`;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} width="100%" style={{ display: 'block' }}>
      <defs>
        <linearGradient id="dauGrad" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor={t.primary} stopOpacity="0.25" />
          <stop offset="100%" stopColor={t.primary} stopOpacity="0" />
        </linearGradient>
      </defs>
      {[0, 0.25, 0.5, 0.75, 1].map((f) => (
        <line
          key={f}
          x1={P}
          x2={W - P}
          y1={ys(max * f)}
          y2={ys(max * f)}
          stroke={t.surfaceSoft}
          strokeWidth="1"
        />
      ))}
      <path d={darea} fill="url(#dauGrad)" />
      <path
        d={dpath}
        fill="none"
        stroke={t.primary}
        strokeWidth="2.4"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      {values.map((v, i) => (
        <circle key={i} cx={xs(i)} cy={ys(v)} r="2.8" fill={t.primary} />
      ))}
      {series.map((s, i) => (
        <text
          key={i}
          x={xs(i)}
          y={H - 10}
          fontSize="10"
          textAnchor="middle"
          fill={t.ink4}
          fontFamily="JetBrains Mono, monospace"
        >
          {s.day}
        </text>
      ))}
    </svg>
  );
}

export function DashboardSection() {
  const { data, loading, error, retryable, reload } = useApi<AdminMetrics>(
    () => api.get<AdminMetrics>('/api/admin/metrics'),
    [],
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column' }}>
      <AdminTopBar
        title="Overview"
        subtitle="Live snapshot of how Taskko students are doing today."
      />
      <div style={{ padding: '18px 28px 28px' }}>
        {loading && <LoadingState label="Loading dashboard…" />}
        {error && !loading && (
          <ErrorState message={error} retryable={retryable} onRetry={reload} />
        )}
        {data && !loading && !error && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
            {data.stub && (
              <div
                style={{
                  fontSize: 11.5,
                  fontWeight: 700,
                  color: t.primaryDeep,
                  background: t.primarySoft,
                  padding: '6px 12px',
                  borderRadius: 8,
                  alignSelf: 'flex-start',
                }}
              >
                Showing sample data (stub) — live metrics arrive in M9.
              </div>
            )}

            {/* KPI grid */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
              <StatCard label="Active users (DAU)" value={data.kpis.dau.toLocaleString()} delta="today" deltaTone="flat" accent={t.primary} />
              <StatCard label="New signups" value={data.kpis.signupsToday.toLocaleString()} delta="today" deltaTone="up" accent={t.energy} />
              <StatCard label="Active streaks" value={data.kpis.activeStreaks.toLocaleString()} delta="ongoing" deltaTone="flat" accent={t.energy} />
              <StatCard label="AI calls today" value={data.kpis.aiCallsToday.toLocaleString()} delta="today" deltaTone="flat" accent={t.mint} />
              <StatCard label="Pro conversions" value={data.kpis.proConversions.toLocaleString()} delta="this week" deltaTone="up" accent="#5BCBF5" />
              <StatCard label="Avg tasks / user" value={String(data.kpis.avgTasksPerUser)} delta="per day" deltaTone="flat" accent={t.gold} />
            </div>

            {/* Charts row */}
            <div style={{ display: 'grid', gridTemplateColumns: '1.6fr 1fr', gap: 14 }}>
              <AdminPanel
                title="Engagement"
                subtitle="Daily active users over the week"
                action={
                  <span
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: 5,
                      fontSize: 11.5,
                      fontWeight: 600,
                      color: t.ink3,
                    }}
                  >
                    <span style={{ width: 9, height: 9, borderRadius: 99, background: t.primary }} /> DAU
                  </span>
                }
              >
                <EngagementChart series={data.engagement} />
              </AdminPanel>

              <AdminPanel title="Rank distribution" subtitle="Across all active users">
                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                  {(() => {
                    const total = data.rankDistribution.reduce((s, r) => s + r.count, 0) || 1;
                    return data.rankDistribution.map((r) => {
                      const pct = Math.round((r.count / total) * 100);
                      const c = RANK_COLORS[r.rank] ?? t.ink4;
                      return (
                        <div key={r.rank}>
                          <div
                            style={{
                              display: 'flex',
                              justifyContent: 'space-between',
                              fontSize: 12,
                              fontWeight: 700,
                              color: t.ink2,
                              marginBottom: 4,
                            }}
                          >
                            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                              <span style={{ width: 8, height: 8, borderRadius: 99, background: c }} /> {r.rank}
                            </span>
                            <span className="mono" style={{ color: t.ink3, fontWeight: 600 }}>
                              {r.count.toLocaleString()} · {pct}%
                            </span>
                          </div>
                          <div style={{ height: 6, background: t.surfaceSoft, borderRadius: 99, overflow: 'hidden' }}>
                            <div style={{ width: `${pct}%`, height: '100%', background: c, borderRadius: 99 }} />
                          </div>
                        </div>
                      );
                    });
                  })()}
                </div>
              </AdminPanel>
            </div>

            {/* Tables row */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
              <AdminPanel title="Top goals being broken down" subtitle="What students are asking Tako to help with">
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {(() => {
                    const max = Math.max(...data.topGoals.map((g) => g.users), 1);
                    const colors = [t.primary, t.energy, t.mint, t.rose, t.gold, t.purple];
                    return data.topGoals.map((g, i) => (
                      <div key={g.goal} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '6px 4px' }}>
                        <div className="mono" style={{ width: 18, fontSize: 11, fontWeight: 700, color: t.ink4 }}>
                          {String(i + 1).padStart(2, '0')}
                        </div>
                        <div style={{ flex: 1, fontSize: 13, fontWeight: 600, color: t.ink }}>{g.goal}</div>
                        <div style={{ flex: '0 0 140px', height: 6, background: t.surfaceSoft, borderRadius: 99, overflow: 'hidden' }}>
                          <div
                            style={{
                              width: `${(g.users / max) * 100}%`,
                              height: '100%',
                              background: colors[i % colors.length],
                              borderRadius: 99,
                            }}
                          />
                        </div>
                        <div className="mono" style={{ fontSize: 11.5, color: t.ink3, fontWeight: 600, width: 44, textAlign: 'right' }}>
                          {g.users}
                        </div>
                      </div>
                    ));
                  })()}
                </div>
              </AdminPanel>

              <AdminPanel
                title="Recent activity"
                subtitle="Live feed of high-signal events"
                action={
                  <span style={{ fontSize: 11, fontWeight: 700, color: t.mintDeep, display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                    <span style={{ width: 8, height: 8, borderRadius: 99, background: t.mintDeep }} /> Live
                  </span>
                }
              >
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  {data.activityFeed.map((e, i) => {
                    const meta = FEED_ICON[e.type] ?? { icon: 'sparkles' as IconName, tone: t.primary };
                    return (
                      <div
                        key={i}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: 10,
                          padding: '9px 4px',
                          borderBottom: i < data.activityFeed.length - 1 ? `1px solid ${t.surfaceSoft}` : 'none',
                        }}
                      >
                        <div
                          style={{
                            width: 30,
                            height: 30,
                            borderRadius: 9,
                            background: `${meta.tone}15`,
                            color: meta.tone,
                            display: 'grid',
                            placeItems: 'center',
                            flexShrink: 0,
                          }}
                        >
                          <Icon name={meta.icon} size={15} />
                        </div>
                        <div style={{ flex: 1, fontSize: 12.5, color: t.ink, lineHeight: 1.4 }}>{e.text}</div>
                        <div className="mono" style={{ fontSize: 11, color: t.ink4, whiteSpace: 'nowrap' }}>
                          {e.at}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </AdminPanel>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default DashboardSection;
