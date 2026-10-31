import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.servicio,
    required super.monto,
    required super.fecha,
    required super.userId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      servicio: json['servicio']?.toString() ?? 'Servicio',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      userId: json['userId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio': servicio,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'userId': userId,
    };
  }
}

