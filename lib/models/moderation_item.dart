import 'package:equatable/equatable.dart';

/// A reported-content row in the admin moderation queue (FR-11.5). Mirrors
/// `/api/admin/moderation` (Firestore `moderation` collection).
class ModerationItem extends Equatable {
  const ModerationItem({
    required this.id,
    required this.targetUser,
    required this.reason,
    required this.severity,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String targetUser;
  final String reason;

  /// 'low' | 'medium' | 'high'
  final String severity;

  /// 'open' | 'dismissed' | 'warned' | 'suspended'
  final String status;
  final String? createdAt;

  bool get isOpen => status == 'open';

  factory ModerationItem.fromJson(Map<String, dynamic> j) => ModerationItem(
        id: (j['id'] as String?) ?? '',
        targetUser: (j['targetUser'] as String?) ?? '',
        reason: (j['reason'] as String?) ?? '',
        severity: (j['severity'] as String?) ?? 'low',
        status: (j['status'] as String?) ?? 'open',
        createdAt: j['createdAt'] as String?,
      );

  ModerationItem copyWith({String? status}) => ModerationItem(
        id: id,
        targetUser: targetUser,
        reason: reason,
        severity: severity,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, targetUser, reason, severity, status, createdAt];
}
