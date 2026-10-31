import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';

final notificationsRemoteDataSourceProvider = Provider<NotificationsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationsRemoteDataSourceImpl(apiClient: apiClient);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final remote = ref.watch(notificationsRemoteDataSourceProvider);
  final hive = ref.watch(hiveStorageProvider);
  return NotificationsRepositoryImpl(remoteDataSource: remote, hiveStorage: hive);
});

class NotificationsState {
  final bool isLoading;
  final List<NotificationEntity> notifications;
  final String? errorMessage;
  final NotificationType? selectedFilter;

  const NotificationsState({
    this.isLoading = false,
    this.notifications = const [],
    this.errorMessage,
    this.selectedFilter,
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationEntity>? notifications,
    String? errorMessage,
    NotificationType? selectedFilter,
    bool clearFilter = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }

  List<NotificationEntity> get filteredNotifications {
    if (selectedFilter == null) return notifications;
    return notifications.where((n) => n.type == selectedFilter).toList();
  }

  int get unreadCount {
    return notifications.where((n) => n.status == NotificationStatus.unread).length;
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final controller = NotificationsController(repository: repository, userId: user?.id);
  if (user != null) {
    controller.loadNotifications();
  }
  return controller;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsControllerProvider).unreadCount;
});

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsRepository repository;
  final String? userId;

  NotificationsController({
    required this.repository,
    this.userId,
  }) : super(const NotificationsState());

  Future<void> loadNotifications() async {
    if (userId == null || userId!.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await repository.getNotifications(userId!);
      // Ordenar por fecha descendente
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(isLoading: false, notifications: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron cargar las notificaciones.',
      );
    }
  }

  Future<void> markAsRead(String id) async {
    await repository.markAsRead(id);
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(status: NotificationStatus.read);
      }
      return n.copyWith();
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void setFilter(NotificationType? type) {
    if (type == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(selectedFilter: type);
    }
  }
}
