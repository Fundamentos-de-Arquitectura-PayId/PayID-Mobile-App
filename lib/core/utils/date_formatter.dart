import 'package:intl/intl.dart';

/// Formateador de fechas para PayID
class DateFormatter {
  DateFormatter._();

  static final DateFormat _shortDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _longDate = DateFormat("d 'de' MMMM, yyyy", 'es_PE');
  static final DateFormat _monthYear = DateFormat('MM/yy');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String toShortDate(DateTime date) => _shortDate.format(date.toLocal());
  static String toLongDate(DateTime date) => _longDate.format(date.toLocal());
  static String toMonthYear(DateTime date) => _monthYear.format(date.toLocal());
  static String toDateTime(DateTime date) => _dateTime.format(date.toLocal());

  /// Retorna un tiempo relativo amigable (ej: "Hace 5 minutos", "Hoy", "Ayer")
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return _shortDate.format(date.toLocal());
    }
  }
}

