import 'package:equatable/equatable.dart';

/// A user row in the admin console (FR-11.4). Mirrors `/api/admin/users`:
/// Firebase Auth identity merged with the Firestore `users/{uid}` profile.
class AdminUser extends Equatable {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.rank,
    required this.points,
    required this.status,
  });

  final String id;
  final String name;
  final String email;
  final String plan;
  final String rank;
  final int points;

  /// 'active' | 'flagged' | 'suspended'
  final String status;

  bool get isSuspended => status == 'suspended';

  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        id: (j['id'] as String?) ?? '',
        name: (j['name'] as String?) ?? 'Student',
        email: (j['email'] as String?) ?? '',
        plan: (j['plan'] as String?) ?? 'free',
        rank: (j['rank'] as String?) ?? 'Rookie',
        points: (j['points'] as num?)?.toInt() ?? 0,
        status: (j['status'] as String?) ?? 'active',
      );

  @override
  List<Object?> get props => [id, name, email, plan, rank, points, status];
}
