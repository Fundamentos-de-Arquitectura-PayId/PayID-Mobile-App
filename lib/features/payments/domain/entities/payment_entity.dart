class PaymentEntity {
  final String id;
  final String servicio;
  final double monto;
  final DateTime fecha;
  final String userId;

  const PaymentEntity({
    required this.id,
    required this.servicio,
    required this.monto,
    required this.fecha,
    required this.userId,
  });
}

