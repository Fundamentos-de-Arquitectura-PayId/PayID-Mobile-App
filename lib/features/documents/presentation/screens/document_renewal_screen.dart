import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../domain/entities/document_entity.dart';

class DocumentRenewalScreen extends StatefulWidget {
  final DocumentEntity document;

  const DocumentRenewalScreen({super.key, required this.document});

  @override
  State<DocumentRenewalScreen> createState() => _DocumentRenewalScreenState();
}

class _DocumentRenewalScreenState extends State<DocumentRenewalScreen> {
  int _currentStep = 1; // 1: Solicitud registrada, 2: En revisión institucional, 3: Emitido
  bool _isSubmitting = false;

  void _requestRenewal() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _currentStep = 2;
    });

    PayIdSnackBar.showSuccess(
      context,
      'Solicitud de renovación registrada para ${widget.document.typeName}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Seguimiento de Renovación'),
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
              PayIdInfoCard(
                title: widget.document.typeName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('N° ${widget.document.documentNumber}', style: AppTypography.heading3),
                    const SizedBox(height: 4),
                    Text('Titular: ${widget.document.fullName}', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      widget.document.expirationDate != null
                          ? 'Vencimiento: ${DateFormatter.toShortDate(widget.document.expirationDate!)}'
                          : 'Sin fecha de caducidad',
                      style: AppTypography.helper,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              Text('Etapas del Trámite', style: AppTypography.heading3),
              const SizedBox(height: AppDimensions.space16),

              _buildStepItem(
                stepNumber: 1,
                title: 'Solicitud de renovación registrada',
                description: 'Se valida la vigencia actual y datos del titular.',
                isDone: _currentStep >= 1,
                isCurrent: _currentStep == 1,
              ),
              _buildStepItem(
                stepNumber: 2,
                title: 'En revisión institucional (SUNEDU / RENIEC)',
                description: 'Validación en entidad emisora oficial.',
                isDone: _currentStep >= 2,
                isCurrent: _currentStep == 2,
              ),
              _buildStepItem(
                stepNumber: 3,
                title: 'Emisión digital y actualización en PayID',
                description: 'El nuevo documento se sincronizará automáticamente.',
                isDone: _currentStep >= 3,
                isCurrent: _currentStep == 3,
                isLast: true,
              ),
              const SizedBox(height: AppDimensions.space24),

              // Nota de transparencia técnica según la especificación académica
              const PayIdSecurityCard(
                title: 'Integración Institucional en Desarrollo',
                message:
                    'El backend actual registra el estado en la app. La conexión bidireccional directa con los servicios de SUNEDU / RENIEC está programada para la siguiente fase.',
                type: SecurityCardType.info,
              ),
              const SizedBox(height: AppDimensions.space32),

              if (_currentStep == 1) ...[
                PayIdButton(
                  text: 'Iniciar trámite de renovación',
                  icon: LucideIcons.send,
                  isLoading: _isSubmitting,
                  loadingText: 'Registrando trámite...',
                  onPressed: _requestRenewal,
                ),
              ] else ...[
                PayIdButton(
                  text: 'Volver a mis documentos',
                  variant: PayIdButtonVariant.secondary,
                  onPressed: () => context.pop(),
                ),
              ],
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String description,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    final activeColor = AppColors.primaryInstitutional;
    final inactiveColor = AppColors.line;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? activeColor : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? activeColor : AppColors.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(LucideIcons.check, size: 16, color: AppColors.white)
                    : Text(
                        '$stepNumber',
                        style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? activeColor : inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.label.copyWith(
                  color: isDone ? AppColors.ink : AppColors.textSecondary,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.helper,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
