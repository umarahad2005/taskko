import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches a short, light joke to refresh the user's mood during a break
/// (SRS FR-9). Falls back to a built-in joke offline.
abstract final class JokeService {
  static const _fallback =
      "Why did the student eat his homework?\nBecause the teacher said it was a piece of cake. 🍰";

  static Future<String> random() async {
    try {
      final res = await http
          .get(Uri.parse('https://official-joke-api.appspot.com/random_joke'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final setup = (j['setup'] as String?)?.trim();
        final punchline = (j['punchline'] as String?)?.trim();
        if (setup != null && punchline != null) return '$setup\n\n$punchline';
      }
    } catch (_) {}
    return _fallback;
  }
}
