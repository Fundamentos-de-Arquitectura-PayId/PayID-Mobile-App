import 'dart:async';
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
import '../../../../core/widgets/payid_logo.dart';
import '../../../../core/widgets/payid_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  Timer? _lockoutTimer;
  int _remainingLockoutSeconds = 0;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutCountdown(DateTime lockoutEndUtc) {
    _lockoutTimer?.cancel();
    final remaining = lockoutEndUtc.difference(DateTime.now().toUtc()).inSeconds;
    if (remaining <= 0) return;

    setState(() {
      _remainingLockoutSeconds = remaining;
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingLockoutSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingLockoutSeconds = 0;
        });
      } else {
        setState(() {
          _remainingLockoutSeconds--;
        });
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.login(
      emailOrPhone: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/dashboard');
    } else {
      final state = ref.read(authControllerProvider);
      if (state.isLocked && state.lockoutEndUtc != null) {
        _startLockoutCountdown(state.lockoutEndUtc!);
      }
    }
  }

  String _formatRemainingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.space32),
                const Center(
                  child: PayIdLogo(
                    size: PayIdLogoSize.medium,
                    showTagline: true,
                  ),
                ),
                const SizedBox(height: AppDimensions.space40),

                Text(
                  'Iniciar sesión',
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Ingresa tus credenciales para acceder a tus documentos y billetera',
                  style: AppTypography.lead.copyWith(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

                // Tarjeta de bloqueo de seguridad si aplica (US22)
                if (authState.isLocked || _remainingLockoutSeconds > 0) ...[
                  PayIdSecurityCard(
                    title: 'Cuenta bloqueada temporalmente',
                    message: _remainingLockoutSeconds > 0
                        ? 'Por seguridad, se han bloqueado los intentos tras 5 fallos consecutivos. Intenta nuevamente en ${_formatRemainingTime(_remainingLockoutSeconds)}.'
                        : (authState.errorMessage ?? 'Cuenta bloqueada temporalmente.'),
                    type: SecurityCardType.error,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ] else if (authState.errorMessage != null && !authState.isLocked) ...[
                  PayIdSecurityCard(
                    title: 'Error de acceso',
                    message: authState.errorMessage!,
                    type: SecurityCardType.warning,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ],

                // Campo Identificador
                PayIdTextField(
                  label: 'Correo electrónico o celular',
                  hint: 'ejemplo@correo.com o 987654321',
                  controller: _identifierController,
                  type: PayIdTextFieldType.text,
                  prefixIcon: const Icon(LucideIcons.user, size: AppDimensions.iconControl, color: AppColors.outline),
                  validator: Validators.emailOrPhone,
                  enabled: !authState.isLoading && _remainingLockoutSeconds == 0,
                ),
                const SizedBox(height: AppDimensions.space24),

                // Campo Contraseña
                PayIdTextField(
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  controller: _passwordController,
                  type: PayIdTextFieldType.password,
                  prefixIcon: const Icon(LucideIcons.lock, size: AppDimensions.iconControl, color: AppColors.outline),
                  validator: Validators.password,
                  enabled: !authState.isLoading && _remainingLockoutSeconds == 0,
                ),
                const SizedBox(height: AppDimensions.space12),

                // Olvido de contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: AppTypography.label.copyWith(
                        color: AppColors.petroleum,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Botón principal
                PayIdButton(
                  text: 'Ingresar a PayID',
                  size: PayIdButtonSize.l,
                  isLoading: authState.isLoading,
                  loadingText: 'Verificando...',
                  onPressed: _remainingLockoutSeconds > 0 ? null : _handleLogin,
                ),
                const SizedBox(height: AppDimensions.space32),

                // Enlace a Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes una cuenta? ',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Regístrate aquí',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primaryInstitutional,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

