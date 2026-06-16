import '../../models/admin_metrics.dart';
import '../../models/admin_user.dart';
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
    final user = (json['user'] as Map?)?.cast<String, dynamic>();
    if (user == null) {
      throw StateError('Malformed response from admin users endpoint');
    }
    return AdminUser.fromJson(user);
  }
}
