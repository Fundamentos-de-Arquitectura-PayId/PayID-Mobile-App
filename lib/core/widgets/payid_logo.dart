import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum PayIdLogoSize {
  small,
  medium,
  large,
}

/// Logotipo oficial de PayID
/// Diseñado con la identidad visual oficial, colores institucionales y proporciones exactas.
class PayIdLogo extends StatelessWidget {
  final PayIdLogoSize size;
  final bool showTagline;
  final Color? color;

  const PayIdLogo({
    super.key,
    this.size = PayIdLogoSize.medium,
    this.showTagline = false,
    this.color,
  });

  double get _fontSize {
    switch (size) {
      case PayIdLogoSize.small:
        return 20.0;
      case PayIdLogoSize.medium:
        return 28.0;
      case PayIdLogoSize.large:
        return 40.0;
    }
  }

  double get _iconSize {
    switch (size) {
      case PayIdLogoSize.small:
        return 22.0;
      case PayIdLogoSize.medium:
        return 32.0;
      case PayIdLogoSize.large:
        return 46.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primaryInstitutional;

    final logoRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Símbolo de identidad PayID
        Container(
          width: _iconSize,
          height: _iconSize,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(
              size == PayIdLogoSize.large
                  ? AppDimensions.radiusCard
                  : AppDimensions.radiusInput,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.credit_card_rounded,
              color: AppColors.white,
              size: _iconSize * 0.6,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space8),

        // Nombre de marca "PayID"
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Pay',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const TextSpan(
                text: 'ID',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!showTagline) return logoRow;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoRow,
        const SizedBox(height: AppDimensions.space4),
        Text(
          'Identidad digital y pagos',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

