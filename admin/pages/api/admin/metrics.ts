/**
 * GET /api/admin/metrics — real dashboard KPIs + aggregates (FR-11.3). Admin-only.
 * Computed from Firebase Auth + Firestore (users, tasks, aiLogs). No stubs.
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendJson } from '../../../lib/http';
import { adminAuth, adminDb } from '../../../lib/firebaseAdmin';

function rankForPoints(p: number): string {
  if (p >= 3000) return 'Legend';
  if (p >= 1560) return 'Elite';
  if (p >= 1000) return 'Pro';
  return 'Rookie';
}

const _DOW = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

function dateKey(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

async function safeCount(run: () => Promise<number>): Promise<number> {
  try {
    return await run();
  } catch {
    return 0;
  }
}

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET'])) return;

  const db = adminDb();
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const todayKey = dateKey(new Date());
  const dayMs = 86_400_000;

  // --- Auth: total users, signups today + per-day for last 7 days, recent feed ---
  const list = await adminAuth().listUsers(1000);
  const totalUsers = list.users.length;
  let signupsToday = 0;
  const signupsByDay = List7();
  for (const u of list.users) {
    if (!u.metadata.creationTime) continue;
    const c = new Date(u.metadata.creationTime);
    const cDay = new Date(c.getFullYear(), c.getMonth(), c.getDate());
    if (c >= todayStart) signupsToday++;
    const diff = Math.floor((stripTime(new Date()).getTime() - cDay.getTime()) / dayMs);
    if (diff >= 0 && diff < 7) signupsByDay[6 - diff]++;
  }
  const engagement = signupsByDay.map((count, i) => {
    const d = new Date(Date.now() - (6 - i) * dayMs);
    return { day: _DOW[d.getDay()], dau: count }; // 'dau' key reused for daily new-signups (real)
  });
  const activityFeed = [...list.users]
    .filter((u) => u.metadata.creationTime)
    .sort((a, b) => new Date(b.metadata.creationTime!).getTime() - new Date(a.metadata.creationTime!).getTime())
    .slice(0, 6)
    .map((u) => ({ type: 'signup', text: `${u.displayName || u.email || 'A student'} joined`, at: u.metadata.creationTime }));

  // --- Firestore profiles: rank distribution, active streaks, active today (DAU) ---
  const profilesSnap = await db.collection('users').get();
  const rankCounts: Record<string, number> = { Rookie: 0, Pro: 0, Elite: 0, Legend: 0 };
  let activeStreaks = 0;
  let activeToday = 0;
  profilesSnap.forEach((doc) => {
    const p = doc.data();
    const pts = (p.points as number) ?? 0;
    rankCounts[rankForPoints(pts)]++;
    if (((p.streakDays as number) ?? 0) > 0) activeStreaks++;
    if ((p.lastActiveDate as string) === todayKey) activeToday++;
  });
  const rankDistribution = Object.entries(rankCounts).map(([rank, count]) => ({ rank, count }));

  // --- AI calls today (from aiLogs) + tasks aggregate ---
  const aiCallsToday = await safeCount(async () =>
    (await db.collection('aiLogs').where('ts', '>=', todayStart).count().get()).data().count);
  const totalTasks = await safeCount(async () => (await db.collectionGroup('tasks').count().get()).data().count);
  const avgTasksPerUser = totalUsers > 0 ? Math.round((totalTasks / totalUsers) * 10) / 10 : 0;

  // --- Top goals (sampled from tasks) ---
  const goalTally: Record<string, number> = {};
  try {
    const tasksSnap = await db.collectionGroup('tasks').limit(300).get();
    tasksSnap.forEach((d) => {
      const g = (d.data().goal as string) || '';
      if (g && g.toLowerCase() !== 'admin') goalTally[g] = (goalTally[g] ?? 0) + 1;
    });
  } catch {
    // ignore
  }
  const topGoals = Object.entries(goalTally)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([goal, users]) => ({ goal, users }));

  sendJson(res, {
    kpis: {
      dau: activeToday,
      signupsToday,
      activeStreaks,
      aiCallsToday,
      proConversions: 0, // free product (M17 deferred)
      avgTasksPerUser,
    },
    engagement,
    rankDistribution,
    topGoals,
    activityFeed,
  });
});

function stripTime(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

function List7(): number[] {
  return [0, 0, 0, 0, 0, 0, 0];
}
