/**
 * /api/admin/moderation — moderation queue (FR-11.5). Admin-only (FR-11.9).
 *
 * GET  ?severity=all|low|medium|high → { items: ModerationItem[] }
 * POST body: { itemId: string, action: 'dismiss'|'warn'|'suspend' } → { item }
 *
 * Errors: 400, 401, 403, 500 { error, retryable }
 * TODO(M9): back with the real `moderation/{id}` Firestore collection.
 */
import type { NextApiResponse } from 'next';
import { withAdmin, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';

interface ModerationItem {
  id: string;
  targetUser: string;
  reason: string;
  severity: 'low' | 'medium' | 'high';
  status: 'open' | 'dismissed' | 'warned' | 'suspended';
  createdAt: string;
}

const QUEUE: ModerationItem[] = [
  { id: 'm1', targetUser: 'zara@uni.edu', reason: 'Reported squad message', severity: 'low', status: 'open', createdAt: '2026-06-05T08:10:00Z' },
  { id: 'm2', targetUser: 'guest_882', reason: 'Spam goal submissions', severity: 'medium', status: 'open', createdAt: '2026-06-05T07:42:00Z' },
  { id: 'm3', targetUser: 'bilal@uni.edu', reason: 'Abusive language flagged by AI', severity: 'high', status: 'open', createdAt: '2026-06-04T21:05:00Z' },
];

const ACTIONS: Record<string, ModerationItem['status']> = {
  dismiss: 'dismissed',
  warn: 'warned',
  suspend: 'suspended',
};

export default withAdmin(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['GET', 'POST'])) return;

  if (req.method === 'GET') {
    const severity = String(req.query.severity ?? 'all').toLowerCase();
    const items = severity === 'all' ? QUEUE : QUEUE.filter((i) => i.severity === severity);
    return sendJson(res, { items, stub: true });
  }

  const { itemId, action } = (req.body ?? {}) as { itemId?: string; action?: string };
  if (!itemId || !action || !(action in ACTIONS)) {
    return sendError(res, 400, 'Provide itemId and a valid action', false);
  }
  const base = QUEUE.find((i) => i.id === itemId) ?? QUEUE[0];
  sendJson(res, { item: { ...base, status: ACTIONS[action] }, stub: true });
});
