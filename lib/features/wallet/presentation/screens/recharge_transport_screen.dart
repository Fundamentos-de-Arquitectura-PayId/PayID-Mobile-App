import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import '../../domain/entities/payment_card_entity.dart';
import '../../domain/entities/transport_card_entity.dart';
import '../controllers/wallet_controller.dart';

class RechargeTransportScreen extends ConsumerStatefulWidget {
  final TransportCardEntity? initialCard;

  const RechargeTransportScreen({super.key, this.initialCard});

  @override
  ConsumerState<RechargeTransportScreen> createState() => _RechargeTransportScreenState();
}

class _RechargeTransportScreenState extends ConsumerState<RechargeTransportScreen> {
  final _amountController = TextEditingController(text: '10.00');
  TransportCardEntity? _selectedTransportCard;
  PaymentCardEntity? _selectedPaymentCard;

  final List<double> _predefinedAmounts = [5.0, 10.0, 20.0, 50.0];

  @override
  void initState() {
    super.initState();
    _selectedTransportCard = widget.initialCard;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleRecharge() async {
    if (_selectedTransportCard == null) {
      PayIdSnackBar.showError(context, 'Selecciona una tarjeta de transporte');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      PayIdSnackBar.showError(context, 'Ingresa un monto válido mayor a S/ 0.00');
      return;
    }

    if (_selectedPaymentCard != null && _selectedPaymentCard!.balance < amount) {
      PayIdSnackBar.showError(
        context,
        'Saldo insuficiente en ${_selectedPaymentCard!.brand} (Disponible: ${CurrencyFormatter.format(_selectedPaymentCard!.balance)})',
      );
      return;
    }

    final confirmed = await PayIdDialog.showConfirmation(
      context: context,
      title: 'Confirmar Recarga',
      message:
          '¿Deseas recargar ${CurrencyFormatter.format(amount)} a tu tarjeta ${_selectedTransportCard!.type} (N° ${_selectedTransportCard!.cardNumber})?',
      confirmLabel: 'Confirmar Recarga',
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(walletControllerProvider.notifier)
          .rechargeTransport(
            transportCardId: _selectedTransportCard!.id,
            paymentCardId: _selectedPaymentCard?.id,
            amount: amount,
          );

      if (success && mounted) {
        PayIdSnackBar.showSuccess(
          context,
          'Recarga de ${CurrencyFormatter.format(amount)} exitosa.',
        );
        context.pop();
      } else if (mounted) {
        PayIdSnackBar.showError(
          context,
          ref.read(walletControllerProvider).errorMessage ?? 'Error al procesar la recarga.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletControllerProvider);

    // Si aún no se seleccionó tarjeta de transporte, tomar la primera disponible
    if (_selectedTransportCard == null && walletState.transportCards.isNotEmpty) {
      _selectedTransportCard = walletState.transportCards.first;
    }

    // Si aún no se seleccionó tarjeta de pago, tomar la primera
    if (_selectedPaymentCard == null && walletState.paymentCards.isNotEmpty) {
      _selectedPaymentCard = walletState.paymentCards.first;
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Recargar Transporte'),
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
              // 1. Tarjeta de transporte destino
              Text('Tarjeta de Transporte Destino', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              if (walletState.transportCards.isEmpty) ...[
                PayIdSecurityCard(
                  title: 'Sin tarjetas de transporte',
                  message: 'Debes asociar una tarjeta de transporte antes de poder recargar saldo.',
                  type: SecurityCardType.warning,
                  actionLabel: 'Asociar tarjeta',
                  onAction: () => context.push('/wallet/add-transport-card'),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TransportCardEntity>(
                      value: _selectedTransportCard,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: walletState.transportCards.map((card) {
                        return DropdownMenuItem<TransportCardEntity>(
                          value: card,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${card.type} (N° ${card.cardNumber})'),
                              Text(
                                CurrencyFormatter.format(card.balance),
                                style: AppTypography.label.copyWith(color: AppColors.petroleum),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTransportCard = val);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.space24),

              // 2. Método de pago origen
              Text('Método de Pago (Origen)', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              if (walletState.paymentCards.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<PaymentCardEntity?>(
                      value: _selectedPaymentCard,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: [
                        ...walletState.paymentCards.map((card) {
                          return DropdownMenuItem<PaymentCardEntity?>(
                            value: card,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${card.brand} •••• ${card.fullNumber.length >= 4 ? card.fullNumber.substring(card.fullNumber.length - 4) : ""}'),
                                Text(
                                  CurrencyFormatter.format(card.balance),
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.primaryInstitutional,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedPaymentCard = val);
                      },
                    ),
                  ),
                ),
              ] else ...[
                PayIdInfoCard(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.wallet, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sin tarjeta de débito vinculada. La recarga se simulará directamente.',
                          style: AppTypography.helper,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.space24),

              // 3. Monto de recarga
              Text('Monto a Recargar en Soles (PEN)', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              Row(
                children: _predefinedAmounts.map((amount) {
                  final isSelected = _amountController.text == amount.toStringAsFixed(2);
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _amountController.text = amount.toStringAsFixed(2);
                          });
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.mint50 : AppColors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryInstitutional : AppColors.line,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'S/ ${amount.toInt()}',
                              style: AppTypography.label.copyWith(
                                color: isSelected
                                    ? AppColors.primaryInstitutional
                                    : AppColors.text,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space16),

              PayIdTextField(
                label: 'O ingresa otro monto personalizado',
                hint: '0.00',
                controller: _amountController,
                type: PayIdTextFieldType.number,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Text('S/ ', style: AppTypography.label.copyWith(fontSize: 16)),
                ),
                validator: Validators.positiveAmount,
              ),
              const SizedBox(height: AppDimensions.space32),

              // Botón de ejecución
              PayIdButton(
                text: 'Confirmar y Recargar',
                size: PayIdButtonSize.l,
                icon: LucideIcons.check,
                isLoading: walletState.isOperationInProgress,
                loadingText: 'Recargando...',
                onPressed: walletState.transportCards.isEmpty ? null : _handleRecharge,
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}

