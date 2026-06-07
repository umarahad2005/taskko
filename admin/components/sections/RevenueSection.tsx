/**
 * RevenueSection — Pro-tier analytics placeholder (FR-11.7).
 *
 * No real billing this build, so this is a static analytics view (clearly
 * marked as illustrative). Mirrors the prototype's revenue layout: KPI cards,
 * an MRR trend line, and a plan-breakdown donut.
 */
import React from 'react';
import { tokens as t } from '../../lib/theme';
import { AdminTopBar, AdminPanel, StatCard } from '../ui';

function MrrChart() {
  const pts = [820, 840, 900, 950, 1020, 1040, 1100, 1080, 1150, 1240, 1280, 1310, 1380, 1420];
  const xs = (i: number) => 40 + (i / (pts.length - 1)) * 540;
  const ys = (v: number) => 190 - (v / 1500) * 180;
  const path = pts.map((v, i) => `${i ? 'L' : 'M'} ${xs(i)} ${ys(v)}`).join(' ');
  const area = path + ` L ${xs(pts.length - 1)} 190 L 40 190 Z`;
  return (
    <svg viewBox="0 0 600 220" width="100%">
      <defs>
        <linearGradient id="revGrad" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor={t.primary} stopOpacity="0.3" />
          <stop offset="100%" stopColor={t.primary} stopOpacity="0" />
        </linearGradient>
      </defs>
      {[0, 500, 1000, 1500].map((v, i) => (
        <g key={v}>
          <line x1="40" x2="580" y1={190 - i * 45} y2={190 - i * 45} stroke={t.surfaceSoft} />
          <text x="6" y={194 - i * 45} fontSize="10" fill={t.ink4} fontFamily="JetBrains Mono, monospace">
            {v}k
          </text>
        </g>
      ))}
      <path d={area} fill="url(#revGrad)" />
      <path d={path} fill="none" stroke={t.primary} strokeWidth="2.5" strokeLinecap="round" />
      {pts.map((v, i) => (
        <circle key={i} cx={xs(i)} cy={ys(v)} r="2.5" fill={t.primary} />
      ))}
    </svg>
  );
}

function PlanDonut() {
  const segs = [
    { l: 'Monthly · PKR 499', pct: 62, c: t.primary },
    { l: 'Annual · PKR 4,990', pct: 24, c: t.energy },
    { l: 'Student bundle', pct: 10, c: t.mint },
    { l: 'Lifetime', pct: 4, c: t.purple },
  ];
  const r = 38;
  const C = 2 * Math.PI * r;
  let acc = -25;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 20, padding: '10px 0' }}>
      <svg viewBox="0 0 100 100" width="140" height="140">
        {segs.map((s, i) => {
          const len = (s.pct / 100) * C;
          const offset = (acc / 100) * C;
          acc += s.pct;
          return (
            <circle
              key={i}
              cx="50"
              cy="50"
              r={r}
              fill="transparent"
              stroke={s.c}
              strokeWidth="14"
              strokeDasharray={`${len} ${C}`}
              strokeDashoffset={-offset}
              transform="rotate(-90 50 50)"
            />
          );
        })}
        <text x="50" y="48" textAnchor="middle" fontSize="11" fill={t.ink3} fontWeight="700">
          Pro
        </text>
        <text x="50" y="62" textAnchor="middle" fontSize="14" fill={t.ink} fontWeight="800" fontFamily="Georgia, serif">
          2,847
        </text>
      </svg>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {segs.map((s) => (
          <div key={s.l} style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12.5, color: t.ink2 }}>
            <span style={{ width: 10, height: 10, borderRadius: 99, background: s.c }} />
            <span style={{ flex: 1, fontWeight: 600 }}>{s.l}</span>
            <span className="mono" style={{ fontWeight: 700, color: t.ink }}>
              {s.pct}%
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

export function RevenueSection() {
  return (
    <div>
      <AdminTopBar title="Revenue & subscriptions" subtitle="Pro tier conversions, MRR, and growth" />
      <div style={{ padding: '18px 28px 28px', display: 'flex', flexDirection: 'column', gap: 18 }}>
        <div
          style={{
            fontSize: 11.5,
            fontWeight: 700,
            color: t.energyDeep,
            background: t.energySoft,
            padding: '8px 14px',
            borderRadius: 8,
            alignSelf: 'flex-start',
          }}
        >
          Illustrative analytics — no real billing is wired in this build (FR-11.7).
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
          <StatCard label="MRR" value="PKR 1.42M" delta="+12% wow" deltaTone="up" accent={t.primary} spark="0,18 12,14 24,12 36,10 48,7 60,5 72,2" />
          <StatCard label="Pro subscribers" value="2,847" delta="+148 this week" deltaTone="up" accent={t.energy} spark="0,18 12,14 24,11 36,9 48,7 60,5 72,3" />
          <StatCard label="Trial → paid" value="32.4%" delta="+1.8 pp" deltaTone="up" accent={t.mint} />
          <StatCard label="Churn (30d)" value="3.1%" delta="-0.4 pp" deltaTone="up" accent={t.purple} />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
          <AdminPanel title="MRR over time" subtitle="Past 30 days · PKR thousands">
            <MrrChart />
          </AdminPanel>
          <AdminPanel title="Plan breakdown" subtitle="Where subscribers spend">
            <PlanDonut />
          </AdminPanel>
        </div>
      </div>
    </div>
  );
}

export default RevenueSection;
