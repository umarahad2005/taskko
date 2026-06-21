import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../config/backend_config.dart';
import 'ai_api_client.dart' show AiApiException;

/// Thin client for the admin `/api/admin/*` routes. Attaches the caller's
/// Firebase ID token; the backend enforces the `admin` custom claim (FR-11.9),
/// so a non-admin token is rejected with 403 server-side (defence in depth).
class AdminApiClient {
  AdminApiClient({http.Client? client, FirebaseAuth? auth})
      : _client = client ?? http.Client(),
        _auth = auth ?? FirebaseAuth.instance;

  final http.Client _client;
  final FirebaseAuth _auth;

  Future<String> _token() async {
    final user = _auth.currentUser;
    if (user == null) throw AiApiException('Please sign in.', retryable: false);
    return (await user.getIdToken())!;
  }

  Future<Map<String, dynamic>> getJson(String path, {Map<String, String>? query}) async {
    final token = await _token();
    final uri = Uri.parse('${BackendConfig.baseUrl}$path').replace(queryParameters: query);
    late final http.Response res;
    try {
      res = await _client.get(uri, headers: {'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 30));
    } catch (_) {
      throw AiApiException('Network error — check your connection.', retryable: true);
    }
    return _decode(res);
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final token = await _token();
    late final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('${BackendConfig.baseUrl}$path'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw AiApiException('Network error — check your connection.', retryable: true);
    }
    return _decode(res);
  }

  Future<Map<String, dynamic>> patchJson(String path, Map<String, dynamic> body) async {
    final token = await _token();
    late final http.Response res;
    try {
      res = await _client
          .patch(
            Uri.parse('${BackendConfig.baseUrl}$path'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw AiApiException('Network error — check your connection.', retryable: true);
    }
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final decoded = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body);
    final json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) return json;
    if (res.statusCode == 403) {
      throw AiApiException('Admin access required for this account.', retryable: false);
    }
    final msg = (json['error'] as String?) ?? 'Request failed (${res.statusCode}).';
    throw AiApiException(msg, retryable: res.statusCode >= 500);
  }
}
