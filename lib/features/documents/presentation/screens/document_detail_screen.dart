import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_badge.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../domain/entities/document_entity.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentEntity document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(document.shortTypeName),
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
              // Credencial Digital Estilizada
              _buildDigitalCard(context),
              const SizedBox(height: AppDimensions.space24),

              // Alertas de vencimiento si aplica (US9)
              if (document.isExpired) ...[
                PayIdSecurityCard(
                  title: 'Documento Vencido',
                  message:
                      'Este documento ha caducado. Te recomendamos iniciar el trámite de renovación para mantener tu billetera y accesos actualizados.',
                  type: SecurityCardType.error,
                  actionLabel: 'Tramitar Renovación',
                  onAction: () => context.push('/documents/renewal', extra: document),
                ),
                const SizedBox(height: AppDimensions.space24),
              ] else if (document.isExpiringSoon) ...[
                PayIdSecurityCard(
                  title: 'Próximo a Vencer',
                  message:
                      'Tu documento vence el ${DateFormatter.toShortDate(document.expirationDate!)}. Puedes solicitar tu renovación con anticipación.',
                  type: SecurityCardType.warning,
                  actionLabel: 'Ver Renovación',
                  onAction: () => context.push('/documents/renewal', extra: document),
                ),
                const SizedBox(height: AppDimensions.space24),
              ],

              // Estado de validación
              PayIdInfoCard(
                title: 'Información y Validación',
                child: Column(
                  children: [
                    _buildDataRow(
                      label: 'Número de documento',
                      value: document.documentNumber,
                      icon: LucideIcons.fileText,
                    ),
                    const Divider(),
                    _buildDataRow(
                      label: 'Titular',
                      value: document.fullName,
                      icon: LucideIcons.user,
                    ),
                    const Divider(),
                    _buildDataRow(
                      label: 'Tipo de documento',
                      value: document.typeName,
                      icon: LucideIcons.badgeHelp,
                    ),
                    const Divider(),
                    _buildDataRow(
                      label: 'Fecha de emisión',
                      value: DateFormatter.toShortDate(document.issueDate),
                      icon: LucideIcons.calendar,
                    ),
                    const Divider(),
                    _buildDataRow(
                      label: 'Fecha de caducidad',
                      value: document.expirationDate != null
                          ? DateFormatter.toShortDate(document.expirationDate!)
                          : 'Indeterminada',
                      icon: LucideIcons.calendarX,
                    ),
                    const Divider(),
                    _buildDataRow(
                      label: 'Estado de verificación',
                      value: document.statusName,
                      icon: LucideIcons.shieldCheck,
                      trailing: PayIdBadge(
                        text: document.status == DocumentStatus.verified
                            ? 'Oficial'
                            : 'En trámite',
                        variant: document.status == DocumentStatus.verified
                            ? PayIdBadgeVariant.success
                            : PayIdBadgeVariant.warning,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Botón de acción para renovación (US4)
              PayIdButton(
                text: 'Solicitar o consultar renovación',
                icon: LucideIcons.refreshCw,
                variant: PayIdButtonVariant.secondary,
                onPressed: () => context.push('/documents/renewal', extra: document),
              ),
              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDigitalCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryInstitutional,
            AppColors.petroleum,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryInstitutional.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PAYID • IDENTIDAD DIGITAL',
                    style: AppTypography.helper.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  document.shortTypeName,
                  style: AppTypography.helper.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space32),
          Text(
            document.documentNumber,
            style: AppTypography.heading2.copyWith(
              color: AppColors.white,
              letterSpacing: 2.0,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAR',
                      style: AppTypography.helper.copyWith(
                        color: AppColors.white.withValues(alpha: 0.65),
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      document.fullName.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'VENCE',
                    style: AppTypography.helper.copyWith(
                      color: AppColors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    document.expirationDate != null
                        ? DateFormatter.toMonthYear(document.expirationDate!)
                        : 'INDET.',
                    style: AppTypography.label.copyWith(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required String label,
    required String value,
    required IconData icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconControl, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.helper.copyWith(fontSize: 11),
                ),
                Text(
                  value,
                  style: AppTypography.label.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
