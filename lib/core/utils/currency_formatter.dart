import 'package:intl/intl.dart';

/// Formateador de moneda en soles peruanos (PEN - S/)
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _penFormat = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  /// Convierte un monto decimal a formato "S/ 1,250.00"
  static String format(num amount) {
    return _penFormat.format(amount);
  }

  /// Formatea sin el prefijo "S/ "
  static String formatNumberOnly(num amount) {
    final format = NumberFormat('#,##0.00', 'es_PE');
    return format.format(amount);
  }

  /// Enmascara un número de tarjeta mostrando solo los últimos 4 dígitos
  /// Ejemplo: "**** **** **** 1234"
  static String maskCardNumber(String fullNumber) {
    final clean = fullNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.length < 4) return '•••• •••• •••• ••••';
    final last4 = clean.substring(clean.length - 4);
    return '•••• •••• •••• $last4';
  }
}

