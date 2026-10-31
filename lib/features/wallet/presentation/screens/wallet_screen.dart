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
import '../../domain/entities/payment_card_entity.dart';
import '../../domain/entities/transport_card_entity.dart';
import '../controllers/wallet_controller.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);
    final notifier = ref.read(walletControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Billetera Digital'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: AppDimensions.iconControl),
            tooltip: 'Actualizar',
            onPressed: () => notifier.loadWallet(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notifier.loadWallet(),
          color: AppColors.primaryInstitutional,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumen general de saldo (Information Card)
                _buildTotalBalanceCard(state),
                const SizedBox(height: AppDimensions.space24),

                // Accesos rápidos
                Row(
                  children: [
                    Expanded(
                      child: PayIdButton(
                        text: 'Recargar Transporte',
                        icon: LucideIcons.bus,
                        size: PayIdButtonSize.m,
                        onPressed: () => context.push('/wallet/recharge'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: PayIdButton(
                        text: 'Pagar Deudas',
                        icon: LucideIcons.receipt,
                        variant: PayIdButtonVariant.secondary,
                        size: PayIdButtonSize.m,
                        onPressed: () => context.push('/wallet/pay-debt'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space24),

                if (state.errorMessage != null) ...[
                  PayIdSecurityCard(
                    title: 'Aviso de billetera',
                    message: state.errorMessage!,
                    type: SecurityCardType.warning,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ],

                // Sección 1: Tarjetas de Pago
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tarjetas de Pago', style: AppTypography.heading3),
                    TextButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Agregar'),
                      onPressed: () => context.push('/wallet/add-payment-card'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                if (state.paymentCards.isEmpty) ...[
                  PayIdInfoCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.creditCard, size: 36, color: AppColors.outline),
                            const SizedBox(height: 8),
                            Text('No tienes tarjetas de pago vinculadas', style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.paymentCards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                    itemBuilder: (context, index) {
                      final card = state.paymentCards[index];
                      return _buildPaymentCardItem(context, card);
                    },
                  ),
                ],
                const SizedBox(height: AppDimensions.space32),

                // Sección 2: Tarjetas de Transporte (US5, US19)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tarjetas de Transporte', style: AppTypography.heading3),
                    TextButton.icon(
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Asociar'),
                      onPressed: () => context.push('/wallet/add-transport-card'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                if (state.transportCards.isEmpty) ...[
                  PayIdInfoCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.bus, size: 36, color: AppColors.outline),
                            const SizedBox(height: 8),
                            Text('No tienes tarjetas de transporte vinculadas', style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.transportCards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                    itemBuilder: (context, index) {
                      final transport = state.transportCards[index];
                      return _buildTransportCardItem(context, transport);
                    },
                  ),
                ],
                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(WalletState state) {
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
                'Saldo Total Disponible',
                style: AppTypography.helper.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const PayIdBadge(
                text: 'Soles (PEN)',
                variant: PayIdBadgeVariant.brand,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            CurrencyFormatter.format(state.totalPaymentBalance),
            style: AppTypography.heading1.copyWith(
              color: AppColors.ink,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          const Divider(),
          const SizedBox(height: AppDimensions.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.bus, size: 16, color: AppColors.petroleum),
                  const SizedBox(width: 6),
                  Text(
                    'Saldo en transporte: ${CurrencyFormatter.format(state.totalTransportBalance)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.petroleum,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (state.totalDebt > 0)
                Row(
                  children: [
                    const Icon(LucideIcons.alertCircle, size: 16, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Deuda: ${CurrencyFormatter.format(state.totalDebt)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCardItem(BuildContext context, PaymentCardEntity card) {
    return PayIdInfoCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: InkWell(
        onTap: () => context.push('/wallet/card-detail', extra: card),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryInstitutional.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              ),
              child: const Icon(
                LucideIcons.creditCard,
                size: AppDimensions.iconNavigation,
                color: AppColors.primaryInstitutional,
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
                      Text(
                        '${card.brand} •••• ${card.fullNumber.length >= 4 ? card.fullNumber.substring(card.fullNumber.length - 4) : ""}',
                        style: AppTypography.label.copyWith(fontSize: 14),
                      ),
                      Text(
                        CurrencyFormatter.format(card.balance),
                        style: AppTypography.label.copyWith(
                          color: AppColors.primaryInstitutional,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cuenta: ${card.accountNumber}', style: AppTypography.helper),
                      if (card.hasDebt)
                        PayIdBadge(
                          text: 'Deuda: ${CurrencyFormatter.format(card.debtAmount)}',
                          variant: PayIdBadgeVariant.error,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportCardItem(BuildContext context, TransportCardEntity card) {
    return PayIdInfoCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.petroleum.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            ),
            child: const Icon(
              LucideIcons.bus,
              size: AppDimensions.iconNavigation,
              color: AppColors.petroleum,
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
                    Text(
                      card.type,
                      style: AppTypography.label.copyWith(fontSize: 14),
                    ),
                    Text(
                      CurrencyFormatter.format(card.balance),
                      style: AppTypography.label.copyWith(
                        color: AppColors.petroleum,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tarjeta N° ${card.cardNumber}',
                  style: AppTypography.helper,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          PayIdButton(
            text: 'Recargar',
            size: PayIdButtonSize.s,
            isFullWidth: false,
            onPressed: () => context.push('/wallet/recharge', extra: card),
          ),
        ],
      ),
    );
  }
}

