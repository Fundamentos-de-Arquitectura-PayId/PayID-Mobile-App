import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/wallet_models.dart';
import '../controllers/wallet_controller.dart';

class AddPaymentCardScreen extends ConsumerStatefulWidget {
  const AddPaymentCardScreen({super.key});

  @override
  ConsumerState<AddPaymentCardScreen> createState() => _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends ConsumerState<AddPaymentCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '100.00');

  String _selectedBrand = 'Visa';

  @override
  void dispose() {
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      PayIdSnackBar.showError(context, 'Sesión no válida.');
      return;
    }

    final balance = double.tryParse(_initialBalanceController.text.trim()) ?? 0.0;

    final request = CreatePaymentCardRequest(
      userId: user.id,
      fullNumber: _numberController.text.trim(),
      brand: _selectedBrand,
      balance: balance,
      expiryDate: _expiryController.text.trim(),
      cvv: _cvvController.text.trim(),
    );

    final success = await ref
        .read(walletControllerProvider.notifier)
        .createPaymentCard(request);

    if (success && mounted) {
      PayIdSnackBar.showSuccess(context, 'Tarjeta agregada exitosamente a tu billetera.');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Agregar Tarjeta de Pago'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PayIdSecurityCard(
                  title: 'Seguridad en tus Datos Bancarios',
                  message:
                      'PayID encripta la información de tus tarjetas. El código CVV se solicita únicamente para verificación inicial y nunca es almacenado en el teléfono.',
                  type: SecurityCardType.info,
                ),
                const SizedBox(height: AppDimensions.space24),

                // Franquicia
                Text('Franquicia de la tarjeta', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBrand,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: const [
                        DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                        DropdownMenuItem(value: 'Mastercard', child: Text('Mastercard')),
                        DropdownMenuItem(value: 'American Express', child: Text('American Express')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBrand = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Número de tarjeta
                PayIdTextField(
                  label: 'Número de tarjeta (16 dígitos)',
                  hint: '4557 1234 5678 9012',
                  controller: _numberController,
                  type: PayIdTextFieldType.number,
                  validator: Validators.cardNumber,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Fecha de vencimiento y CVV
                Row(
                  children: [
                    Expanded(
                      child: PayIdTextField(
                        label: 'Vencimiento (MM/AA)',
                        hint: '12/28',
                        controller: _expiryController,
                        validator: Validators.expiryDate,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: PayIdTextField(
                        label: 'CVV',
                        hint: '123',
                        controller: _cvvController,
                        type: PayIdTextFieldType.number,
                        validator: Validators.cvv,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space20),

                // Saldo inicial de prueba / demostración
                PayIdTextField(
                  label: 'Saldo inicial en soles (Demostración)',
                  hint: '100.00',
                  controller: _initialBalanceController,
                  type: PayIdTextFieldType.number,
                  helperText: 'El saldo se registrará en PEN (S/) en tu cuenta',
                  validator: Validators.positiveAmount,
                ),
                const SizedBox(height: AppDimensions.space32),

                PayIdButton(
                  text: 'Vincular Tarjeta',
                  size: PayIdButtonSize.l,
                  isLoading: state.isOperationInProgress,
                  loadingText: 'Vinculando...',
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: AppDimensions.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
