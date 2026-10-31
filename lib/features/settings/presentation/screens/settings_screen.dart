import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await PayIdDialog.showConfirmation(
      context: context,
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que deseas cerrar tu sesión en PayID?',
      confirmLabel: 'Cerrar Sesión',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Configuración'),
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
              Text('Cuenta y Perfil', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              PayIdActionCard(
                title: 'Información Personal',
                subtitle: 'Datos de identidad, correo y celular',
                icon: LucideIcons.user,
                onTap: () => context.push('/settings/personal-info'),
              ),
              const SizedBox(height: AppDimensions.space12),

              PayIdActionCard(
                title: 'Seguridad y Privacidad',
                subtitle: 'Bloqueos antifraude, biometría y claves',
                icon: LucideIcons.shieldCheck,
                onTap: () => context.push('/settings/security'),
              ),
              const SizedBox(height: AppDimensions.space24),

              Text('Legal y Soporte', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              PayIdActionCard(
                title: 'Términos y Políticas',
                subtitle: 'Condiciones de uso y protección de datos (Perú)',
                icon: LucideIcons.fileText,
                onTap: () => context.push('/settings/terms'),
              ),
              const SizedBox(height: AppDimensions.space12),

              PayIdActionCard(
                title: 'Soporte y Reclamaciones',
                subtitle: 'Crear ticket de asistencia técnica',
                icon: LucideIcons.helpCircle,
                onTap: () => context.push('/settings/support'),
              ),
              const SizedBox(height: AppDimensions.space32),

              PayIdButton(
                text: 'Cerrar Sesión',
                variant: PayIdButtonVariant.secondary,
                icon: LucideIcons.logOut,
                onPressed: () => _handleLogout(context, ref),
              ),
              const SizedBox(height: AppDimensions.space16),

              Center(
                child: Text(
                  'PayID Mobile v1.0.0 • Perú\nConectado a ASP.NET Core 9 REST API',
                  style: AppTypography.helper,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}
