enum TicketPriority {
  low, // 0
  medium, // 1
  high, // 2
  critical, // 3
}

enum TicketStatus {
  open, // 0
  inProgress, // 1
  resolved, // 2
  closed, // 3
}

class SupportTicketEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;

  const SupportTicketEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
  });
}

