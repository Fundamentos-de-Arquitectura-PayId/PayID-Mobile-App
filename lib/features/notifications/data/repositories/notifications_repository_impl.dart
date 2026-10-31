import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final HiveStorageService hiveStorage;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.hiveStorage,
  });

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final list = await remoteDataSource.getNotificationsByUser(userId);
    final readIds = hiveStorage.getReadNotificationIds().toSet();

    return list.map((item) {
      if (readIds.contains(item.id)) {
        return item.copyWith(status: NotificationStatus.read);
      }
      return item;
    }).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final readIds = hiveStorage.getReadNotificationIds().toSet();
    readIds.add(notificationId);
    await hiveStorage.saveReadNotificationIds(readIds.toList());
  }
}

