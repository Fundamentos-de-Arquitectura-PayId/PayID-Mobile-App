import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_badge.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../domain/entities/notification_entity.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.security:
        return LucideIcons.shieldAlert;
      case NotificationType.transaction:
        return LucideIcons.arrowUpRight;
      case NotificationType.reminder:
        return LucideIcons.calendarClock;
      case NotificationType.goal:
        return LucideIcons.target;
      case NotificationType.system:
        return LucideIcons.bell;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.security:
        return AppColors.error;
      case NotificationType.transaction:
        return AppColors.petroleum;
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.goal:
        return AppColors.primaryInstitutional;
      case NotificationType.system:
        return AppColors.info;
    }
  }

  String _labelForType(NotificationType type) {
    switch (type) {
      case NotificationType.security:
        return 'Seguridad';
      case NotificationType.transaction:
        return 'Operación';
      case NotificationType.reminder:
        return 'Trámite / Alerta';
      case NotificationType.goal:
        return 'Meta';
      case NotificationType.system:
        return 'Sistema';
    }
  }

  void _showNotificationDetail(
    BuildContext context,
    WidgetRef ref,
    NotificationEntity notification,
  ) {
    ref.read(notificationsControllerProvider.notifier).markAsRead(notification.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusPanel),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _colorForType(notification.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                  ),
                  child: Icon(
                    _iconForType(notification.type),
                    color: _colorForType(notification.type),
                    size: AppDimensions.iconNavigation,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTypography.heading3.copyWith(fontSize: 18),
                      ),
                      Text(
                        DateFormatter.toDateTime(notification.createdAt),
                        style: AppTypography.helper,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
            const Divider(),
            const SizedBox(height: AppDimensions.space16),
            Text(
              notification.message,
              style: AppTypography.body.copyWith(height: 1.5),
            ),
            const SizedBox(height: AppDimensions.space24),
            PayIdButton(
              text: 'Entendido',
              size: PayIdButtonSize.m,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final notifier = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: AppDimensions.iconControl),
            tooltip: 'Actualizar',
            onPressed: () => notifier.loadNotifications(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtros horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todas',
                    isSelected: state.selectedFilter == null,
                    onTap: () => notifier.setFilter(null),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _FilterChip(
                    label: 'Seguridad',
                    isSelected: state.selectedFilter == NotificationType.security,
                    onTap: () => notifier.setFilter(NotificationType.security),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _FilterChip(
                    label: 'Transacciones',
                    isSelected: state.selectedFilter == NotificationType.transaction,
                    onTap: () => notifier.setFilter(NotificationType.transaction),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _FilterChip(
                    label: 'Trámites',
                    isSelected: state.selectedFilter == NotificationType.reminder,
                    onTap: () => notifier.setFilter(NotificationType.reminder),
                  ),
                ],
              ),
            ),

            // Lista de notificaciones
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryInstitutional,
                        ),
                      ),
                    )
                  : state.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.space24),
                            child: PayIdSecurityCard(
                              title: 'Error de carga',
                              message: state.errorMessage!,
                              type: SecurityCardType.warning,
                              actionLabel: 'Reintentar',
                              onAction: () => notifier.loadNotifications(),
                            ),
                          ),
                        )
                      : state.filteredNotifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.line.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.bellOff,
                                      size: 32,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  const SizedBox(height: AppDimensions.space16),
                                  Text(
                                    'No tienes notificaciones pendientes',
                                    style: AppTypography.heading3.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: AppDimensions.space4),
                                  Text(
                                    'Aquí verás avisos sobre tus documentos y pagos',
                                    style: AppTypography.helper,
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppDimensions.space16),
                              itemCount: state.filteredNotifications.length,
                              separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                              itemBuilder: (context, index) {
                                final item = state.filteredNotifications[index];
                                final isUnread = item.status == NotificationStatus.unread;

                                return PayIdInfoCard(
                                  backgroundColor: isUnread ? AppColors.white : AppColors.canvas,
                                  padding: const EdgeInsets.all(AppDimensions.space16),
                                  child: InkWell(
                                    onTap: () => _showNotificationDetail(context, ref, item),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _colorForType(item.type).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                                          ),
                                          child: Icon(
                                            _iconForType(item.type),
                                            color: _colorForType(item.type),
                                            size: AppDimensions.iconControl,
                                          ),
                                        ),
                                        const SizedBox(width: AppDimensions.space12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  PayIdBadge(
                                                    text: _labelForType(item.type),
                                                    variant: item.type == NotificationType.security
                                                        ? PayIdBadgeVariant.error
                                                        : PayIdBadgeVariant.info,
                                                  ),
                                                  Text(
                                                    DateFormatter.timeAgo(item.createdAt),
                                                    style: AppTypography.helper.copyWith(fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: AppDimensions.space8),
                                              Text(
                                                item.title,
                                                style: AppTypography.label.copyWith(
                                                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: AppDimensions.space4),
                                              Text(
                                                item.message,
                                                style: AppTypography.bodySmall.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isUnread) ...[
                                          const SizedBox(width: AppDimensions.space8),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryInstitutional,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryInstitutional : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primaryInstitutional : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            fontSize: 13,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

