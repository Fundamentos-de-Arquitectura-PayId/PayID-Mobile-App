import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/payid_badge.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../domain/entities/payment_card_entity.dart';
import '../controllers/wallet_controller.dart';

class PayDebtScreen extends ConsumerWidget {
  const PayDebtScreen({super.key});

  Future<void> _payDebt(BuildContext context, WidgetRef ref, PaymentCardEntity card) async {
    final confirmed = await PayIdDialog.showConfirmation(
      context: context,
      title: 'Pagar Deuda de Tarjeta',
      message:
          '¿Deseas pagar la deuda de ${CurrencyFormatter.format(card.debtAmount)} en la tarjeta ${card.brand} (N° ${card.maskedNumber}) con su saldo disponible (${CurrencyFormatter.format(card.balance)})?',
      confirmLabel: 'Confirmar Pago',
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(walletControllerProvider.notifier)
          .payDebt(card.id);

      if (success && context.mounted) {
        PayIdSnackBar.showSuccess(
          context,
          'Deuda cancelada correctamente en ${card.brand}.',
        );
      } else if (context.mounted) {
        PayIdSnackBar.showError(
          context,
          ref.read(walletControllerProvider).errorMessage ??
              'Saldo insuficiente en la tarjeta para cubrir el monto adeudado.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final debtCards = state.paymentCards.where((c) => c.hasDebt).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Pago de Deudas'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PayIdInfoCard(
                title: 'Resumen de Obligaciones',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total adeudado en PayID', style: AppTypography.helper),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(state.totalDebt),
                          style: AppTypography.heading2.copyWith(
                            color: state.totalDebt > 0 ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    PayIdBadge(
                      text: state.totalDebt > 0 ? 'Con deudas' : 'Sin deudas',
                      variant: state.totalDebt > 0
                          ? PayIdBadgeVariant.error
                          : PayIdBadgeVariant.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              if (debtCards.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.successBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.checkCheck,
                            size: 32,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space16),
                        Text(
                          '¡Excelente! Estás al día con tus pagos',
                          style: AppTypography.heading3.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: AppDimensions.space8),
                        Text(
                          'No registras deudas pendientes en ninguna de tus tarjetas asociadas.',
                          style: AppTypography.helper,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text('Tarjetas con Saldo Pendiente', style: AppTypography.heading3),
                const SizedBox(height: AppDimensions.space12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: debtCards.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                  itemBuilder: (context, index) {
                    final card = debtCards[index];
                    final canPayWithBalance = card.balance >= card.debtAmount;

                    return PayIdInfoCard(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${card.brand} •••• ${card.fullNumber.length >= 4 ? card.fullNumber.substring(card.fullNumber.length - 4) : ""}',
                                style: AppTypography.label.copyWith(fontSize: 16),
                              ),
                              PayIdBadge(
                                text: 'Deuda: ${CurrencyFormatter.format(card.debtAmount)}',
                                variant: PayIdBadgeVariant.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Saldo disponible:', style: AppTypography.helper),
                              Text(
                                CurrencyFormatter.format(card.balance),
                                style: AppTypography.label.copyWith(
                                  color: canPayWithBalance ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),

                          if (!canPayWithBalance) ...[
                            Text(
                              'Saldo insuficiente para cubrir esta deuda. Recarga saldo a la tarjeta antes de pagar.',
                              style: AppTypography.helper.copyWith(color: AppColors.error),
                            ),
                            const SizedBox(height: 8),
                          ],

                          PayIdButton(
                            text: 'Pagar con Saldo (${CurrencyFormatter.format(card.debtAmount)})',
                            size: PayIdButtonSize.s,
                            icon: LucideIcons.creditCard,
                            isLoading: state.isOperationInProgress,
                            loadingText: 'Procesando pago...',
                            onPressed: canPayWithBalance
                                ? () => _payDebt(context, ref, card)
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }
}

