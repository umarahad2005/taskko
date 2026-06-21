import '../models/admin_metrics.dart';
import '../models/admin_settings.dart';
import '../models/admin_user.dart';
import '../models/ai_insights.dart';
import '../models/moderation_item.dart';

/// Admin console boundary (SRS FR-11). The real impl calls `/api/admin/*`
/// (admin-claim enforced server-side); the mock returns sample data.
abstract interface class AdminRepository {
  /// Dashboard KPIs + aggregates (FR-11.3).
  Future<AdminMetrics> metrics();

  /// User list, optionally filtered/searched (FR-11.4).
  Future<List<AdminUser>> users({String filter = 'all', String query = ''});

  /// Apply a moderation/admin action to a user; returns the updated row.
  /// action: 'suspend' | 'reinstate' | 'grant_points' (points required for grant).
  Future<AdminUser> userAction({required String userId, required String action, int? points});

  /// Create a new user account (Auth + Firestore profile); returns the new row.
  Future<AdminUser> createUser({
    required String name,
    required String email,
    required String password,
    int points = 0,
    String plan = 'free',
  });

  /// Update an existing user's profile/identity; returns the updated row. Only
  /// the non-null fields are changed. `status`: 'active' | 'flagged' | 'suspended'.
  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
    int? points,
    String? plan,
    String? status,
  });

  /// Permanently delete a user account (Auth + Firestore profile).
  Future<void> deleteUser(String userId);

  /// Moderation queue, filtered by severity ('all'|'low'|'medium'|'high') (FR-11.5).
  Future<List<ModerationItem>> moderationQueue({String severity = 'all'});

  /// Resolve a moderation item; action: 'dismiss' | 'warn' | 'suspend' (FR-11.5).
  Future<ModerationItem> moderationAction({required String itemId, required String action});

  /// Gemini usage / quality / prompt insights (FR-11.6).
  Future<AiInsights> aiInsights();

  /// Feature flags + admin team (FR-11.8).
  Future<AdminSettings> settings();

  /// Toggle one or more feature flags; returns the merged settings (FR-11.8).
  Future<AdminSettings> updateFlags(Map<String, bool> flags);
}
