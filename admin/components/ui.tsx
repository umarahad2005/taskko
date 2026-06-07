/**
 * components/ui.tsx — shared admin UI primitives (ported from the prototype).
 *
 * StatCard, AdminPanel, AdminTopBar plus loading/error/empty states used by
 * every section. Styling matches design_reference/project/admin-sidebar.jsx.
 */
import React from 'react';
import { tokens as t } from '../lib/theme';
import { Icon } from './Icon';

/* ---------------------------------------------------------------- StatCard */

interface StatCardProps {
  label: string;
  value: string;
  delta?: string;
  deltaTone?: 'up' | 'down' | 'flat';
  spark?: string;
  accent?: string;
}

export function StatCard({
  label,
  value,
  delta,
  deltaTone = 'up',
  spark,
  accent = t.primary,
}: StatCardProps) {
  const tone = deltaTone === 'up' ? t.mintDeep : deltaTone === 'down' ? t.energyDeep : t.ink3;
  return (
    <div
      style={{
        background: t.surface,
        border: `1px solid ${t.line}`,
        borderRadius: 16,
        padding: '18px 20px',
        position: 'relative',
        overflow: 'hidden',
      }}
    >
      <div
        style={{
          position: 'absolute',
          right: -20,
          top: -20,
          width: 80,
          height: 80,
          borderRadius: 99,
          background: `${accent}12`,
        }}
      />
      <div
        style={{
          fontSize: 11.5,
          fontWeight: 700,
          color: t.ink3,
          letterSpacing: 0.4,
          textTransform: 'uppercase',
        }}
      >
        {label}
      </div>
      <div
        className="display"
        style={{
          fontWeight: 700,
          fontSize: 32,
          color: t.ink,
          marginTop: 6,
          lineHeight: 1,
          letterSpacing: -0.5,
        }}
      >
        {value}
      </div>
      {(delta || spark) && (
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            marginTop: 8,
            position: 'relative',
          }}
        >
          {delta ? (
            <div
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 3,
                fontSize: 11.5,
                fontWeight: 700,
                color: tone,
                background: `${tone}15`,
                padding: '3px 8px',
                borderRadius: 99,
              }}
            >
              {deltaTone === 'up' ? '↑' : deltaTone === 'down' ? '↓' : '·'} {delta}
            </div>
          ) : (
            <span />
          )}
          {spark && (
            <svg width="78" height="22" viewBox="0 0 78 22">
              <polyline
                points={spark}
                fill="none"
                stroke={accent}
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          )}
        </div>
      )}
    </div>
  );
}

/* --------------------------------------------------------------- AdminPanel */

interface AdminPanelProps {
  title?: string;
  subtitle?: string;
  action?: React.ReactNode;
  children: React.ReactNode;
  padding?: number;
}

export function AdminPanel({ title, subtitle, action, children, padding = 18 }: AdminPanelProps) {
  return (
    <div
      style={{
        background: t.surface,
        border: `1px solid ${t.line}`,
        borderRadius: 16,
        overflow: 'hidden',
      }}
    >
      {title && (
        <div
          style={{
            padding: '14px 18px',
            borderBottom: `1px solid ${t.line}`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: 12,
          }}
        >
          <div>
            <div style={{ fontWeight: 700, fontSize: 14.5, color: t.ink }}>{title}</div>
            {subtitle && <div style={{ fontSize: 11.5, color: t.ink3, marginTop: 1 }}>{subtitle}</div>}
          </div>
          {action}
        </div>
      )}
      <div style={{ padding }}>{children}</div>
    </div>
  );
}

/* -------------------------------------------------------------- AdminTopBar */

interface AdminTopBarProps {
  title: string;
  subtitle?: string;
  actions?: React.ReactNode;
}

export function AdminTopBar({ title, subtitle, actions }: AdminTopBarProps) {
  return (
    <div
      style={{
        padding: '18px 28px',
        borderBottom: `1px solid ${t.line}`,
        background: t.surface,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: 20,
        position: 'sticky',
        top: 0,
        zIndex: 5,
      }}
    >
      <div>
        <div
          style={{
            fontSize: 11,
            fontWeight: 800,
            color: t.primaryDeep,
            letterSpacing: 1.4,
            textTransform: 'uppercase',
          }}
        >
          Admin
        </div>
        <div
          className="display"
          style={{
            fontWeight: 700,
            fontSize: 24,
            letterSpacing: -0.4,
            color: t.ink,
            marginTop: 1,
          }}
        >
          {title}
        </div>
        {subtitle && <div style={{ fontSize: 13, color: t.ink3, marginTop: 2 }}>{subtitle}</div>}
      </div>
      <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>{actions}</div>
    </div>
  );
}

/* ------------------------------------------------------- loading / error / empty */

export function LoadingState({ label = 'Loading…' }: { label?: string }) {
  return (
    <div
      role="status"
      aria-live="polite"
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 12,
        padding: '56px 20px',
        color: t.ink3,
      }}
    >
      <div className="tk-spinner" />
      <div style={{ fontSize: 13, fontWeight: 600 }}>{label}</div>
    </div>
  );
}

export function ErrorState({
  message,
  retryable,
  onRetry,
}: {
  message: string;
  retryable?: boolean;
  onRetry?: () => void;
}) {
  return (
    <div
      role="alert"
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 12,
        padding: '48px 20px',
        textAlign: 'center',
      }}
    >
      <div
        style={{
          width: 44,
          height: 44,
          borderRadius: 12,
          background: t.energySoft,
          color: t.energyDeep,
          display: 'grid',
          placeItems: 'center',
        }}
      >
        <Icon name="info" size={22} />
      </div>
      <div style={{ fontSize: 14, fontWeight: 700, color: t.ink, maxWidth: 420 }}>{message}</div>
      {retryable && onRetry && (
        <button
          onClick={onRetry}
          className="tap"
          style={{
            border: 'none',
            background: 'linear-gradient(180deg,#3BC2F5,#1FB6F0)',
            color: '#fff',
            padding: '9px 18px',
            borderRadius: 10,
            fontSize: 12.5,
            fontWeight: 700,
            cursor: 'pointer',
            display: 'inline-flex',
            alignItems: 'center',
            gap: 6,
          }}
        >
          <Icon name="refresh" size={14} /> Retry
        </button>
      )}
    </div>
  );
}

export function EmptyState({ message }: { message: string }) {
  return (
    <div
      style={{
        padding: '40px 20px',
        textAlign: 'center',
        color: t.ink4,
        fontSize: 13,
        fontWeight: 600,
      }}
    >
      {message}
    </div>
  );
}

/* ------------------------------------------------------------------ buttons */

export function PrimaryButton(
  props: React.ButtonHTMLAttributes<HTMLButtonElement> & { children: React.ReactNode },
) {
  const { children, style, ...rest } = props;
  return (
    <button
      className="tap"
      {...rest}
      style={{
        border: 'none',
        background: 'linear-gradient(180deg,#3BC2F5,#1FB6F0)',
        color: '#fff',
        padding: '8px 14px',
        borderRadius: 10,
        fontSize: 12.5,
        fontWeight: 700,
        cursor: 'pointer',
        display: 'inline-flex',
        alignItems: 'center',
        gap: 6,
        boxShadow: '0 6px 14px -6px rgba(31,182,240,0.55)',
        opacity: rest.disabled ? 0.6 : 1,
        ...style,
      }}
    >
      {children}
    </button>
  );
}

export function GhostButton(
  props: React.ButtonHTMLAttributes<HTMLButtonElement> & { children: React.ReactNode },
) {
  const { children, style, ...rest } = props;
  return (
    <button
      className="tap"
      {...rest}
      style={{
        border: `1px solid ${t.line}`,
        background: t.surface,
        color: t.ink2,
        padding: '8px 14px',
        borderRadius: 10,
        fontSize: 12.5,
        fontWeight: 700,
        cursor: 'pointer',
        display: 'inline-flex',
        alignItems: 'center',
        gap: 6,
        opacity: rest.disabled ? 0.6 : 1,
        ...style,
      }}
    >
      {children}
    </button>
  );
}
