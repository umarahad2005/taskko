/**
 * /api/admin/moderation — real moderation queue (FR-11.5). Admin-only.
 * Backed by the Firestore `moderation` collection (empty until reports exist).
 *
 * GET  ?severity=all|low|medium|high → { items: ModerationItem[] }
 * POST { itemId, action: 'dismiss'|'warn'|'suspend' } → { item }
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { adminDb } from '../../../lib/firebaseAdmin';

const ACTIONS: Record<string, string> = { dismiss: 'dismissed', warn: 'warned', suspend: 'suspended' };

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET', 'POST'])) return;
  const col = adminDb().collection('moderation');

  if (req.method === 'GET') {
    const severity = String(req.query.severity ?? 'all').toLowerCase();
    const snap = await col.limit(100).get();
    let items = snap.docs.map((d) => {
      const x = d.data();
      const ts = x.createdAt;
      return {
        id: d.id,
        targetUser: (x.targetUser as string) ?? '',
        reason: (x.reason as string) ?? '',
        severity: (x.severity as string) ?? 'low',
        status: (x.status as string) ?? 'open',
        createdAt: ts && typeof ts.toDate === 'function' ? ts.toDate().toISOString() : null,
      };
    });
    if (severity !== 'all') items = items.filter((i) => i.severity === severity);
    items.sort((a, b) => (b.createdAt ?? '').localeCompare(a.createdAt ?? ''));
    return sendJson(res, { items });
  }

  const { itemId, action } = (req.body ?? {}) as { itemId?: string; action?: string };
  if (!itemId || !action || !(action in ACTIONS)) {
    return sendError(res, 400, 'Provide itemId and a valid action', false);
  }
  await col.doc(itemId).set({ status: ACTIONS[action] }, { merge: true });
  const d = await col.doc(itemId).get();
  sendJson(res, { item: { id: d.id, ...d.data() } });
});
