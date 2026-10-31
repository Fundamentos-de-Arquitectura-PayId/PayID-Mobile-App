import '../../../../core/utils/currency_formatter.dart';

class TransportCardEntity {
  final String id;
  final String userId;
  final String type; // ej: "Metropolitano", "Metro de Lima"
  final double balance;
  final String cardNumber;
  final DateTime lastRechargeDate;

  const TransportCardEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.balance,
    required this.cardNumber,
    required this.lastRechargeDate,
  });

  String get maskedNumber => CurrencyFormatter.maskCardNumber(cardNumber);
}

