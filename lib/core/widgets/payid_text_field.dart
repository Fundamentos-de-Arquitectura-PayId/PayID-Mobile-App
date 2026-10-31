import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum PayIdTextFieldType {
  text,
  email,
  phone,
  password,
  search,
  number,
}

/// Campo de entrada oficial conforme al Sistema de Diseño de PayID
class PayIdTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? initialValue;
  final TextEditingController? controller;
  final PayIdTextFieldType type;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final FocusNode? focusNode;

  const PayIdTextField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.controller,
    this.type = PayIdTextFieldType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<PayIdTextField> createState() => _PayIdTextFieldState();
}

class _PayIdTextFieldState extends State<PayIdTextField> {
  late FocusNode _focusNode;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _hasBeenFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Valida al salir del campo
      _validate();
    } else {
      _hasBeenFocused = true;
    }
    setState(() {});
  }

  void _validate() {
    if (widget.validator != null) {
      final text = widget.controller?.text ?? '';
      setState(() {
        _errorMessage = widget.validator!(text);
      });
    }
  }

  TextInputType get _keyboardType {
    switch (widget.type) {
      case PayIdTextFieldType.email:
        return TextInputType.emailAddress;
      case PayIdTextFieldType.phone:
      case PayIdTextFieldType.number:
        return TextInputType.number;
      case PayIdTextFieldType.search:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.type == PayIdTextFieldType.password;
    final isSearch = widget.type == PayIdTextFieldType.search;

    Widget? effectiveSuffixIcon = widget.suffixIcon;

    if (isPassword) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
          size: AppDimensions.iconControl,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      );
    } else if (isSearch && (widget.controller?.text.isNotEmpty ?? false)) {
      effectiveSuffixIcon = IconButton(
        icon: const Icon(
          LucideIcons.x,
          size: AppDimensions.iconControl,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          widget.controller?.clear();
          if (widget.onChanged != null) widget.onChanged!('');
          setState(() {});
        },
      );
    }

    Widget? effectivePrefixIcon = widget.prefixIcon;
    if (isSearch && effectivePrefixIcon == null) {
      effectivePrefixIcon = const Icon(
        LucideIcons.search,
        size: AppDimensions.iconControl,
        color: AppColors.outline,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Etiqueta visible obligatoria
        Text(
          widget.label,
          style: AppTypography.label.copyWith(
            color: widget.enabled ? AppColors.text : AppColors.outline,
          ),
        ),
        const SizedBox(height: AppDimensions.inputLabelGap),

        // Campo de texto
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: isPassword ? _obscurePassword : false,
          keyboardType: _keyboardType,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          style: AppTypography.body.copyWith(
            color: widget.enabled ? AppColors.text : AppColors.textSecondary,
          ),
          onChanged: (val) {
            if (_hasBeenFocused && _errorMessage != null) {
              // Limpiar error una vez corregido
              _validate();
            }
            if (widget.onChanged != null) widget.onChanged!(val);
          },
          onFieldSubmitted: (val) {
            _validate();
            if (widget.onSubmitted != null) widget.onSubmitted!(val);
          },
          validator: (val) {
            final res = widget.validator?.call(val);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _errorMessage != res) {
                setState(() => _errorMessage = res);
              }
            });
            return res == null ? null : '';
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: effectivePrefixIcon,
            suffixIcon: effectiveSuffixIcon,
            errorText: null, // Error manejado explícitamente abajo para control visual exacto
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),

        // Mensaje de error o ayuda contextual
        if (_errorMessage != null && _errorMessage!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space4),
          Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: AppDimensions.iconMetadata,
                color: AppColors.error,
              ),
              const SizedBox(width: AppDimensions.space4),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: AppTypography.helper.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.space4),
          Text(
            widget.helperText!,
            style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

