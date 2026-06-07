/**
 * lib/http.ts — standard JSON error envelope + small response helpers.
 *
 * All Taskko API errors use the shape: { error: string, retryable: boolean }
 * (SRS §6, NFR-4). `retryable` tells the Flutter app / admin UI whether a
 * "Retry" affordance makes sense (e.g. transient Gemini/network failure) vs.
 * a hard client error (bad request, unauthorized).
 */
import type { NextApiResponse } from 'next';

export interface ErrorEnvelope {
  error: string;
  retryable: boolean;
}

/** Build a typed error envelope. */
export function errorEnvelope(message: string, retryable = false): ErrorEnvelope {
  return { error: message, retryable };
}

/** Send a JSON error with the standard envelope. */
export function sendError(
  res: NextApiResponse,
  status: number,
  message: string,
  retryable = false,
): void {
  res.status(status).json(errorEnvelope(message, retryable));
}

/** Send a successful JSON payload. */
export function sendJson<T>(res: NextApiResponse, body: T, status = 200): void {
  res.status(status).json(body);
}

/**
 * Guard that the request uses one of the allowed HTTP methods.
 * Returns true if the method is allowed; otherwise sends 405 and returns false.
 */
export function methodGuard(
  req: { method?: string },
  res: NextApiResponse,
  allowed: string[],
): boolean {
  const method = (req.method ?? 'GET').toUpperCase();
  if (allowed.includes(method)) return true;
  res.setHeader('Allow', allowed.join(', '));
  sendError(res, 405, `Method ${method} not allowed`, false);
  return false;
}

/**
 * Wrap an async handler so any thrown error becomes a 500 envelope instead of
 * crashing the function (NFR-4: failures never crash a flow).
 */
export function withErrorEnvelope(
  handler: (...args: any[]) => Promise<unknown> | unknown,
) {
  return async (req: any, res: NextApiResponse) => {
    try {
      return await handler(req, res);
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('[taskko] unhandled handler error:', err);
      if (!res.headersSent) {
        sendError(res, 500, 'Internal server error', true);
      }
    }
  };
}
