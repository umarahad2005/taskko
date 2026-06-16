/**
 * POST /api/ai/chat — Tako chat reply given message + user context (FR-7.2).
 *
 * Server-side Gemini (NFR-2), grounded in user state (streak, points, mood,
 * pending tasks). On failure returns a friendly fallback with `fallback: true`
 * so chat history is preserved and the UI can retry (FR-7.6, NFR-4).
 *
 * Request:  POST, Authorization: Bearer <token>
 *           body: { message: string, context?: {
 *             name?, rank?, points?, streakDays?, shields?, mood?, pendingTasks?[] } }
 * Response 200: { reply: string, fallback: boolean }
 * Errors:   400 (missing message), 401 (auth), 500 { error, retryable }
 */
import type { NextApiResponse } from 'next';
import { withAuth, type AuthedRequest } from '../../../lib/auth';
import { methodGuard, sendError, sendJson } from '../../../lib/http';
import { generateChatReply, loadUserContext, type UserContext } from '../../../lib/gemini';

// Allow up to 60s on Vercel — Gemini 3.x thinking can exceed the default timeout.
export const config = { maxDuration: 60 };

export default withAuth(async (req: AuthedRequest, res: NextApiResponse) => {
  if (!methodGuard(req, res, ['POST'])) return;

  const { message, context } = (req.body ?? {}) as {
    message?: unknown;
    context?: unknown;
  };

  if (typeof message !== 'string' || message.trim().length === 0 || message.length > 2000) {
    return sendError(res, 400, 'A non-empty message (≤2000 chars) is required', false);
  }

  // Ground Tako in the caller's real state: load their profile + pending tasks
  // from Firestore (so "what are my current tasks?" works), then let any
  // client-provided context override/augment it.
  const serverCtx = await loadUserContext(req.user.uid);
  const clientCtx: UserContext =
    typeof context === 'object' && context !== null ? (context as UserContext) : {};
  const ctx: UserContext = { ...serverCtx, ...clientCtx };

  const result = await generateChatReply(message.trim(), ctx);
  sendJson(res, result);
});
