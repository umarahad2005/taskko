import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/admin_metrics.dart';
import '../../../models/admin_settings.dart';
import '../../../models/admin_user.dart';
import '../../../models/ai_insights.dart';
import '../../../models/moderation_item.dart';
import '../../../repositories/admin_repository.dart';

/// Drives the in-app admin console (FR-11): dashboard metrics, user management,
/// the moderation queue, AI insights, and feature-flag settings — full parity
/// with the web admin so admins have complete control from the phone too.
class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._repo) : super(const AdminState());

  final AdminRepository _repo;

  // --- Dashboard ----------------------------------------------------------
  Future<void> loadDashboard() async {
    emit(state.copyWith(metricsStatus: ViewStatus.loading, error: null));
    try {
      final m = await _repo.metrics();
      emit(state.copyWith(metricsStatus: ViewStatus.success, metrics: m));
    } catch (e) {
      emit(state.copyWith(metricsStatus: ViewStatus.failure, error: e.toString()));
    }
  }

  // --- Users --------------------------------------------------------------
  Future<void> loadUsers() async {
    emit(state.copyWith(usersStatus: ViewStatus.loading, error: null));
    try {
      final users = await _repo.users(filter: state.filter, query: state.query);
      emit(state.copyWith(usersStatus: ViewStatus.success, users: users));
    } catch (e) {
      emit(state.copyWith(usersStatus: ViewStatus.failure, error: e.toString()));
    }
  }

  void setFilter(String filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
    loadUsers();
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  Future<void> act({required String userId, required String action, int? points}) async {
    emit(state.copyWith(busyUserId: userId, error: null));
    try {
      final updated = await _repo.userAction(userId: userId, action: action, points: points);
      final users = state.users.map((u) => u.id == updated.id ? updated : u).toList();
      emit(state.copyWith(users: users, clearBusy: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearBusy: true));
    }
  }

  // --- Moderation ---------------------------------------------------------
  Future<void> loadModeration() async {
    emit(state.copyWith(moderationStatus: ViewStatus.loading, error: null));
    try {
      final items = await _repo.moderationQueue(severity: state.severity);
      emit(state.copyWith(moderationStatus: ViewStatus.success, moderation: items));
    } catch (e) {
      emit(state.copyWith(moderationStatus: ViewStatus.failure, error: e.toString()));
    }
  }

  void setSeverity(String severity) {
    if (severity == state.severity) return;
    emit(state.copyWith(severity: severity));
    loadModeration();
  }

  Future<void> moderate({required String itemId, required String action}) async {
    emit(state.copyWith(busyModId: itemId, error: null));
    try {
      final updated = await _repo.moderationAction(itemId: itemId, action: action);
      final items = state.moderation.map((m) => m.id == updated.id ? updated : m).toList();
      emit(state.copyWith(moderation: items, clearBusyMod: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearBusyMod: true));
    }
  }

  // --- AI insights --------------------------------------------------------
  Future<void> loadAiInsights() async {
    emit(state.copyWith(aiStatus: ViewStatus.loading, error: null));
    try {
      final ai = await _repo.aiInsights();
      emit(state.copyWith(aiStatus: ViewStatus.success, ai: ai));
    } catch (e) {
      emit(state.copyWith(aiStatus: ViewStatus.failure, error: e.toString()));
    }
  }

  // --- Settings (feature flags) ------------------------------------------
  Future<void> loadSettings() async {
    emit(state.copyWith(settingsStatus: ViewStatus.loading, error: null));
    try {
      final s = await _repo.settings();
      emit(state.copyWith(settingsStatus: ViewStatus.success, settings: s));
    } catch (e) {
      emit(state.copyWith(settingsStatus: ViewStatus.failure, error: e.toString()));
    }
  }

  Future<void> toggleFlag(String key) async {
    final current = state.settings;
    if (current == null) return;
    final next = !(current.flags[key] ?? false);
    // Optimistic update so the switch flips immediately.
    final optimistic = {...current.flags, key: next};
    emit(state.copyWith(settings: current.copyWith(flags: optimistic), savingFlag: key, error: null));
    try {
      final saved = await _repo.updateFlags({key: next});
      emit(state.copyWith(settings: saved, clearSavingFlag: true));
    } catch (e) {
      // Revert on failure.
      emit(state.copyWith(settings: current, error: e.toString(), clearSavingFlag: true));
    }
  }
}

class AdminState extends Equatable {
  const AdminState({
    this.metricsStatus = ViewStatus.initial,
    this.metrics,
    this.usersStatus = ViewStatus.initial,
    this.users = const [],
    this.filter = 'all',
    this.query = '',
    this.moderationStatus = ViewStatus.initial,
    this.moderation = const [],
    this.severity = 'all',
    this.busyModId,
    this.aiStatus = ViewStatus.initial,
    this.ai,
    this.settingsStatus = ViewStatus.initial,
    this.settings,
    this.savingFlag,
    this.error,
    this.busyUserId,
  });

  final ViewStatus metricsStatus;
  final AdminMetrics? metrics;
  final ViewStatus usersStatus;
  final List<AdminUser> users;
  final String filter;
  final String query;
  final ViewStatus moderationStatus;
  final List<ModerationItem> moderation;
  final String severity;
  final String? busyModId;
  final ViewStatus aiStatus;
  final AiInsights? ai;
  final ViewStatus settingsStatus;
  final AdminSettings? settings;
  final String? savingFlag;
  final String? error;
  final String? busyUserId;

  AdminState copyWith({
    ViewStatus? metricsStatus,
    AdminMetrics? metrics,
    ViewStatus? usersStatus,
    List<AdminUser>? users,
    String? filter,
    String? query,
    ViewStatus? moderationStatus,
    List<ModerationItem>? moderation,
    String? severity,
    String? busyModId,
    bool clearBusyMod = false,
    ViewStatus? aiStatus,
    AiInsights? ai,
    ViewStatus? settingsStatus,
    AdminSettings? settings,
    String? savingFlag,
    bool clearSavingFlag = false,
    String? error,
    String? busyUserId,
    bool clearBusy = false,
  }) {
    return AdminState(
      metricsStatus: metricsStatus ?? this.metricsStatus,
      metrics: metrics ?? this.metrics,
      usersStatus: usersStatus ?? this.usersStatus,
      users: users ?? this.users,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderation: moderation ?? this.moderation,
      severity: severity ?? this.severity,
      busyModId: clearBusyMod ? null : (busyModId ?? this.busyModId),
      aiStatus: aiStatus ?? this.aiStatus,
      ai: ai ?? this.ai,
      settingsStatus: settingsStatus ?? this.settingsStatus,
      settings: settings ?? this.settings,
      savingFlag: clearSavingFlag ? null : (savingFlag ?? this.savingFlag),
      error: error,
      busyUserId: clearBusy ? null : (busyUserId ?? this.busyUserId),
    );
  }

  @override
  List<Object?> get props => [
        metricsStatus,
        metrics,
        usersStatus,
        users,
        filter,
        query,
        moderationStatus,
        moderation,
        severity,
        busyModId,
        aiStatus,
        ai,
        settingsStatus,
        settings,
        savingFlag,
        error,
        busyUserId,
      ];
}
