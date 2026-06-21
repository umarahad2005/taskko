/// Feature flags + admin team for the admin console (FR-11.8). Mirrors
/// `/api/admin/settings`. Flags are an ordered map of key → enabled.
class AdminSettings {
  const AdminSettings({required this.flags, required this.adminTeam});

  final Map<String, bool> flags;
  final List<AdminMember> adminTeam;

  factory AdminSettings.fromJson(Map<String, dynamic> j) {
    final rawFlags = (j['flags'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AdminSettings(
      flags: {for (final e in rawFlags.entries) e.key: e.value == true},
      adminTeam: ((j['adminTeam'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => AdminMember.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }

  AdminSettings copyWith({Map<String, bool>? flags}) =>
      AdminSettings(flags: flags ?? this.flags, adminTeam: adminTeam);

  /// Human-readable label + description for known flag keys (falls back to the
  /// raw key). Matches the web admin's SettingsSection labels.
  static const Map<String, (String, String)> labels = {
    'aiBreakdownEnabled': ('AI goal breakdown', 'Let students break goals into tasks with Tako.'),
    'socialSharingEnabled': ('Social sharing', 'Share report cards and badges to socials.'),
    'moodCheckInEnabled': ('Mood-aware sessions', 'Mood picker rewrites the next session length.'),
    'squadLeaderboardEnabled': ('Squad leaderboards', 'Show the weekly squad leaderboard in the Hub.'),
    'maintenanceMode': ('Maintenance mode', 'Show a maintenance notice and pause writes.'),
  };
}

class AdminMember {
  const AdminMember({required this.email, required this.role});
  final String email;
  final String role;

  factory AdminMember.fromJson(Map<String, dynamic> j) => AdminMember(
        email: (j['email'] as String?) ?? '',
        role: (j['role'] as String?) ?? 'admin',
      );
}
