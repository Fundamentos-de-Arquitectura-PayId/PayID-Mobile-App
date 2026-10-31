import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../domain/entities/payment_card_entity.dart';
import '../controllers/wallet_controller.dart';

class CardDetailScreen extends ConsumerWidget {
  final PaymentCardEntity card;

  const CardDetailScreen({super.key, required this.card});

  Future<void> _handlePayDebt(BuildContext context, WidgetRef ref) async {
    final confirmed = await PayIdDialog.showConfirmation(
      context: context,
      title: 'Pagar Deuda',
      message:
          '¿Deseas pagar la deuda de ${CurrencyFormatter.format(card.debtAmount)} usando el saldo de esta tarjeta?',
      confirmLabel: 'Pagar Deuda',
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(walletControllerProvider.notifier)
          .payDebt(card.id);

      if (success && context.mounted) {
        PayIdSnackBar.showSuccess(context, 'Deuda cancelada correctamente.');
        context.pop();
      } else if (context.mounted) {
        PayIdSnackBar.showError(
          context,
          'Saldo insuficiente en la tarjeta para saldar la deuda.',
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    PayIdSnackBar.showInfo(context, '$label copiado al portapapeles');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text('${card.brand} •••• ${card.fullNumber.length >= 4 ? card.fullNumber.substring(card.fullNumber.length - 4) : ""}'),
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
              // Tarjeta visual estilizada
              _buildVisualCard(context),
              const SizedBox(height: AppDimensions.space24),

              // Alerta de Deuda pendiente (US6)
              if (card.hasDebt) ...[
                PayIdSecurityCard(
                  title: 'Deuda Pendiente',
                  message:
                      'Tienes una deuda registrada de ${CurrencyFormatter.format(card.debtAmount)}. Puedes liquidarla inmediatamente si dispones de saldo suficiente.',
                  type: SecurityCardType.warning,
                  actionLabel: 'Pagar Ahora',
                  onAction: () => _handlePayDebt(context, ref),
                ),
                const SizedBox(height: AppDimensions.space24),
              ],

              // Datos bancarios oficiales
              PayIdInfoCard(
                title: 'Datos de la Cuenta',
                child: Column(
                  children: [
                    _buildCopyableRow(
                      context,
                      label: 'Número de Cuenta',
                      value: card.accountNumber,
                      icon: LucideIcons.hash,
                    ),
                    const Divider(),
                    _buildCopyableRow(
                      context,
                      label: 'CCI (Código de Cuenta Interbancario)',
                      value: card.cci,
                      icon: LucideIcons.landmark,
                    ),
                    const Divider(),
                    _buildCopyableRow(
                      context,
                      label: 'Número de Tarjeta (Enmascarado)',
                      value: card.maskedNumber,
                      icon: LucideIcons.creditCard,
                    ),
                    const Divider(),
                    _buildCopyableRow(
                      context,
                      label: 'Fecha de Expiración',
                      value: card.expiryDate,
                      icon: LucideIcons.calendar,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Botón de pago de deuda si aplica
              if (card.hasDebt) ...[
                PayIdButton(
                  text: 'Pagar Deuda (${CurrencyFormatter.format(card.debtAmount)})',
                  size: PayIdButtonSize.l,
                  icon: LucideIcons.checkCircle2,
                  isLoading: walletState.isOperationInProgress,
                  loadingText: 'Procesando pago...',
                  onPressed: () => _handlePayDebt(context, ref),
                ),
                const SizedBox(height: AppDimensions.space24),
              ],

              // Movimientos de la tarjeta
              Text('Movimientos Recientes', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              if (card.transactions.isEmpty) ...[
                PayIdInfoCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No hay movimientos registrados en esta tarjeta',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: card.transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space8),
                  itemBuilder: (context, index) {
                    final tx = card.transactions[index];
                    final isPositive = tx.amount > 0;

                    return PayIdInfoCard(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isPositive ? AppColors.successBg : AppColors.errorBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPositive ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                                  size: 18,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description,
                                    style: AppTypography.label.copyWith(fontSize: 14),
                                  ),
                                  Text(
                                    DateFormatter.toShortDate(tx.date),
                                    style: AppTypography.helper,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '${isPositive ? '+' : ''}${CurrencyFormatter.format(tx.amount)}',
                            style: AppTypography.label.copyWith(
                              color: isPositive ? AppColors.success : AppColors.error,
                              fontSize: 15,
                            ),
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

  Widget _buildVisualCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A2F),
            AppColors.primaryInstitutional,
            Color(0xFF0F4D2A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryInstitutional.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYID DEBIT',
                style: AppTypography.helper.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                card.brand.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space32),
          Text(
            card.maskedNumber,
            style: AppTypography.heading3.copyWith(
              color: AppColors.white,
              letterSpacing: 3.0,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppDimensions.space20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SALDO DISPONIBLE',
                    style: AppTypography.helper.copyWith(
                      color: AppColors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(card.balance),
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'VENCE',
                    style: AppTypography.helper.copyWith(
                      color: AppColors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    card.expiryDate,
                    style: AppTypography.label.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconControl, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.helper.copyWith(fontSize: 11)),
                Text(value, style: AppTypography.label.copyWith(fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.copy, size: 16, color: AppColors.primaryInstitutional),
            tooltip: 'Copiar',
            onPressed: () => _copyToClipboard(context, value, label),
          ),
        ],
      ),
    );
  }
}

