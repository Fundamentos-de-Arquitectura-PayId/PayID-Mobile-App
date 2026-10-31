import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.status,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notificación',
      message: json['message']?.toString() ?? '',
      type: _mapType(json['type']),
      status: _mapStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': _typeToInt(type),
      'status': _statusToInt(status),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static NotificationType _mapType(dynamic value) {
    final int val = value is int ? value : int.tryParse(value?.toString() ?? '1') ?? 1;
    switch (val) {
      case 2:
        return NotificationType.transaction;
      case 3:
        return NotificationType.goal;
      case 4:
        return NotificationType.reminder;
      case 5:
        return NotificationType.security;
      case 1:
      default:
        return NotificationType.system;
    }
  }

  static int _typeToInt(NotificationType type) {
    switch (type) {
      case NotificationType.system:
        return 1;
      case NotificationType.transaction:
        return 2;
      case NotificationType.goal:
        return 3;
      case NotificationType.reminder:
        return 4;
      case NotificationType.security:
        return 5;
    }
  }

  static NotificationStatus _mapStatus(dynamic value) {
    final int val = value is int ? value : int.tryParse(value?.toString() ?? '1') ?? 1;
    switch (val) {
      case 2:
        return NotificationStatus.read;
      case 3:
        return NotificationStatus.archived;
      case 1:
      default:
        return NotificationStatus.unread;
    }
  }

  static int _statusToInt(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.unread:
        return 1;
      case NotificationStatus.read:
        return 2;
      case NotificationStatus.archived:
        return 3;
    }
  }
}

