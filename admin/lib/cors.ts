/**
 * lib/cors.ts — CORS handling honoring ALLOWED_ORIGINS (SRS §6).
 *
 * The Flutter Android client sends no Origin header (native HTTP), so those
 * requests are always permitted. Browser callers (admin web, Flutter web) send
 * an Origin which must appear in the ALLOWED_ORIGINS allow-list.
 *
 * `applyCors` also short-circuits OPTIONS preflight requests, returning true to
 * signal the caller that the request has been fully handled.
 */
import type { NextApiRequest, NextApiResponse } from 'next';

function allowedOrigins(): string[] {
  return (process.env.ALLOWED_ORIGINS ?? '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
}

/**
 * Apply CORS headers. Returns true if the request was a preflight (OPTIONS)
 * and has been fully answered — the caller should then return immediately.
 */
export function applyCors(req: NextApiRequest, res: NextApiResponse): boolean {
  const origin = req.headers.origin;
  const allowList = allowedOrigins();

  if (origin && allowList.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
    res.setHeader('Vary', 'Origin');
  }

  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PATCH, OPTIONS',
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Authorization, Content-Type',
  );
  res.setHeader('Access-Control-Max-Age', '86400');

  if ((req.method ?? '').toUpperCase() === 'OPTIONS') {
    res.status(204).end();
    return true;
  }
  return false;
}
