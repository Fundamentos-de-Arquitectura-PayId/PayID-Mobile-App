import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotificationsByUser(String userId);
  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String message,
    required int type,
  });
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient apiClient;

  NotificationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    final response = await apiClient.get(ApiConfig.notificationsByUser(userId));
    if (response is List) {
      return response
          .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  @override
  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String message,
    required int type,
  }) async {
    final response = await apiClient.post(
      ApiConfig.notifications,
      data: {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
      },
    );
    return NotificationModel.fromJson(Map<String, dynamic>.from(response));
  }
}

