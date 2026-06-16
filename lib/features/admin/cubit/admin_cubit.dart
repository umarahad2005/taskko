import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/admin_metrics.dart';
import '../../../models/admin_user.dart';
import '../../../repositories/admin_repository.dart';

/// Drives the in-app admin console (FR-11): dashboard metrics + user management.
class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._repo) : super(const AdminState());

  final AdminRepository _repo;

  Future<void> loadDashboard() async {
    emit(state.copyWith(metricsStatus: ViewStatus.loading, error: null));
    try {
      final m = await _repo.metrics();
      emit(state.copyWith(metricsStatus: ViewStatus.success, metrics: m));
    } catch (e) {
      emit(state.copyWith(metricsStatus: ViewStatus.failure, error: e.toString()));
    }
  }

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
}

class AdminState extends Equatable {
  const AdminState({
    this.metricsStatus = ViewStatus.initial,
    this.metrics,
    this.usersStatus = ViewStatus.initial,
    this.users = const [],
    this.filter = 'all',
    this.query = '',
    this.error,
    this.busyUserId,
  });

  final ViewStatus metricsStatus;
  final AdminMetrics? metrics;
  final ViewStatus usersStatus;
  final List<AdminUser> users;
  final String filter;
  final String query;
  final String? error;
  final String? busyUserId;

  AdminState copyWith({
    ViewStatus? metricsStatus,
    AdminMetrics? metrics,
    ViewStatus? usersStatus,
    List<AdminUser>? users,
    String? filter,
    String? query,
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
      error: error,
      busyUserId: clearBusy ? null : (busyUserId ?? this.busyUserId),
    );
  }

  @override
  List<Object?> get props =>
      [metricsStatus, metrics, usersStatus, users, filter, query, error, busyUserId];
}
