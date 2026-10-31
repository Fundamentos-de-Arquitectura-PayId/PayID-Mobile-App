import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Tema visual oficial de la aplicación móvil PayID
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryInstitutional,
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryInstitutional,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.mint50,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.petroleum,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.fog,
        onSecondaryContainer: AppColors.petroleum,
        surface: AppColors.white,
        onSurface: AppColors.text,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.outline,
      ),

      // Tipografía Inter oficial
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        headlineSmall: AppTypography.heading3,
        bodyLarge: AppTypography.lead,
        bodyMedium: AppTypography.body,
        labelLarge: AppTypography.label,
        bodySmall: AppTypography.helper,
      ),

      // Tarjetas oficiales (border 1px #D7E0DA, radio 12px, sin elevación por defecto)
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(
            color: AppColors.line,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // Entradas de texto oficiales (48px alto, radio 8px, borde 1px #82958A)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.inputHorizontalPadding,
          vertical: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.outline, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.petroleum, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: const BorderSide(color: AppColors.error, width: 2.0),
        ),
        labelStyle: AppTypography.label.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.body.copyWith(color: AppColors.outline),
        helperStyle: AppTypography.helper,
        errorStyle: AppTypography.helper.copyWith(color: AppColors.error),
      ),

      // Botón elevado primario
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryInstitutional,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: AppTypography.label.copyWith(color: AppColors.white),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // Botón con borde secundario
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryInstitutional,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeightM),
          side: const BorderSide(color: AppColors.primaryInstitutional, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          textStyle: AppTypography.label.copyWith(color: AppColors.primaryInstitutional),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // Botón de texto terciario
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryInstitutional,
          textStyle: AppTypography.label.copyWith(color: AppColors.primaryInstitutional),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Barra superior
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading3.copyWith(color: AppColors.ink),
        iconTheme: const IconThemeData(
          color: AppColors.ink,
          size: AppDimensions.iconNavigation,
        ),
      ),

      // Divisor
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
