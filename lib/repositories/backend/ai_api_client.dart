import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../config/backend_config.dart';

/// Error from the backend AI API, carrying the `{error, retryable}` envelope
/// (SRS §6) so cubits can show a friendly message + Retry (FR-5.4/7.6).
class AiApiException implements Exception {
  AiApiException(this.message, {this.retryable = true});
  final String message;
  final bool retryable;
  @override
  String toString() => message;
}

/// Thin client for the Vercel `/api/ai/*` routes. Attaches the caller's Firebase
/// ID token as a Bearer header (the backend verifies it via the Admin SDK).
class AiApiClient {
  AiApiClient({http.Client? client, FirebaseAuth? auth})
      : _client = client ?? http.Client(),
        _auth = auth ?? FirebaseAuth.instance;

  final http.Client _client;
  final FirebaseAuth _auth;

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AiApiException('Please sign in to use Tako.', retryable: false);
    }
    final token = await user.getIdToken();

    late final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('${BackendConfig.baseUrl}$path'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw AiApiException('Network error — check your connection.', retryable: true);
    }

    final decoded = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body);
    final json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) return json;

    final msg = (json['error'] as String?) ?? 'Request failed (${res.statusCode}).';
    final retryable = (json['retryable'] as bool?) ?? (res.statusCode >= 500);
    throw AiApiException(msg, retryable: retryable);
  }
}
