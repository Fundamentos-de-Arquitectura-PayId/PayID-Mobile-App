import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_logo.dart';
import '../../../../core/widgets/payid_text_field.dart';
import '../../data/models/register_request_model.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _birthDateError;
  bool _isUniversityStudent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 20, 1, 1);
    final firstDate = DateTime(now.year - 120, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'PE'),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateError = null;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_selectedBirthDate == null) {
      setState(() {
        _birthDateError = 'La fecha de nacimiento es obligatoria';
      });
    }

    if (!_formKey.currentState!.validate() || _selectedBirthDate == null) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      PayIdSnackBar.showError(context, 'Las contraseñas no coinciden');
      return;
    }

    if (_emailController.text.trim().isEmpty && _phoneController.text.trim().isEmpty) {
      PayIdSnackBar.showError(
        context,
        'Debes indicar un correo electrónico o un número de celular',
      );
      return;
    }

    final request = RegisterRequestModel(
      nombre: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      telefono: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      password: _passwordController.text,
      dni: _dniController.text.trim(),
      fechaNacimiento: _selectedBirthDate!,
      esUniversitario: _isUniversityStudent,
    );

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.register(request);

    if (success && mounted) {
      PayIdSnackBar.showSuccess(
        context,
        'Cuenta creada exitosamente. Inicia sesión con tus credenciales.',
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const PayIdLogo(size: PayIdLogoSize.small),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Crea tu cuenta PayID',
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Accede a tu identidad digital, billetera y transporte integrado',
                  style: AppTypography.lead.copyWith(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                if (authState.errorMessage != null) ...[
                  PayIdSecurityCard(
                    title: 'No se pudo registrar la cuenta',
                    message: authState.errorMessage!,
                    type: SecurityCardType.error,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ],

                // Nombre completo
                PayIdTextField(
                  label: 'Nombre completo',
                  hint: 'Ej: Carlos Alberto Gómez Mendoza',
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.trim().length < 2) {
                      return 'El nombre es obligatorio y debe tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // DNI
                PayIdTextField(
                  label: 'DNI (Documento Nacional de Identidad)',
                  hint: '8 dígitos numéricos',
                  controller: _dniController,
                  type: PayIdTextFieldType.number,
                  validator: Validators.dni,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Selector de Fecha de Nacimiento
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de nacimiento',
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: AppDimensions.inputLabelGap),
                    InkWell(
                      onTap: () => _selectBirthDate(context),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                      child: Container(
                        height: AppDimensions.inputHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.inputHorizontalPadding,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                          border: Border.all(
                            color: _birthDateError != null ? AppColors.error : AppColors.outline,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedBirthDate != null
                                  ? DateFormatter.toShortDate(_selectedBirthDate!)
                                  : 'dd/mm/aaaa',
                              style: AppTypography.body.copyWith(
                                color: _selectedBirthDate != null
                                    ? AppColors.text
                                    : AppColors.outline,
                              ),
                            ),
                            const Icon(
                              LucideIcons.calendar,
                              size: AppDimensions.iconControl,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_birthDateError != null) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        _birthDateError!,
                        style: AppTypography.helper.copyWith(color: AppColors.error),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Correo electrónico
                PayIdTextField(
                  label: 'Correo electrónico',
                  hint: 'usuario@correo.com',
                  controller: _emailController,
                  type: PayIdTextFieldType.email,
                  helperText: 'Opcional si indicas celular',
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      return Validators.email(val);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Celular
                PayIdTextField(
                  label: 'Número de celular',
                  hint: '987654321',
                  controller: _phoneController,
                  type: PayIdTextFieldType.phone,
                  helperText: '9 dígitos comenzando con 9 (opcional si indicas correo)',
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      return Validators.phone(val);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Switch Universitario
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.graduationCap,
                        size: AppDimensions.iconNavigation,
                        color: AppColors.primaryInstitutional,
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Eres estudiante universitario?',
                              style: AppTypography.label.copyWith(fontSize: 14),
                            ),
                            Text(
                              'Permite habilitar tu carné universitario digital',
                              style: AppTypography.helper,
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isUniversityStudent,
                        activeTrackColor: AppColors.primaryInstitutional,
                        onChanged: (val) {
                          setState(() => _isUniversityStudent = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Contraseña
                PayIdTextField(
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  controller: _passwordController,
                  type: PayIdTextFieldType.password,
                  validator: Validators.password,
                ),
                const SizedBox(height: AppDimensions.space16),

                // Confirmar contraseña
                PayIdTextField(
                  label: 'Confirmar contraseña',
                  hint: 'Repite tu contraseña',
                  controller: _confirmPasswordController,
                  type: PayIdTextFieldType.password,
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space32),

                // Botón Enviar
                PayIdButton(
                  text: 'Crear cuenta',
                  size: PayIdButtonSize.l,
                  isLoading: authState.isLoading,
                  loadingText: 'Creando cuenta...',
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppDimensions.space24),

                // Enlace a Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Inicia sesión',
                          style: AppTypography.label.copyWith(
                            color: AppColors.primaryInstitutional,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
