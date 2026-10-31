class TransactionEntity {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  bool get isIncome => amount > 0;
}

