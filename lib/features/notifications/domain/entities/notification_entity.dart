enum NotificationType {
  system,
  transaction,
  goal,
  reminder,
  security,
}

enum NotificationStatus {
  unread,
  read,
  archived,
}

class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    NotificationStatus? status,
  }) {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

