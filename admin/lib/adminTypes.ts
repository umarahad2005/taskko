/**
 * lib/adminTypes.ts — shared response types for the admin UI.
 *
 * These mirror the JSON shapes returned by /api/admin/* (see API_CONTRACTS.md
 * and pages/api/admin/*). Kept on the client so the React sections are typed.
 */

export interface AdminMetrics {
  kpis: {
    dau: number;
    signupsToday: number;
    activeStreaks: number;
    aiCallsToday: number;
    proConversions: number;
    avgTasksPerUser: number;
  };
  engagement: { day: string; dau: number }[];
  rankDistribution: { rank: string; count: number }[];
  topGoals: { goal: string; users: number }[];
  activityFeed: { type: string; text: string; at: string }[];
  stub?: boolean;
}

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  plan: 'free' | 'pro';
  rank: string;
  points: number;
  status: 'active' | 'flagged' | 'suspended';
}

export type UserFilter = 'all' | 'pro' | 'free' | 'flagged' | 'suspended';
export type UserAction = 'suspend' | 'reinstate' | 'grant_points';

export interface ModerationItem {
  id: string;
  targetUser: string;
  reason: string;
  severity: 'low' | 'medium' | 'high';
  status: 'open' | 'dismissed' | 'warned' | 'suspended';
  createdAt: string;
}

export type Severity = 'all' | 'low' | 'medium' | 'high';
export type ModerationAction = 'dismiss' | 'warn' | 'suspend';

export interface AiInsights {
  usage: { callsToday: number; calls7d: number; avgLatencyMs: number; fallbackRate: number };
  costUsd: { today: number; month: number };
  quality: { feature: string; good: number; fallback: number }[];
  stuckPhrases: string[];
  recentPrompts: { feature: string; goal?: string; message?: string; at: string }[];
  stub?: boolean;
}

export interface AdminMember {
  email: string;
  role: 'owner' | 'admin';
}

export interface AdminSettings {
  flags: Record<string, boolean>;
  adminTeam: AdminMember[];
  stub?: boolean;
}
