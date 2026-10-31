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
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import '../controllers/payments_controller.dart';

class NewPaymentScreen extends ConsumerStatefulWidget {
  const NewPaymentScreen({super.key});

  @override
  ConsumerState<NewPaymentScreen> createState() => _NewPaymentScreenState();
}

class _NewPaymentScreenState extends ConsumerState<NewPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customServiceController = TextEditingController();
  final _amountController = TextEditingController(text: '35.00');

  String _selectedService = 'Pensión Universitaria';
  bool _isCustom = false;

  final List<String> _services = [
    'Pensión Universitaria',
    'Matrícula Académica',
    'Carné Universitario (Trámite SUNEDU)',
    'Certificado de Estudios',
    'Servicios Básicos (Luz / Agua)',
    'Otro servicio',
  ];

  @override
  void dispose() {
    _customServiceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final serviceName = _isCustom ? _customServiceController.text.trim() : _selectedService;
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.')) ?? 0.0;

    final confirmed = await PayIdDialog.showConfirmation(
      context: context,
      title: 'Confirmar Pago',
      message:
          '¿Deseas procesar el pago de ${CurrencyFormatter.format(amount)} por concepto de "$serviceName"?',
      confirmLabel: 'Pagar Ahora',
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(paymentsControllerProvider.notifier)
          .createPayment(servicio: serviceName, monto: amount);

      if (success && mounted) {
        PayIdSnackBar.showSuccess(
          context,
          'Pago de ${CurrencyFormatter.format(amount)} procesado correctamente.',
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Realizar Pago de Servicio'),
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
                Text('Concepto o Servicio', style: AppTypography.label),
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
                      value: _selectedService,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: _services.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedService = val;
                            _isCustom = val == 'Otro servicio';
                          });
                        }
                      },
                    ),
                  ),
                ),
                if (_isCustom) ...[
                  const SizedBox(height: AppDimensions.space16),
                  PayIdTextField(
                    label: 'Nombre del servicio',
                    hint: 'Ej: Cuota de asociación estudiantil',
                    controller: _customServiceController,
                    validator: (val) => Validators.required(val, 'Ingresa el nombre del servicio'),
                  ),
                ],
                const SizedBox(height: AppDimensions.space24),

                PayIdTextField(
                  label: 'Monto a pagar en Soles (PEN)',
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

                PayIdButton(
                  text: 'Pagar Servicio',
                  size: PayIdButtonSize.l,
                  icon: LucideIcons.check,
                  isLoading: state.isCreating,
                  loadingText: 'Procesando pago...',
                  onPressed: _handlePayment,
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

