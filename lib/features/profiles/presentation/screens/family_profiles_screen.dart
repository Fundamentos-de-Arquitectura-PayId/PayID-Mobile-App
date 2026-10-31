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
import '../controllers/family_profiles_controller.dart';

class FamilyProfilesScreen extends ConsumerWidget {
  const FamilyProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyProfilesControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Perfiles Familiares'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/family-profiles/add'),
        backgroundColor: AppColors.primaryInstitutional,
        foregroundColor: AppColors.white,
        icon: const Icon(LucideIcons.userPlus, size: AppDimensions.iconControl),
        label: Text('Agregar Familiar', style: AppTypography.label.copyWith(color: AppColors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nota de transparencia técnica según la regla 9
              const PayIdSecurityCard(
                title: 'Almacenamiento Local de Familiares',
                message:
                    'Los perfiles familiares se guardan localmente en tu dispositivo. La sincronización multi-cuenta en el servidor ASP.NET Core está planificada para el Sprint 2.',
                type: SecurityCardType.info,
              ),
              const SizedBox(height: AppDimensions.space24),

              Text('Integrantes de la Familia', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space12),

              if (familyState.members.isEmpty) ...[
                PayIdInfoCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.mint50,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
                            ),
                            child: const Icon(LucideIcons.users, size: 30, color: AppColors.primaryInstitutional),
                          ),
                          const SizedBox(height: 12),
                          Text('No tienes familiares agregados', style: AppTypography.heading3.copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            'Puedes vincular hijos, apoderados o dependientes para consultar sus documentos y recargas.',
                            style: AppTypography.helper,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          PayIdButton(
                            text: 'Agregar primer familiar',
                            isFullWidth: false,
                            onPressed: () => context.push('/family-profiles/add'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: familyState.members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                  itemBuilder: (context, index) {
                    final member = familyState.members[index];

                    return PayIdInfoCard(
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.mint50,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: const Icon(
                              LucideIcons.user,
                              size: AppDimensions.iconNavigation,
                              color: AppColors.primaryInstitutional,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      member.fullName,
                                      style: AppTypography.label.copyWith(fontSize: 15),
                                    ),
                                    PayIdBadge(
                                      text: member.relationship,
                                      variant: PayIdBadgeVariant.brand,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('DNI: ${member.dni}', style: AppTypography.helper),
                                const SizedBox(height: 2),
                                Text(
                                  'Nacimiento: ${DateFormatter.toShortDate(member.birthDate)}${member.isStudent ? " • Estudiante" : ""}',
                                  style: AppTypography.helper,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                            tooltip: 'Eliminar familiar',
                            onPressed: () async {
                              final confirm = await PayIdDialog.showConfirmation(
                                context: context,
                                title: 'Eliminar Familiar',
                                message: '¿Estás seguro de quitar a ${member.fullName} de tus perfiles familiares?',
                                isDangerous: true,
                              );
                              if (confirm == true) {
                                ref.read(familyProfilesControllerProvider.notifier).removeMember(member.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }
}

