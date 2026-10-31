import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_badge.dart';
import '../../../../core/widgets/payid_card.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Información Personal'),
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
              const PayIdSecurityCard(
                title: 'Identidad Verificada',
                message:
                    'Tus datos principales provienen del registro oficial. Para modificar tu nombre o DNI, contacta con soporte para validación biométrica.',
                type: SecurityCardType.info,
              ),
              const SizedBox(height: AppDimensions.space24),

              PayIdInfoCard(
                title: 'Datos Registrados',
                child: Column(
                  children: [
                    _buildRow(label: 'Nombre completo', value: user?.nombre ?? '-'),
                    const Divider(),
                    _buildRow(label: 'DNI', value: user?.dni ?? '-'),
                    const Divider(),
                    _buildRow(
                      label: 'Fecha de nacimiento',
                      value: user != null ? DateFormatter.toShortDate(user.fechaNacimiento) : '-',
                    ),
                    const Divider(),
                    _buildRow(label: 'Correo electrónico', value: user?.email ?? '-'),
                    const Divider(),
                    _buildRow(label: 'Celular', value: user?.telefono ?? 'No registrado'),
                    const Divider(),
                    _buildRow(
                      label: 'Perfil Universitario',
                      value: user?.esUniversitario == true ? 'Activo (SUNEDU)' : 'No registrado',
                      trailing: PayIdBadge(
                        text: user?.esUniversitario == true ? 'Habilitado' : 'Estándar',
                        variant: user?.esUniversitario == true
                            ? PayIdBadgeVariant.success
                            : PayIdBadgeVariant.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.helper),
          if (trailing != null)
            trailing
          else
            Text(value, style: AppTypography.label.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
