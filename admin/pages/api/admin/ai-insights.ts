/**
 * GET /api/admin/ai-insights — real Gemini usage from the `aiLogs` collection
 * (FR-11.6). Admin-only. Populated by lib/gemini.ts on every AI call.
 */
import type { NextApiResponse } from 'next';
import type { QueryDocumentSnapshot } from 'firebase-admin/firestore';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';
import { adminDb } from '../../../lib/firebaseAdmin';

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET'])) return;

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  let docs: QueryDocumentSnapshot[] = [];
  try {
    docs = (await adminDb().collection('aiLogs').orderBy('ts', 'desc').limit(500).get()).docs;
  } catch {
    try {
      docs = (await adminDb().collection('aiLogs').limit(500).get()).docs;
    } catch {
      docs = [];
    }
  }

  let callsToday = 0;
  let fallbacks = 0;
  let latencySum = 0;
  let latencyN = 0;
  const perFeature: Record<string, { total: number; fallback: number }> = {};
  const recentPrompts: { feature: string; at: string | null }[] = [];

  for (const d of docs) {
    const x = d.data();
    const tsRaw = x.ts as { toDate?: () => Date } | undefined;
    const ts = tsRaw && typeof tsRaw.toDate === 'function' ? tsRaw.toDate() : null;
    const feature = (x.feature as string) ?? 'unknown';
    const fallback = (x.fallback as boolean) ?? false;
    if (ts && ts >= todayStart) callsToday++;
    if (fallback) fallbacks++;
    if (typeof x.latencyMs === 'number') {
      latencySum += x.latencyMs;
      latencyN++;
    }
    perFeature[feature] ??= { total: 0, fallback: 0 };
    perFeature[feature].total++;
    if (fallback) perFeature[feature].fallback++;
    if (recentPrompts.length < 12) recentPrompts.push({ feature, at: ts ? ts.toISOString() : null });
  }

  const calls = docs.length;
  const quality = Object.entries(perFeature).map(([feature, v]) => ({
    feature,
    good: v.total > 0 ? Math.round((1 - v.fallback / v.total) * 100) / 100 : 1,
    fallback: v.total > 0 ? Math.round((v.fallback / v.total) * 100) / 100 : 0,
  }));

  sendJson(res, {
    usage: {
      callsToday,
      calls7d: calls,
      avgLatencyMs: latencyN > 0 ? Math.round(latencySum / latencyN) : 0,
      fallbackRate: calls > 0 ? Math.round((fallbacks / calls) * 1000) / 1000 : 0,
    },
    costUsd: { today: 0, month: 0 }, // free tier — no per-call cost tracked
    quality,
    stuckPhrases: [],
    recentPrompts,
  });
});
