import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_card.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/support_remote_data_source.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SupportRemoteDataSource(apiClient: apiClient);
});

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedPriority = 1; // 0: Baja, 1: Media, 2: Alta, 3: Crítica
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      PayIdSnackBar.showError(context, 'Sesión no válida.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ds = ref.read(supportRemoteDataSourceProvider);
      final ticket = await ds.createTicket(
        userId: user.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        PayIdSnackBar.showSuccess(
          context,
          'Ticket creado con éxito. Identificador: ${ticket.id.substring(0, 8)}...',
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        PayIdSnackBar.showError(context, 'No se pudo enviar el ticket de soporte.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Soporte y Asistencia'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: AppDimensions.iconNavigation),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PayIdSecurityCard(
                  title: 'Centro de Ayuda Oficial PayID',
                  message:
                      'Describe detalladamente el inconveniente que presentas. Nuestro equipo de soporte técnico revisará tu reporte a la brevedad.',
                  type: SecurityCardType.info,
                ),
                const SizedBox(height: AppDimensions.space24),

                Text('Prioridad del Requerimiento', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedPriority,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Baja — Consulta general')),
                        DropdownMenuItem(value: 1, child: Text('Media — Inconveniente operativo')),
                        DropdownMenuItem(value: 2, child: Text('Alta — Problema con pago o tarjeta')),
                        DropdownMenuItem(value: 3, child: Text('Crítica — Bloqueo o seguridad')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriority = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                PayIdTextField(
                  label: 'Título del problema o consulta',
                  hint: 'Ej: Consulta sobre saldo de Metropolitano',
                  controller: _titleController,
                  validator: (val) => Validators.required(val, 'El título es obligatorio'),
                ),
                const SizedBox(height: AppDimensions.space20),

                Text('Descripción del problema', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  style: AppTypography.body,
                  validator: (val) => Validators.required(val, 'La descripción es obligatoria'),
                  decoration: const InputDecoration(
                    hintText: 'Explica lo ocurrido, números de operación o detalles adicionales...',
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

                PayIdButton(
                  text: 'Enviar Ticket a Soporte',
                  size: PayIdButtonSize.l,
                  icon: LucideIcons.send,
                  isLoading: _isLoading,
                  loadingText: 'Enviando requerimiento...',
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: AppDimensions.space24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
