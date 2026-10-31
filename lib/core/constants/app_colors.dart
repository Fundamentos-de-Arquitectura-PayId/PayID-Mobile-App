import 'package:flutter/material.dart';

/// Paleta de colores oficial de PayID (Biblioteca Figma PayID 1.0)
class AppColors {
  AppColors._();

  // Colores principales
  /// Verde institucional: Identidad de PayID. No usar automáticamente para éxito.
  static const Color primaryInstitutional = Color(0xFF00763E);
  static const Color primaryDeep = Color(0xFF005D32);
  static const Color primaryDark = Color(0xFF004626);
  static const Color brandGray = Color(0xFF77797C);

  // Colores secundarios
  static const Color petroleum = Color(0xFF12646B); // Usado también para Focus Ring
  static const Color fog = Color(0xFFEAF3F4);
  static const Color softLime = Color(0xFFD9E8B2);
  static const Color mint50 = Color(0xFFEAF5EE);
  static const Color mint200 = Color(0xFFB8DCC8);

  // Escala neutra
  static const Color ink = Color(0xFF182B24); // Tinta más oscura
  static const Color text = Color(0xFF34463E); // Texto principal
  static const Color textSecondary = Color(0xFF617269); // Texto secundario
  static const Color outline = Color(0xFF82958A); // Contorno para inputs
  static const Color line = Color(0xFFD7E0DA); // Línea divisoria y bordes de tarjeta
  static const Color canvas = Color(0xFFF3F6F3); // Fondo de la app (Lienzo)
  static const Color white = Color(0xFFFFFFFF);

  // Estados semánticos (Texto e Iconos)
  static const Color success = Color(0xFF006B3C);
  static const Color warning = Color(0xFF805500);
  static const Color error = Color(0xFFB32935);
  static const Color info = Color(0xFF245DA8);

  // Fondos semánticos
  static const Color successBg = Color(0xFFEAF5EE);
  static const Color warningBg = Color(0xFFFFF4D6);
  static const Color errorBg = Color(0xFFFDEEF0);
  static const Color infoBg = Color(0xFFEDF3FC);
}

