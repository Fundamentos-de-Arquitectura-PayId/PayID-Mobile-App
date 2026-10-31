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
import '../../domain/entities/document_entity.dart';
import '../controllers/documents_controller.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  IconData _iconForDocType(DocumentType type) {
    switch (type) {
      case DocumentType.dni:
        return LucideIcons.creditCard;
      case DocumentType.carnetUniversitario:
        return LucideIcons.graduationCap;
      case DocumentType.pasaporte:
        return LucideIcons.bookOpen;
      case DocumentType.carnetExtranjeria:
        return LucideIcons.contact;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentsControllerProvider);
    final notifier = ref.read(documentsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Documentos Digitales'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: AppDimensions.iconControl),
            tooltip: 'Actualizar',
            onPressed: () => notifier.loadDocuments(forceRefresh: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/documents/register'),
        backgroundColor: AppColors.primaryInstitutional,
        foregroundColor: AppColors.white,
        icon: const Icon(LucideIcons.plus, size: AppDimensions.iconControl),
        label: Text('Registrar', style: AppTypography.label.copyWith(color: AppColors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner de Modo Sin Conexión (US11)
            if (state.isOfflineMode) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.warningBg,
                child: Row(
                  children: [
                    const Icon(LucideIcons.wifiOff, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo sin conexión. Mostrando documentos guardados localmente.',
                        style: AppTypography.helper.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Filtros de categoría de documentos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              child: Row(
                children: [
                  _DocFilterChip(
                    label: 'Todos',
                    isSelected: state.selectedFilter == null,
                    onTap: () => notifier.setFilter(null),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _DocFilterChip(
                    label: 'DNI',
                    isSelected: state.selectedFilter == DocumentType.dni,
                    onTap: () => notifier.setFilter(DocumentType.dni),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _DocFilterChip(
                    label: 'Carné Univ.',
                    isSelected: state.selectedFilter == DocumentType.carnetUniversitario,
                    onTap: () => notifier.setFilter(DocumentType.carnetUniversitario),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _DocFilterChip(
                    label: 'Pasaporte',
                    isSelected: state.selectedFilter == DocumentType.pasaporte,
                    onTap: () => notifier.setFilter(DocumentType.pasaporte),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  _DocFilterChip(
                    label: 'C. Extranjería',
                    isSelected: state.selectedFilter == DocumentType.carnetExtranjeria,
                    onTap: () => notifier.setFilter(DocumentType.carnetExtranjeria),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryInstitutional,
                        ),
                      ),
                    )
                  : state.filteredDocuments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.space32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.mint50,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
                                  ),
                                  child: const Icon(
                                    LucideIcons.fileText,
                                    size: 36,
                                    color: AppColors.primaryInstitutional,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                Text(
                                  'Aún no tienes documentos registrados',
                                  style: AppTypography.heading3.copyWith(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDimensions.space8),
                                Text(
                                  'Registra tu DNI, carné universitario o pasaporte para acceder a ellos sin conexión.',
                                  style: AppTypography.helper,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDimensions.space24),
                                PayIdButton(
                                  text: 'Registrar primer documento',
                                  isFullWidth: false,
                                  onPressed: () => context.push('/documents/register'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.space16),
                          itemCount: state.filteredDocuments.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.space12),
                          itemBuilder: (context, index) {
                            final doc = state.filteredDocuments[index];
                            final isExpired = doc.isExpired;
                            final isExpiringSoon = doc.isExpiringSoon;

                            return PayIdInfoCard(
                              padding: const EdgeInsets.all(AppDimensions.space16),
                              child: InkWell(
                                onTap: () => context.push('/documents/detail', extra: doc),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.mint50,
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                                            border: Border.all(color: AppColors.mint200),
                                          ),
                                          child: Icon(
                                            _iconForDocType(doc.type),
                                            color: AppColors.primaryInstitutional,
                                            size: AppDimensions.iconNavigation,
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
                                                    doc.typeName,
                                                    style: AppTypography.label.copyWith(fontSize: 15),
                                                  ),
                                                  PayIdBadge(
                                                    text: doc.status == DocumentStatus.verified
                                                        ? 'Verificado'
                                                        : doc.status == DocumentStatus.pending
                                                            ? 'En validación'
                                                            : 'Observado',
                                                    variant: doc.status == DocumentStatus.verified
                                                        ? PayIdBadgeVariant.success
                                                        : doc.status == DocumentStatus.pending
                                                            ? PayIdBadgeVariant.warning
                                                            : PayIdBadgeVariant.error,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: AppDimensions.space4),
                                              Text(
                                                'N° ${doc.documentNumber}',
                                                style: AppTypography.heading3.copyWith(
                                                  fontSize: 17,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: AppDimensions.space4),
                                              Text(
                                                doc.fullName,
                                                style: AppTypography.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppDimensions.space12),
                                    const Divider(),
                                    const SizedBox(height: AppDimensions.space8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.calendar,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              doc.expirationDate != null
                                                  ? 'Vence: ${DateFormatter.toShortDate(doc.expirationDate!)}'
                                                  : 'Sin caducidad',
                                              style: AppTypography.helper,
                                            ),
                                          ],
                                        ),
                                        if (isExpired) ...[
                                          const PayIdBadge(
                                            text: 'Vencido',
                                            variant: PayIdBadgeVariant.error,
                                            icon: LucideIcons.alertTriangle,
                                          ),
                                        ] else if (isExpiringSoon) ...[
                                          const PayIdBadge(
                                            text: 'Vence pronto',
                                            variant: PayIdBadgeVariant.warning,
                                            icon: LucideIcons.clock,
                                          ),
                                        ] else ...[
                                          Row(
                                            children: [
                                              Text(
                                                'Ver detalle',
                                                style: AppTypography.helper.copyWith(
                                                  color: AppColors.primaryInstitutional,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const Icon(
                                                LucideIcons.chevronRight,
                                                size: 14,
                                                color: AppColors.primaryInstitutional,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DocFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryInstitutional : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primaryInstitutional : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            fontSize: 13,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

