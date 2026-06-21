/// Gemini usage / quality / prompt insights for the admin console (FR-11.6).
/// Mirrors the `/api/admin/ai-insights` response.
class AiInsights {
  const AiInsights({
    required this.callsToday,
    required this.calls7d,
    required this.avgLatencyMs,
    required this.fallbackRate,
    required this.costToday,
    required this.costMonth,
    required this.quality,
    required this.stuckPhrases,
    required this.recentPrompts,
  });

  final int callsToday;
  final int calls7d;
  final int avgLatencyMs;
  final double fallbackRate;
  final double costToday;
  final double costMonth;
  final List<AiQuality> quality;
  final List<String> stuckPhrases;
  final List<AiPrompt> recentPrompts;

  factory AiInsights.fromJson(Map<String, dynamic> j) {
    final usage = (j['usage'] as Map?)?.cast<String, dynamic>() ?? const {};
    final cost = (j['costUsd'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AiInsights(
      callsToday: (usage['callsToday'] as num?)?.toInt() ?? 0,
      calls7d: (usage['calls7d'] as num?)?.toInt() ?? 0,
      avgLatencyMs: (usage['avgLatencyMs'] as num?)?.toInt() ?? 0,
      fallbackRate: (usage['fallbackRate'] as num?)?.toDouble() ?? 0,
      costToday: (cost['today'] as num?)?.toDouble() ?? 0,
      costMonth: (cost['month'] as num?)?.toDouble() ?? 0,
      quality: ((j['quality'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => AiQuality.fromJson(m.cast<String, dynamic>()))
          .toList(),
      stuckPhrases: ((j['stuckPhrases'] as List?) ?? const []).whereType<String>().toList(),
      recentPrompts: ((j['recentPrompts'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => AiPrompt.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class AiQuality {
  const AiQuality({required this.feature, required this.good, required this.fallback});
  final String feature;
  final double good;
  final double fallback;

  factory AiQuality.fromJson(Map<String, dynamic> j) => AiQuality(
        feature: (j['feature'] as String?) ?? 'unknown',
        good: (j['good'] as num?)?.toDouble() ?? 1,
        fallback: (j['fallback'] as num?)?.toDouble() ?? 0,
      );
}

class AiPrompt {
  const AiPrompt({required this.feature, this.at, this.goal, this.message});
  final String feature;
  final String? at;
  final String? goal;
  final String? message;

  String get label => goal ?? message ?? '—';

  factory AiPrompt.fromJson(Map<String, dynamic> j) => AiPrompt(
        feature: (j['feature'] as String?) ?? 'unknown',
        at: j['at'] as String?,
        goal: j['goal'] as String?,
        message: j['message'] as String?,
      );
}
