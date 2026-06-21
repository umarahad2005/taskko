import '../../models/admin_metrics.dart';
import '../../models/admin_settings.dart';
import '../../models/admin_user.dart';
import '../../models/ai_insights.dart';
import '../../models/moderation_item.dart';
import '../admin_repository.dart';
import 'admin_api_client.dart';

/// Real admin console repository — calls the backend `/api/admin/*` routes.
class AdminRepositoryHttp implements AdminRepository {
  AdminRepositoryHttp(this._api);

  final AdminApiClient _api;

  @override
  Future<AdminMetrics> metrics() async {
    final json = await _api.getJson('/api/admin/metrics');
    return AdminMetrics.fromJson(json);
  }

  @override
  Future<List<AdminUser>> users({String filter = 'all', String query = ''}) async {
    final params = <String, String>{'filter': filter};
    final q = query.trim();
    if (q.isNotEmpty) params['q'] = q;
    final json = await _api.getJson('/api/admin/users', query: params);
    return ((json['users'] as List?) ?? const [])
        .whereType<Map>()
        .map((m) => AdminUser.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<AdminUser> userAction({required String userId, required String action, int? points}) async {
    final json = await _api.postJson('/api/admin/users', {
      'userId': userId,
      'action': action,
      'points': ?points,
    });
    return _userFrom(json);
  }

  @override
  Future<AdminUser> createUser({
    required String name,
    required String email,
    required String password,
    int points = 0,
    String plan = 'free',
  }) async {
    final json = await _api.postJson('/api/admin/users', {
      'action': 'create',
      'name': name,
      'email': email,
      'password': password,
      'points': points,
      'plan': plan,
    });
    return _userFrom(json);
  }

  @override
  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
    int? points,
    String? plan,
    String? status,
  }) async {
    final json = await _api.postJson('/api/admin/users', {
      'action': 'update',
      'userId': userId,
      'name': ?name,
      'email': ?email,
      'points': ?points,
      'plan': ?plan,
      'status': ?status,
    });
    return _userFrom(json);
  }

  @override
  Future<void> deleteUser(String userId) =>
      _api.postJson('/api/admin/users', {'action': 'delete', 'userId': userId});

  AdminUser _userFrom(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    if (user == null) {
      throw StateError('Malformed response from admin users endpoint');
    }
    return AdminUser.fromJson(user);
  }

  @override
  Future<List<ModerationItem>> moderationQueue({String severity = 'all'}) async {
    final json = await _api.getJson('/api/admin/moderation', query: {'severity': severity});
    return ((json['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((m) => ModerationItem.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<ModerationItem> moderationAction({required String itemId, required String action}) async {
    final json = await _api.postJson('/api/admin/moderation', {'itemId': itemId, 'action': action});
    final item = (json['item'] as Map?)?.cast<String, dynamic>();
    if (item == null) {
      throw StateError('Malformed response from admin moderation endpoint');
    }
    return ModerationItem.fromJson(item);
  }

  @override
  Future<AiInsights> aiInsights() async {
    final json = await _api.getJson('/api/admin/ai-insights');
    return AiInsights.fromJson(json);
  }

  @override
  Future<AdminSettings> settings() async {
    final json = await _api.getJson('/api/admin/settings');
    return AdminSettings.fromJson(json);
  }

  @override
  Future<AdminSettings> updateFlags(Map<String, bool> flags) async {
    final json = await _api.patchJson('/api/admin/settings', {'flags': flags});
    return AdminSettings.fromJson(json);
  }
}
