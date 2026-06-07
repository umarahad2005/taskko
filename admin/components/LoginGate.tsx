/**
 * components/LoginGate.tsx — Firebase auth + admin-claim UX gate (FR-11.1/11.9).
 *
 * Three states:
 *  - signed out → sign-in card (Google + email/password).
 *  - signed in, NO admin claim → "admin access required" message.
 *  - signed in WITH admin claim → render the admin console (children).
 *
 * The server enforces the claim on every /api/admin/* call (FR-11.9); this gate
 * is UX only and never the security boundary.
 */
import React, { useEffect, useState } from 'react';
import {
  isFirebaseConfigured,
  watchAuth,
  signInWithGoogle,
  signInWithEmail,
  signOut,
  hasAdminClaim,
  type User,
} from '../lib/firebaseClient';
import { tokens as t } from '../lib/theme';
import { AdminLayout } from './AdminLayout';
import { Icon } from './Icon';

type Phase = 'loading' | 'signedOut' | 'notAdmin' | 'admin';

export function LoginGate() {
  const [phase, setPhase] = useState<Phase>('loading');
  const [user, setUser] = useState<User | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!isFirebaseConfigured) {
      setPhase('signedOut');
      setAuthError('Firebase is not configured. Set NEXT_PUBLIC_FIREBASE_* env vars.');
      return;
    }
    const unsub = watchAuth(async (u) => {
      setUser(u);
      if (!u) {
        setPhase('signedOut');
        return;
      }
      const admin = await hasAdminClaim(u);
      setPhase(admin ? 'admin' : 'notAdmin');
    });
    return unsub;
  }, []);

  async function doGoogle() {
    setBusy(true);
    setAuthError(null);
    try {
      await signInWithGoogle();
    } catch (err) {
      setAuthError(err instanceof Error ? err.message : 'Google sign-in failed');
    } finally {
      setBusy(false);
    }
  }

  async function doEmail(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setAuthError(null);
    try {
      await signInWithEmail(email, password);
    } catch (err) {
      setAuthError(err instanceof Error ? err.message : 'Email sign-in failed');
    } finally {
      setBusy(false);
    }
  }

  if (phase === 'admin' && user) {
    return (
      <AdminLayout
        adminName={user.displayName ?? ''}
        adminEmail={user.email ?? ''}
        onSignOut={signOut}
      />
    );
  }

  // Centered card shell for loading / signed-out / not-admin states.
  return (
    <div
      style={{
        minHeight: '100vh',
        display: 'grid',
        placeItems: 'center',
        background: 'radial-gradient(1200px 600px at 50% -10%, #DDF3FE 0%, #FAFBFD 55%)',
        fontFamily: t.fontUi,
        padding: 24,
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: 380,
          background: t.surface,
          border: `1px solid ${t.line}`,
          borderRadius: 22,
          padding: 28,
          boxShadow: '0 24px 60px -30px rgba(15,27,38,0.35)',
        }}
      >
        {/* Brand */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 18 }}>
          <div
            style={{
              width: 38,
              height: 38,
              borderRadius: 11,
              background: 'linear-gradient(135deg, #5BCBF5, #1FB6F0, #0A6FA8)',
              display: 'grid',
              placeItems: 'center',
              color: '#fff',
              fontWeight: 800,
              fontSize: 20,
              fontFamily: 'Georgia, serif',
            }}
          >
            t
          </div>
          <div>
            <div className="display" style={{ fontWeight: 700, fontSize: 18, color: t.ink }}>
              taskko
            </div>
            <div style={{ fontSize: 10, color: t.primaryDeep, fontWeight: 800, letterSpacing: 1, textTransform: 'uppercase' }}>
              Admin Console
            </div>
          </div>
        </div>

        {phase === 'loading' && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12, padding: '24px 0' }}>
            <div className="tk-spinner" />
            <div style={{ fontSize: 13, color: t.ink3, fontWeight: 600 }}>Checking your session…</div>
          </div>
        )}

        {phase === 'notAdmin' && (
          <div style={{ textAlign: 'center' }}>
            <div
              style={{
                width: 48,
                height: 48,
                borderRadius: 13,
                background: t.energySoft,
                color: t.energyDeep,
                display: 'grid',
                placeItems: 'center',
                margin: '6px auto 12px',
              }}
            >
              <Icon name="shield" size={24} />
            </div>
            <div className="display" style={{ fontSize: 20, fontWeight: 700, color: t.ink }}>
              Admin access required
            </div>
            <div style={{ fontSize: 13, color: t.ink3, marginTop: 6, lineHeight: 1.5 }}>
              You&rsquo;re signed in as <b style={{ color: t.ink }}>{user?.email}</b>, but this account
              doesn&rsquo;t have the <span className="mono">admin</span> claim. Ask an owner to grant it.
            </div>
            <button
              onClick={signOut}
              className="tap"
              style={{
                marginTop: 16,
                border: `1px solid ${t.line}`,
                background: t.surface,
                color: t.ink2,
                padding: '9px 16px',
                borderRadius: 10,
                fontSize: 12.5,
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              Sign out
            </button>
          </div>
        )}

        {phase === 'signedOut' && (
          <>
            <div className="display" style={{ fontSize: 22, fontWeight: 700, color: t.ink }}>
              Sign in
            </div>
            <div style={{ fontSize: 13, color: t.ink3, marginTop: 2, marginBottom: 16 }}>
              Admins only. Server verifies the admin claim.
            </div>

            {authError && (
              <div
                role="alert"
                style={{
                  fontSize: 12,
                  fontWeight: 600,
                  color: t.energyDeep,
                  background: t.energySoft,
                  padding: '8px 12px',
                  borderRadius: 9,
                  marginBottom: 12,
                }}
              >
                {authError}
              </div>
            )}

            <button
              onClick={doGoogle}
              disabled={busy || !isFirebaseConfigured}
              className="tap"
              style={{
                width: '100%',
                border: `1px solid ${t.line}`,
                background: t.surface,
                color: t.ink,
                padding: '11px 14px',
                borderRadius: 11,
                fontSize: 13.5,
                fontWeight: 700,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 8,
                opacity: busy || !isFirebaseConfigured ? 0.6 : 1,
              }}
            >
              Continue with Google
            </button>

            <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '16px 0', color: t.ink4, fontSize: 11, fontWeight: 700 }}>
              <div style={{ flex: 1, height: 1, background: t.line }} /> OR <div style={{ flex: 1, height: 1, background: t.line }} />
            </div>

            <form onSubmit={doEmail} style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@taskko.app"
                style={inputStyle}
              />
              <input
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Password"
                style={inputStyle}
              />
              <button
                type="submit"
                disabled={busy || !isFirebaseConfigured}
                className="tap"
                style={{
                  border: 'none',
                  background: 'linear-gradient(180deg,#3BC2F5,#1FB6F0)',
                  color: '#fff',
                  padding: '11px 14px',
                  borderRadius: 11,
                  fontSize: 13.5,
                  fontWeight: 800,
                  cursor: 'pointer',
                  boxShadow: '0 8px 18px -8px rgba(31,182,240,0.6)',
                  opacity: busy || !isFirebaseConfigured ? 0.6 : 1,
                }}
              >
                {busy ? 'Signing in…' : 'Sign in with email'}
              </button>
            </form>
          </>
        )}
      </div>
    </div>
  );
}

const inputStyle: React.CSSProperties = {
  border: `1px solid ${t.line}`,
  borderRadius: 11,
  padding: '11px 14px',
  fontSize: 13.5,
  color: t.ink,
  outline: 'none',
  background: t.surfaceSoft,
};

export default LoginGate;
