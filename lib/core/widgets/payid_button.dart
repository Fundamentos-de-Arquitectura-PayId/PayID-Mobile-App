import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum PayIdButtonVariant { primary, secondary, tertiary, danger }

enum PayIdButtonSize {
  s, // 40 px
  m, // 48 px
  l, // 56 px
}

/// Botón reutilizable conforme al Sistema de Diseño Oficial de PayID
class PayIdButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final PayIdButtonVariant variant;
  final PayIdButtonSize size;
  final bool isLoading;
  final String? loadingText;
  final IconData? icon;
  final bool isFullWidth;

  const PayIdButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = PayIdButtonVariant.primary,
    this.size = PayIdButtonSize.m,
    this.isLoading = false,
    this.loadingText,
    this.icon,
    this.isFullWidth = true,
  });

  double get _height {
    switch (size) {
      case PayIdButtonSize.s:
        return AppDimensions.buttonHeightS;
      case PayIdButtonSize.m:
        return AppDimensions.buttonHeightM;
      case PayIdButtonSize.l:
        return AppDimensions.buttonHeightL;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget child;
    if (isLoading) {
      final spinnerColor =
          variant == PayIdButtonVariant.secondary ||
              variant == PayIdButtonVariant.tertiary
          ? AppColors.primaryInstitutional
          : AppColors.white;

      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            ),
          ),
          const SizedBox(width: AppDimensions.space8),
          Flexible(
            child: Text(
              loadingText ?? 'Procesando...',
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: spinnerColor),
            ),
          ),
        ],
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimensions.iconControl),
          const SizedBox(width: AppDimensions.space8),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else {
      child = Text(text);
    }

    Widget button;

    switch (variant) {
      case PayIdButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryInstitutional,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.line,
            disabledForegroundColor: AppColors.outline,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            elevation: 0,
            textStyle: AppTypography.label,
          ),
          child: child,
        );
        break;

      case PayIdButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryInstitutional,
            disabledForegroundColor: AppColors.outline,
            side: BorderSide(
              color: effectiveOnPressed == null
                  ? AppColors.line
                  : AppColors.primaryInstitutional,
              width: 1.5,
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            textStyle: AppTypography.label,
          ),
          child: child,
        );
        break;

      case PayIdButtonVariant.tertiary:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryInstitutional,
            disabledForegroundColor: AppColors.outline,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            textStyle: AppTypography.label,
          ),
          child: child,
        );
        break;

      case PayIdButtonVariant.danger:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.line,
            disabledForegroundColor: AppColors.outline,
            minimumSize: Size(isFullWidth ? double.infinity : 0, _height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            elevation: 0,
            textStyle: AppTypography.label,
          ),
          child: child,
        );
        break;
    }

    return SizedBox(
      height: _height,
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }
}
