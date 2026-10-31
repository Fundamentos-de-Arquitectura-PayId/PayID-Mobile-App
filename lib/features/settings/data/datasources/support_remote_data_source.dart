import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/support_ticket_entity.dart';

class SupportTicketModel extends SupportTicketEntity {
  const SupportTicketModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.priority,
    required super.status,
    required super.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: _intToPriority(json['priority']),
      status: _intToStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static TicketPriority _intToPriority(dynamic val) {
    final v = val is int ? val : int.tryParse(val?.toString() ?? '1') ?? 1;
    switch (v) {
      case 0:
        return TicketPriority.low;
      case 2:
        return TicketPriority.high;
      case 3:
        return TicketPriority.critical;
      case 1:
      default:
        return TicketPriority.medium;
    }
  }

  static TicketStatus _intToStatus(dynamic val) {
    final v = val is int ? val : int.tryParse(val?.toString() ?? '0') ?? 0;
    switch (v) {
      case 1:
        return TicketStatus.inProgress;
      case 2:
        return TicketStatus.resolved;
      case 3:
        return TicketStatus.closed;
      case 0:
      default:
        return TicketStatus.open;
    }
  }
}

class SupportRemoteDataSource {
  final ApiClient apiClient;

  SupportRemoteDataSource({required this.apiClient});

  Future<SupportTicketModel> createTicket({
    required String userId,
    required String title,
    required String description,
    required int priority,
  }) async {
    final response = await apiClient.post(
      ApiConfig.supportTickets,
      data: {
        'userId': userId,
        'title': title,
        'description': description,
        'priority': priority,
      },
    );
    return SupportTicketModel.fromJson(Map<String, dynamic>.from(response));
  }
}
