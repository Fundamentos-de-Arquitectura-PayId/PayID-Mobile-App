import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuración de endpoints y URLs del backend ASP.NET Core
class ApiConfig {
  ApiConfig._();

  /// URL base por defecto según la plataforma de ejecución
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5117/api';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 conecta con el localhost del equipo host desde emulador Android
      return 'http://10.0.2.2:5117/api';
    }
    return 'http://localhost:5117/api';
  }

  /// URL base configurable
  static String baseUrl = defaultBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Rutas de API reales
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  static const String documents = '/documents';
  static String documentsByUser(String userId) => '/documents/user/$userId';

  static const String paymentCards = '/wallet/payment-cards';
  static String paymentCardsByUser(String userId) => '/wallet/payment-cards/user/$userId';
  static const String paymentCardsUpdateBalance = '/wallet/payment-cards/update-balance';
  static const String paymentCardsPayDebt = '/wallet/payment-cards/pay-debt';

  static const String transportCards = '/wallet/transport-cards';
  static String transportCardsByUser(String userId) => '/wallet/transport-cards/user/$userId';
  static const String transportCardsUpdateBalance = '/wallet/transport-cards/update-balance';
  static String transportCardsRecharge(String id) => '/wallet/transport-cards/$id/recharge';
  static String transportCardsTransactions(String id) => '/wallet/transport-cards/$id/transactions';

  static const String payments = '/payments';
  static String paymentsByUser(String userId) => '/payments/user/$userId';

  static const String notifications = '/notifications';
  static String notificationsByUser(String userId) => '/notifications/user/$userId';

  static const String supportTickets = '/support/tickets';
  static const String health = '/health';
}

