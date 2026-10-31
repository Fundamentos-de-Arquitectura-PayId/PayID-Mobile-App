import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Recuperación de contraseña',
          style: AppTypography.heading3,
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.space16),
              const PayIdSecurityCard(
                title: 'Seguridad y Protección de Identidad',
                message:
                    'Por políticas de seguridad de PayID, la recuperación automatizada de contraseña requiere validación de identidad presencial o mediante soporte oficial.',
                type: SecurityCardType.info,
              ),
              const SizedBox(height: AppDimensions.space24),

              PayIdInfoCard(
                title: 'Estado del Servicio',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: AppDimensions.iconControl,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            'Integración de recuperación por SMS / Correo en desarrollo.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      'Si has olvidado tu contraseña o tu cuenta está bloqueada tras 5 intentos fallidos, el bloqueo temporal se levantará automáticamente en 15 minutos.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              PayIdButton(
                text: 'Contactar a Soporte Técnico',
                icon: LucideIcons.helpCircle,
                onPressed: () {
                  context.push('/settings/support');
                },
              ),
              const SizedBox(height: AppDimensions.space12),

              PayIdButton(
                text: 'Regresar al inicio de sesión',
                variant: PayIdButtonVariant.secondary,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}

