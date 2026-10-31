import 'transaction_entity.dart';
import '../../../../core/utils/currency_formatter.dart';

class PaymentCardEntity {
  final String id;
  final String userId;
  final String fullNumber;
  final String brand;
  final double balance;
  final String expiryDate;
  final String? cvv; // No persistir sensiblemente
  final String accountNumber;
  final String cci;
  final double debtAmount;
  final List<TransactionEntity> transactions;

  const PaymentCardEntity({
    required this.id,
    required this.userId,
    required this.fullNumber,
    required this.brand,
    required this.balance,
    required this.expiryDate,
    this.cvv,
    required this.accountNumber,
    required this.cci,
    required this.debtAmount,
    this.transactions = const [],
  });

  String get maskedNumber => CurrencyFormatter.maskCardNumber(fullNumber);

  bool get hasDebt => debtAmount > 0;
}

