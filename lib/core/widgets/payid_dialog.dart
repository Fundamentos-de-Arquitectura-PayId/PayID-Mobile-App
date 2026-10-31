import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';
import 'payid_button.dart';

/// Alertas SnackBar con estilo institucional PayID
class PayIdSnackBar {
  PayIdSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: LucideIcons.checkCircle2,
      textColor: AppColors.success,
      backgroundColor: AppColors.successBg,
      borderColor: AppColors.success,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: LucideIcons.alertCircle,
      textColor: AppColors.error,
      backgroundColor: AppColors.errorBg,
      borderColor: AppColors.error,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: LucideIcons.alertTriangle,
      textColor: AppColors.warning,
      backgroundColor: AppColors.warningBg,
      borderColor: AppColors.warning,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: LucideIcons.info,
      textColor: AppColors.info,
      backgroundColor: AppColors.infoBg,
      borderColor: AppColors.info,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(AppDimensions.space16),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: AppDimensions.iconControl),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo modal accesible de PayID
class PayIdDialog {
  PayIdDialog._();

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
          side: const BorderSide(color: AppColors.line),
        ),
        title: Text(
          title,
          style: AppTypography.heading3,
        ),
        content: Text(
          message,
          style: AppTypography.body.copyWith(color: AppColors.text),
        ),
        actionsPadding: const EdgeInsets.all(AppDimensions.space16),
        actions: [
          Row(
            children: [
              Expanded(
                child: PayIdButton(
                  text: cancelLabel,
                  variant: PayIdButtonVariant.secondary,
                  size: PayIdButtonSize.s,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: PayIdButton(
                  text: confirmLabel,
                  variant: isDangerous ? PayIdButtonVariant.danger : PayIdButtonVariant.primary,
                  size: PayIdButtonSize.s,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

