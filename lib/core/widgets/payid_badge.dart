import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum PayIdBadgeVariant {
  success,
  warning,
  error,
  info,
  neutral,
  brand,
}

/// Badge semántico reutilizable con radio completo
class PayIdBadge extends StatelessWidget {
  final String text;
  final PayIdBadgeVariant variant;
  final IconData? icon;

  const PayIdBadge({
    super.key,
    required this.text,
    this.variant = PayIdBadgeVariant.neutral,
    this.icon,
  });

  Color get _textColor {
    switch (variant) {
      case PayIdBadgeVariant.success:
        return AppColors.success;
      case PayIdBadgeVariant.warning:
        return AppColors.warning;
      case PayIdBadgeVariant.error:
        return AppColors.error;
      case PayIdBadgeVariant.info:
        return AppColors.info;
      case PayIdBadgeVariant.neutral:
        return AppColors.textSecondary;
      case PayIdBadgeVariant.brand:
        return AppColors.primaryInstitutional;
    }
  }

  Color get _bgColor {
    switch (variant) {
      case PayIdBadgeVariant.success:
        return AppColors.successBg;
      case PayIdBadgeVariant.warning:
        return AppColors.warningBg;
      case PayIdBadgeVariant.error:
        return AppColors.errorBg;
      case PayIdBadgeVariant.info:
        return AppColors.infoBg;
      case PayIdBadgeVariant.neutral:
        return AppColors.line.withValues(alpha: 0.5);
      case PayIdBadgeVariant.brand:
        return AppColors.mint50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconMetadata, color: _textColor),
            const SizedBox(width: AppDimensions.space4),
          ],
          Text(
            text,
            style: AppTypography.helper.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

