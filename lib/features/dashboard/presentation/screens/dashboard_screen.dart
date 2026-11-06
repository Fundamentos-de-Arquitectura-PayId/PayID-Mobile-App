import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_badge.dart';
import '../../../../core/widgets/payid_card.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:payid_mobile/features/documents/domain/entities/document_entity.dart';
import 'package:payid_mobile/features/documents/presentation/controllers/documents_controller.dart';
import 'package:payid_mobile/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:payid_mobile/features/payments/presentation/controllers/payments_controller.dart';
import 'package:payid_mobile/features/wallet/presentation/controllers/wallet_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final walletState = ref.watch(walletControllerProvider);
    final docsState = ref.watch(documentsControllerProvider);
    final paymentsState = ref.watch(paymentsControllerProvider);
    final notifsState = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait<void>([
              ref.read(walletControllerProvider.notifier).loadWallet(),
              ref.read(documentsControllerProvider.notifier).loadDocuments(forceRefresh: true),
              ref.read(paymentsControllerProvider.notifier).loadPayments(),
              ref.read(notificationsControllerProvider.notifier).loadNotifications(),
            ]);
          },
          color: AppColors.primaryInstitutional,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con Saludo Personalizado
                _buildHeader(context, user),
                const SizedBox(height: AppDimensions.space24),

                // Notificación pendiente / Alerta urgente (si existe)
                if (notifsState.unreadCount > 0) ...[
                  _buildNotificationAlert(context, notifsState),
                  const SizedBox(height: AppDimensions.space20),
                ],

                // Resumen de Billetera (Saldo disponible en PEN)
                _buildWalletCard(context, walletState),
                const SizedBox(height: AppDimensions.space24),

                // Accesos Rápidos
                Text('Accesos Rápidos', style: AppTypography.heading3),
                const SizedBox(height: AppDimensions.space12),
                _buildQuickActions(context),
                const SizedBox(height: AppDimensions.space32),

                // Documentos Recientes
                _buildRecentDocuments(context, docsState),
                const SizedBox(height: AppDimensions.space32),

                // Últimos Movimientos
                _buildRecentTransactions(context, paymentsState),
                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.firstName ?? "Usuario"}',
              style: AppTypography.heading2.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 2),
            Text(
              'Bienvenido a tu ecosistema PayID',
              style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        InkWell(
          onTap: () => context.push('/notifications'),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              LucideIcons.bell,
              size: AppDimensions.iconControl,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationAlert(BuildContext context, dynamic notifsState) {
    final firstUnread = notifsState.notifications.firstWhere(
      (n) => n.status.index == 0, // unread
      orElse: () => notifsState.notifications.first,
    );

    return PayIdSecurityCard(
      title: 'Aviso Importante',
      message: firstUnread.title,
      type: SecurityCardType.info,
      actionLabel: 'Ver alertas (${notifsState.unreadCount})',
      onAction: () => context.push('/notifications'),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletState walletState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Total en Billetera',
                style: AppTypography.helper.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const PayIdBadge(
                text: 'PEN (S/)',
                variant: PayIdBadgeVariant.brand,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            CurrencyFormatter.format(walletState.totalPaymentBalance),
            style: AppTypography.heading1.copyWith(
              color: AppColors.ink,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transporte: ${CurrencyFormatter.format(walletState.totalTransportBalance)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.petroleum,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => context.push('/wallet'),
                child: Row(
                  children: [
                    Text(
                      'Ver billetera',
                      style: AppTypography.helper.copyWith(
                        color: AppColors.primaryInstitutional,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: AppColors.primaryInstitutional,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: 'Recargar Transporte',
            icon: LucideIcons.bus,
            color: AppColors.primaryInstitutional,
            onTap: () => context.push('/wallet/recharge'),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: _QuickActionButton(
            label: 'Pagar Deudas',
            icon: LucideIcons.receipt,
            color: AppColors.petroleum,
            onTap: () => context.push('/wallet/pay-debt'),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),
        Expanded(
          child: _QuickActionButton(
            label: 'Registrar Documento',
            icon: LucideIcons.filePlus,
            color: AppColors.primaryDeep,
            onTap: () => context.push('/documents/register'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDocuments(BuildContext context, DocumentsState docsState) {
    final recentDocs = docsState.documents.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Documentos Personales', style: AppTypography.heading3),
            TextButton(
              onPressed: () => context.push('/documents'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        if (recentDocs.isEmpty) ...[
          PayIdInfoCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Icon(LucideIcons.fileText, size: 32, color: AppColors.outline),
                    const SizedBox(height: 8),
                    Text('No tienes documentos registrados', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          ...recentDocs.map((doc) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: PayIdInfoCard(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: InkWell(
                  onTap: () => context.push('/documents/detail', extra: doc),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.mint50,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                        ),
                        child: const Icon(
                          LucideIcons.fileCheck,
                          size: AppDimensions.iconControl,
                          color: AppColors.primaryInstitutional,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.typeName, style: AppTypography.label.copyWith(fontSize: 14)),
                            Text('N° ${doc.documentNumber}', style: AppTypography.helper),
                          ],
                        ),
                      ),
                      PayIdBadge(
                        text: doc.status == DocumentStatus.verified ? 'Verificado' : 'En validación',
                        variant: doc.status == DocumentStatus.verified
                            ? PayIdBadgeVariant.success
                            : PayIdBadgeVariant.warning,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, PaymentsState paymentsState) {
    final recent = paymentsState.payments.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Últimos Movimientos', style: AppTypography.heading3),
            TextButton(
              onPressed: () => context.push('/payments/history'),
              child: const Text('Historial'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space8),
        if (recent.isEmpty) ...[
          PayIdInfoCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No hay movimientos recientes', style: AppTypography.bodySmall),
              ),
            ),
          ),
        ] else ...[
          ...recent.map((tx) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: PayIdInfoCard(
                padding: const EdgeInsets.all(AppDimensions.space12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.mint50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.arrowUpRight,
                        size: 18,
                        color: AppColors.primaryInstitutional,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.servicio, style: AppTypography.label.copyWith(fontSize: 14)),
                          Text(DateFormatter.toShortDate(tx.fecha), style: AppTypography.helper),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(tx.monto),
                      style: AppTypography.label.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          constraints: const BoxConstraints(minHeight: 88),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.helper.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

