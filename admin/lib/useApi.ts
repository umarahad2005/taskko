/**
 * lib/useApi.ts — tiny data-fetching hook with loading/error/retry state.
 *
 * Wraps an async fetcher (typically an `api.get(...)` call) and re-runs it when
 * `deps` change. Surfaces the ApiError message + `retryable` flag so sections
 * can show a labelled error with a Retry button.
 */
import { useCallback, useEffect, useState } from 'react';
import { ApiError } from './apiClient';

export interface ApiState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  retryable: boolean;
  reload: () => void;
}

export function useApi<T>(fetcher: () => Promise<T>, deps: unknown[] = []): ApiState<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [retryable, setRetryable] = useState(false);
  const [nonce, setNonce] = useState(0);

  const reload = useCallback(() => setNonce((n) => n + 1), []);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    fetcher()
      .then((res) => {
        if (!cancelled) setData(res);
      })
      .catch((err: unknown) => {
        if (cancelled) return;
        if (err instanceof ApiError) {
          setError(err.message);
          setRetryable(err.retryable);
        } else {
          setError('Something went wrong');
          setRetryable(true);
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, nonce]);

  return { data, loading, error, retryable, reload };
}
