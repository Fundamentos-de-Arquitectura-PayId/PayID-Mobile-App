import '../../domain/entities/payment_card_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transport_card_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? 'Operación',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

class PaymentCardModel extends PaymentCardEntity {
  const PaymentCardModel({
    required super.id,
    required super.userId,
    required super.fullNumber,
    required super.brand,
    required super.balance,
    required super.expiryDate,
    super.cvv,
    required super.accountNumber,
    required super.cci,
    required super.debtAmount,
    super.transactions,
  });

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    final rawTxs = json['transactions'];
    List<TransactionEntity> txList = [];
    if (rawTxs is List) {
      txList = rawTxs
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return PaymentCardModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullNumber: json['fullNumber']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Visa',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      expiryDate: json['expiryDate']?.toString() ?? '',
      cvv: null, // No persistir CVV
      accountNumber: json['accountNumber']?.toString() ?? '',
      cci: json['cci']?.toString() ?? '',
      debtAmount: (json['debtAmount'] as num?)?.toDouble() ?? 0.0,
      transactions: txList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullNumber': fullNumber,
      'brand': brand,
      'balance': balance,
      'expiryDate': expiryDate,
      'accountNumber': accountNumber,
      'cci': cci,
      'debtAmount': debtAmount,
      'transactions': transactions
          .map((t) => TransactionModel(
                id: t.id,
                description: t.description,
                amount: t.amount,
                date: t.date,
              ).toJson())
          .toList(),
    };
  }
}

class TransportCardModel extends TransportCardEntity {
  const TransportCardModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.balance,
    required super.cardNumber,
    required super.lastRechargeDate,
  });

  factory TransportCardModel.fromJson(Map<String, dynamic> json) {
    return TransportCardModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Metropolitano',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      cardNumber: json['cardNumber']?.toString() ?? '',
      lastRechargeDate: json['lastRechargeDate'] != null
          ? DateTime.tryParse(json['lastRechargeDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'balance': balance,
      'cardNumber': cardNumber,
      'lastRechargeDate': lastRechargeDate.toIso8601String(),
    };
  }
}

class CreatePaymentCardRequest {
  final String userId;
  final String fullNumber;
  final String brand;
  final double balance;
  final String expiryDate;
  final String cvv;

  const CreatePaymentCardRequest({
    required this.userId,
    required this.fullNumber,
    required this.brand,
    required this.balance,
    required this.expiryDate,
    required this.cvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullNumber': fullNumber,
      'brand': brand,
      'balance': balance,
      'expiryDate': expiryDate,
      'cvv': cvv,
    };
  }
}

class CreateTransportCardRequest {
  final String userId;
  final String type;
  final double balance;
  final String cardNumber;

  const CreateTransportCardRequest({
    required this.userId,
    required this.type,
    required this.balance,
    required this.cardNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'balance': balance,
      'cardNumber': cardNumber,
    };
  }
}

