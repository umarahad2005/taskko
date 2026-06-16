import '../models/admin_metrics.dart';
import '../models/admin_user.dart';

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
}
