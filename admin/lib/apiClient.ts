/**
 * lib/apiClient.ts — fetch wrapper for the admin UI.
 *
 * Attaches `Authorization: Bearer <Firebase ID token>` to every /api/admin/*
 * call and parses the standard `{ error, retryable }` error envelope (lib/http.ts).
 * Throws `ApiError` on non-2xx so callers can show a retry affordance.
 */
import { getIdToken } from './firebaseClient';

export class ApiError extends Error {
  status: number;
  retryable: boolean;
  constructor(message: string, status: number, retryable: boolean) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.retryable = retryable;
  }
}

type Query = Record<string, string | number | undefined | null>;

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE';
  query?: Query;
  body?: unknown;
}

function buildUrl(path: string, query?: Query): string {
  if (!query) return path;
  const params = new URLSearchParams();
  for (const [k, v] of Object.entries(query)) {
    if (v !== undefined && v !== null && v !== '') params.set(k, String(v));
  }
  const qs = params.toString();
  return qs ? `${path}?${qs}` : path;
}

/**
 * Core request helper. Adds the bearer token, sends/parses JSON, and maps the
 * error envelope to an `ApiError`.
 */
export async function apiRequest<T>(path: string, opts: RequestOptions = {}): Promise<T> {
  const token = await getIdToken();
  if (!token) {
    throw new ApiError('Not signed in', 401, false);
  }

  const headers: Record<string, string> = {
    Authorization: `Bearer ${token}`,
  };
  if (opts.body !== undefined) headers['Content-Type'] = 'application/json';

  let res: Response;
  try {
    res = await fetch(buildUrl(path, opts.query), {
      method: opts.method ?? 'GET',
      headers,
      body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined,
    });
  } catch {
    // Network failure — treat as retryable.
    throw new ApiError('Network error — check your connection', 0, true);
  }

  let data: unknown = null;
  const text = await res.text();
  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      data = null;
    }
  }

  if (!res.ok) {
    const env = (data ?? {}) as { error?: string; retryable?: boolean };
    throw new ApiError(
      env.error ?? `Request failed (${res.status})`,
      res.status,
      env.retryable ?? res.status >= 500,
    );
  }

  return data as T;
}

export const api = {
  get: <T>(path: string, query?: Query) => apiRequest<T>(path, { method: 'GET', query }),
  post: <T>(path: string, body?: unknown) => apiRequest<T>(path, { method: 'POST', body }),
  patch: <T>(path: string, body?: unknown) => apiRequest<T>(path, { method: 'PATCH', body }),
};
