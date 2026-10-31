import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/wallet_models.dart';
import '../controllers/wallet_controller.dart';

class AddTransportCardScreen extends ConsumerStatefulWidget {
  const AddTransportCardScreen({super.key});

  @override
  ConsumerState<AddTransportCardScreen> createState() => _AddTransportCardScreenState();
}

class _AddTransportCardScreenState extends ConsumerState<AddTransportCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _balanceController = TextEditingController(text: '15.00');

  String _selectedType = 'Metropolitano';

  @override
  void dispose() {
    _numberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      PayIdSnackBar.showError(context, 'Sesión no válida.');
      return;
    }

    final balance = double.tryParse(_balanceController.text.trim()) ?? 0.0;

    final request = CreateTransportCardRequest(
      userId: user.id,
      type: _selectedType,
      balance: balance,
      cardNumber: _numberController.text.trim(),
    );

    final success = await ref
        .read(walletControllerProvider.notifier)
        .createTransportCard(request);

    if (success && mounted) {
      PayIdSnackBar.showSuccess(
        context,
        'Tarjeta de transporte asociada exitosamente a PayID.',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Asociar Tarjeta de Transporte'),
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
                Text('Tipo de servicio de transporte', style: AppTypography.label),
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
                      value: _selectedType,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: const [
                        DropdownMenuItem(
                          value: 'Metropolitano',
                          child: Text('Metropolitano (Lima)'),
                        ),
                        DropdownMenuItem(
                          value: 'Metro de Lima Línea 1',
                          child: Text('Metro de Lima Línea 1'),
                        ),
                        DropdownMenuItem(
                          value: 'Corredores Complementarios',
                          child: Text('Corredores Complementarios (ATU)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                PayIdTextField(
                  label: 'Número de tarjeta de transporte',
                  hint: 'Ej: 104589213',
                  controller: _numberController,
                  type: PayIdTextFieldType.number,
                  validator: (val) => Validators.required(val, 'El número es obligatorio'),
                ),
                const SizedBox(height: AppDimensions.space20),

                PayIdTextField(
                  label: 'Saldo inicial en soles (Demostración)',
                  hint: '15.00',
                  controller: _balanceController,
                  type: PayIdTextFieldType.number,
                  helperText: 'Saldo actual con el que se asociará la tarjeta',
                  validator: Validators.positiveAmount,
                ),
                const SizedBox(height: AppDimensions.space32),

                PayIdButton(
                  text: 'Asociar a mi Billetera',
                  size: PayIdButtonSize.l,
                  isLoading: state.isOperationInProgress,
                  loadingText: 'Asociando...',
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
