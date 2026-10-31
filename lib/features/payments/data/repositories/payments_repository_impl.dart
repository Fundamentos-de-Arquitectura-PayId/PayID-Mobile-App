import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_data_source.dart';
import '../models/payment_model.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsRemoteDataSource remoteDataSource;

  PaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PaymentEntity>> getPayments(String userId) {
    return remoteDataSource.getPaymentsByUser(userId);
  }

  @override
  Future<String> createPayment(PaymentModel payment) {
    return remoteDataSource.createPayment(payment);
  }
}
