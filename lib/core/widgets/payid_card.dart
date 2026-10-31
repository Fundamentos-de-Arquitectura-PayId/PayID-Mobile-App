import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum SecurityCardType {
  warning,
  error,
  info,
  success,
}

/// Familia 1: Information Card
/// Presenta saldos, resúmenes e información estructurada.
/// Especificación: Padding 24px, gap 12px, radio 12px, borde 1px #D7E0DA, sin sombra por defecto.
class PayIdInfoCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const PayIdInfoCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.line,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || trailing != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.heading3.copyWith(fontSize: 18),
                    ),
                  ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppDimensions.cardInternalGap),
          ],
          child,
        ],
      ),
    );
  }
}

/// Familia 2: Action Card
/// Representa una única acción o destino interactivo.
/// No anida botones dentro. Trae feedback táctil y chevron.
class PayIdActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const PayIdActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: const BorderSide(
          color: AppColors.line,
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryInstitutional).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                  ),
                  child: Icon(
                    icon,
                    size: AppDimensions.iconNavigation,
                    color: iconColor ?? AppColors.primaryInstitutional,
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(fontSize: 16),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        subtitle!,
                        style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    LucideIcons.chevronRight,
                    size: AppDimensions.iconControl,
                    color: AppColors.outline,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Familia 3: Security Card
/// Presenta condiciones, estados y avisos de seguridad.
class PayIdSecurityCard extends StatelessWidget {
  final String title;
  final String message;
  final SecurityCardType type;
  final IconData? customIcon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const PayIdSecurityCard({
    super.key,
    required this.title,
    required this.message,
    this.type = SecurityCardType.info,
    this.customIcon,
    this.onAction,
    this.actionLabel,
  });

  Color get _borderColor {
    switch (type) {
      case SecurityCardType.warning:
        return AppColors.warning;
      case SecurityCardType.error:
        return AppColors.error;
      case SecurityCardType.success:
        return AppColors.success;
      case SecurityCardType.info:
        return AppColors.info;
    }
  }

  Color get _bgColor {
    switch (type) {
      case SecurityCardType.warning:
        return AppColors.warningBg;
      case SecurityCardType.error:
        return AppColors.errorBg;
      case SecurityCardType.success:
        return AppColors.successBg;
      case SecurityCardType.info:
        return AppColors.infoBg;
    }
  }

  IconData get _icon {
    if (customIcon != null) return customIcon!;
    switch (type) {
      case SecurityCardType.warning:
        return LucideIcons.alertTriangle;
      case SecurityCardType.error:
        return LucideIcons.shieldAlert;
      case SecurityCardType.success:
        return LucideIcons.shieldCheck;
      case SecurityCardType.info:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: _borderColor.withValues(alpha: 0.3),
          width: AppDimensions.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: AppDimensions.iconNavigation, color: _borderColor),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.label.copyWith(
                        color: AppColors.ink,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      message,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: AppDimensions.space12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: _borderColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.label.copyWith(color: _borderColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
