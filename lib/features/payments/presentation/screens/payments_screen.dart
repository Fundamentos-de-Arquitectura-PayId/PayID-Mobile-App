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
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../controllers/payments_controller.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentsControllerProvider);
    final notifier = ref.read(paymentsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: AppDimensions.iconControl),
            tooltip: 'Actualizar',
            onPressed: () => notifier.loadPayments(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/new'),
        backgroundColor: AppColors.primaryInstitutional,
        foregroundColor: AppColors.white,
        icon: const Icon(LucideIcons.plus, size: AppDimensions.iconControl),
        label: Text('Nuevo Pago', style: AppTypography.label.copyWith(color: AppColors.white)),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryInstitutional,
                  ),
                ),
              )
            : state.payments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.space32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.mint50,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
                            ),
                            child: const Icon(
                              LucideIcons.receipt,
                              size: 32,
                              color: AppColors.primaryInstitutional,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space16),
                          Text(
                            'Sin historial de transacciones',
                            style: AppTypography.heading3.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            'Tus pagos de servicios, deudas y recargas aparecerán aquí.',
                            style: AppTypography.helper,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.space24),
                          PayIdButton(
                            text: 'Realizar un pago',
                            isFullWidth: false,
                            onPressed: () => context.push('/payments/new'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    itemCount: state.payments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                    itemBuilder: (context, index) {
                      final item = state.payments[index];

                      return PayIdInfoCard(
                        padding: const EdgeInsets.all(AppDimensions.space16),
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
                                LucideIcons.receipt,
                                size: AppDimensions.iconControl,
                                color: AppColors.primaryInstitutional,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.space12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.servicio,
                                    style: AppTypography.label.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormatter.toDateTime(item.fecha),
                                    style: AppTypography.helper,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(item.monto),
                                  style: AppTypography.label.copyWith(
                                    fontSize: 15,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const PayIdBadge(
                                  text: 'Completado',
                                  variant: PayIdBadgeVariant.success,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

