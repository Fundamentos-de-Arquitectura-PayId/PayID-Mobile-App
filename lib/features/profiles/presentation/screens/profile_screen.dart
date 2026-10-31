import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_badge.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../controllers/family_profiles_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await PayIdDialog.showConfirmation(
      context: context,
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que deseas cerrar tu sesión en este dispositivo?',
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
    final user = ref.watch(currentUserProvider);
    final familyState = ref.watch(familyProfilesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: AppDimensions.iconControl),
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            children: [
              // Cabecera de usuario
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryInstitutional,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'ID',
                          style: AppTypography.heading2.copyWith(
                            color: AppColors.white,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Text(
                      user?.nombre ?? 'Usuario PayID',
                      style: AppTypography.heading3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email.isNotEmpty == true ? user!.email : (user?.telefono ?? ''),
                      style: AppTypography.helper,
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PayIdBadge(
                          text: user?.esUniversitario == true ? 'Estudiante Universitario' : 'Ciudadano',
                          variant: PayIdBadgeVariant.brand,
                          icon: user?.esUniversitario == true ? LucideIcons.graduationCap : LucideIcons.user,
                        ),
                        if (user?.premium == true) ...[
                          const SizedBox(width: 8),
                          const PayIdBadge(
                            text: 'Premium',
                            variant: PayIdBadgeVariant.warning,
                            icon: LucideIcons.star,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),

              // Datos Personales
              PayIdInfoCard(
                title: 'Datos de Identidad',
                child: Column(
                  children: [
                    _buildProfileRow(label: 'DNI', value: user?.dni ?? 'No registrado'),
                    const Divider(),
                    _buildProfileRow(
                      label: 'Nacimiento',
                      value: user != null ? DateFormatter.toShortDate(user.fechaNacimiento) : '-',
                    ),
                    const Divider(),
                    _buildProfileRow(label: 'Celular', value: user?.telefono ?? 'No registrado'),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Gestión de Perfiles Familiares (US2)
              PayIdActionCard(
                title: 'Perfiles Familiares',
                subtitle: '${familyState.members.length} familiar(es) asociados',
                icon: LucideIcons.users,
                onTap: () => context.push('/family-profiles'),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Configuración de la cuenta
              PayIdActionCard(
                title: 'Configuración y Privacidad',
                subtitle: 'Seguridad, términos y políticas',
                icon: LucideIcons.shieldCheck,
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Soporte y Ayuda
              PayIdActionCard(
                title: 'Soporte y Asistencia',
                subtitle: 'Crear ticket de ayuda técnica',
                icon: LucideIcons.helpCircle,
                onTap: () => context.push('/settings/support'),
              ),
              const SizedBox(height: AppDimensions.space32),

              // Botón Cerrar Sesión
              PayIdButton(
                text: 'Cerrar Sesión',
                variant: PayIdButtonVariant.secondary,
                icon: LucideIcons.logOut,
                onPressed: () => _handleLogout(context, ref),
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.helper),
          Text(value, style: AppTypography.label.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
