import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Jerarquía tipográfica oficial de PayID (Biblioteca Figma PayID 1.0)
/// Familia exclusiva: Inter (400 Regular, 500 Medium, 600 Semibold)
class AppTypography {
  AppTypography._();

  static TextStyle display = GoogleFonts.inter(
    fontSize: 56,
    height: 64 / 56,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  static TextStyle heading1 = GoogleFonts.inter(
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextStyle heading2 = GoogleFonts.inter(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextStyle heading3 = GoogleFonts.inter(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static TextStyle lead = GoogleFonts.inter(
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static TextStyle helper = GoogleFonts.inter(
    fontSize: 12,
    height: 18 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = helper;
}
