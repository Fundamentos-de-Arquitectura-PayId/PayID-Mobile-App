import '../entities/payment_entity.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentsRepository {
  Future<List<PaymentEntity>> getPayments(String userId);
  Future<String> createPayment(PaymentModel payment);
}

