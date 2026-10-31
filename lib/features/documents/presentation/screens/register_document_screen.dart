import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../data/models/document_model.dart';
import '../../domain/entities/document_entity.dart';
import '../controllers/documents_controller.dart';

class RegisterDocumentScreen extends ConsumerStatefulWidget {
  const RegisterDocumentScreen({super.key});

  @override
  ConsumerState<RegisterDocumentScreen> createState() => _RegisterDocumentScreenState();
}

class _RegisterDocumentScreenState extends ConsumerState<RegisterDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();

  DocumentType _selectedType = DocumentType.dni;
  DateTime _issueDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.nombre;
      if (user.dni.isNotEmpty) {
        _numberController.text = user.dni;
      }
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isIssue) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssue ? _issueDate : (_expirationDate ?? now.add(const Duration(days: 365 * 3))),
      firstDate: isIssue ? DateTime(now.year - 20) : now.subtract(const Duration(days: 30)),
      lastDate: isIssue ? now : DateTime(now.year + 20),
      helpText: isIssue ? 'Fecha de emisión' : 'Fecha de caducidad',
    );

    if (picked != null) {
      setState(() {
        if (isIssue) {
          _issueDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      PayIdSnackBar.showError(context, 'Sesión no válida.');
      return;
    }

    final request = CreateDocumentRequest(
      userId: user.id,
      documentNumber: _numberController.text.trim(),
      fullName: _nameController.text.trim(),
      type: _selectedType,
      issueDate: _issueDate,
      expirationDate: _expirationDate,
    );

    final success = await ref
        .read(documentsControllerProvider.notifier)
        .registerDocument(request);

    if (success && mounted) {
      PayIdSnackBar.showSuccess(context, 'Documento registrado exitosamente en PayID.');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Registrar Documento'),
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
                Text(
                  'Tipo de Documento',
                  style: AppTypography.label,
                ),
                const SizedBox(height: AppDimensions.inputLabelGap),

                // Selector de Tipo de Documento
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DocumentType>(
                      value: _selectedType,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: const [
                        DropdownMenuItem(
                          value: DocumentType.dni,
                          child: Text('DNI (Documento Nacional de Identidad)'),
                        ),
                        DropdownMenuItem(
                          value: DocumentType.carnetUniversitario,
                          child: Text('Carné Universitario (SUNEDU)'),
                        ),
                        DropdownMenuItem(
                          value: DocumentType.pasaporte,
                          child: Text('Pasaporte'),
                        ),
                        DropdownMenuItem(
                          value: DocumentType.carnetExtranjeria,
                          child: Text('Carné de Extranjería'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Número de Documento
                PayIdTextField(
                  label: 'Número de documento',
                  hint: _selectedType == DocumentType.dni ? '8 dígitos' : 'Número oficial',
                  controller: _numberController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El número de documento es obligatorio';
                    }
                    if (_selectedType == DocumentType.dni && val.trim().length != 8) {
                      return 'El DNI debe tener 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.space20),

                // Nombre completo
                PayIdTextField(
                  label: 'Nombre completo o apellidos del titular',
                  hint: 'Como figura en el documento físico',
                  controller: _nameController,
                  validator: (val) => Validators.required(val, 'El nombre es obligatorio'),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Fecha de emisión
                Text('Fecha de emisión', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                InkWell(
                  onTap: () => _pickDate(true),
                  child: Container(
                    height: AppDimensions.inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormatter.toShortDate(_issueDate), style: AppTypography.body),
                        const Icon(LucideIcons.calendar, size: 20, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Fecha de caducidad
                Text('Fecha de caducidad (Opcional)', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                InkWell(
                  onTap: () => _pickDate(false),
                  child: Container(
                    height: AppDimensions.inputHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _expirationDate != null
                              ? DateFormatter.toShortDate(_expirationDate!)
                              : 'Sin fecha de caducidad',
                          style: AppTypography.body.copyWith(
                            color: _expirationDate != null ? AppColors.text : AppColors.outline,
                          ),
                        ),
                        const Icon(LucideIcons.calendarX, size: 20, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

                PayIdButton(
                  text: 'Guardar documento en PayID',
                  size: PayIdButtonSize.l,
                  isLoading: state.isLoading,
                  loadingText: 'Registrando...',
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
