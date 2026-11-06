import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Configuración de endpoints y URLs del backend ASP.NET Core
class ApiConfig {
  ApiConfig._();

  /// URL base del backend en la nube (Render)
  static const String renderBaseUrl = 'https://payid-backend-n573.onrender.com/api';

  /// URL base para desarrollo local (opcional)
  static String get localBaseUrl {
    if (kIsWeb) return 'http://localhost:5117/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5117/api';
    return 'http://localhost:5117/api';
  }

  /// URL base activa por defecto (conectada a Render)
  static String get defaultBaseUrl => renderBaseUrl;

  /// URL base configurable
  static String baseUrl = defaultBaseUrl;

  /// Render en su capa gratuita puede requerir tiempo de arranque inicial (cold start)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Rutas de API reales
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  static const String documents = '/documents';
  static String documentsByUser(String userId) => '/documents/user/$userId';

  static const String paymentCards = '/wallet/payment-cards';
  static String paymentCardsByUser(String userId) =>
      '/wallet/payment-cards/user/$userId';
  static const String paymentCardsUpdateBalance =
      '/wallet/payment-cards/update-balance';
  static const String paymentCardsPayDebt = '/wallet/payment-cards/pay-debt';

  static const String transportCards = '/wallet/transport-cards';
  static String transportCardsByUser(String userId) =>
      '/wallet/transport-cards/user/$userId';
  static const String transportCardsUpdateBalance =
      '/wallet/transport-cards/update-balance';
  static String transportCardsRecharge(String id) =>
      '/wallet/transport-cards/$id/recharge';
  static String transportCardsTransactions(String id) =>
      '/wallet/transport-cards/$id/transactions';

  static const String payments = '/payments';
  static String paymentsByUser(String userId) => '/payments/user/$userId';

  static const String notifications = '/notifications';
  static String notificationsByUser(String userId) =>
      '/notifications/user/$userId';

  static const String supportTickets = '/support/tickets';

  static const String familyMembers = '/family/members';
  static String familyMember(String id) => '/family/members/$id';

  /// El health check vive en la raíz del servidor (sin el prefijo /api)
  static String get healthUrl =>
      '${baseUrl.replaceFirst(RegExp(r'/api/?$'), '')}/health';
}
