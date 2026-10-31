import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/payid_button.dart';
import '../../../../core/widgets/payid_dialog.dart';
import '../../../../core/widgets/payid_text_field.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/family_member_entity.dart';
import '../controllers/family_profiles_controller.dart';

class AddEditFamilyMemberScreen extends ConsumerStatefulWidget {
  const AddEditFamilyMemberScreen({super.key});

  @override
  ConsumerState<AddEditFamilyMemberScreen> createState() => _AddEditFamilyMemberScreenState();
}

class _AddEditFamilyMemberScreenState extends ConsumerState<AddEditFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedRelationship = 'Hijo/a';
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 10));
  bool _isStudent = false;

  final List<String> _relationships = [
    'Hijo/a',
    'Cónyuge',
    'Padre/Madre',
    'Hermano/a',
    'Dependiente / Apoderado',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'Fecha de nacimiento del familiar',
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      PayIdSnackBar.showError(context, 'Sesión no válida.');
      return;
    }

    final newMember = FamilyMemberEntity(
      id: const Uuid().v4(),
      parentUserId: user.id,
      fullName: _nameController.text.trim(),
      relationship: _selectedRelationship,
      dni: _dniController.text.trim(),
      birthDate: _birthDate,
      isStudent: _isStudent,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    await ref.read(familyProfilesControllerProvider.notifier).addMember(newMember);

    if (mounted) {
      PayIdSnackBar.showSuccess(
        context,
        '${newMember.fullName} agregado a tus perfiles familiares.',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Agregar Familiar'),
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
                // Nombre completo
                PayIdTextField(
                  label: 'Nombre completo',
                  hint: 'Ej: Sofía Gómez',
                  controller: _nameController,
                  validator: (val) => Validators.required(val, 'El nombre es obligatorio'),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Parentesco
                Text('Parentesco', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRelationship,
                      isExpanded: true,
                      style: AppTypography.body,
                      icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                      items: _relationships.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRelationship = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                // DNI
                PayIdTextField(
                  label: 'DNI del familiar',
                  hint: '8 dígitos numéricos',
                  controller: _dniController,
                  type: PayIdTextFieldType.number,
                  validator: Validators.dni,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Fecha de Nacimiento
                Text('Fecha de nacimiento', style: AppTypography.label),
                const SizedBox(height: AppDimensions.inputLabelGap),
                InkWell(
                  onTap: _pickBirthDate,
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
                        Text(DateFormatter.toShortDate(_birthDate), style: AppTypography.body),
                        const Icon(LucideIcons.calendar, size: 20, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),

                // Switch Estudiante
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.graduationCap, size: 24, color: AppColors.primaryInstitutional),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¿Es estudiante?', style: AppTypography.label.copyWith(fontSize: 14)),
                            Text('Habilita gestión de carné estudiantil', style: AppTypography.helper),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isStudent,
                        activeTrackColor: AppColors.primaryInstitutional,
                        onChanged: (val) => setState(() => _isStudent = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),

                PayIdButton(
                  text: 'Guardar Familiar',
                  size: PayIdButtonSize.l,
                  icon: LucideIcons.userCheck,
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
