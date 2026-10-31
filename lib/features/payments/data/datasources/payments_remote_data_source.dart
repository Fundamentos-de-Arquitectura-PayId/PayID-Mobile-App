import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentModel>> getPaymentsByUser(String userId);
  Future<String> createPayment(PaymentModel payment);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final ApiClient apiClient;

  PaymentsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PaymentModel>> getPaymentsByUser(String userId) async {
    try {
      final response = await apiClient.get(ApiConfig.paymentsByUser(userId));
      if (response is List) {
        return response
            .map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      // Si el servidor responde 404 cuando no hay pagos, retornamos lista vacía
      return [];
    }
  }

  @override
  Future<String> createPayment(PaymentModel payment) async {
    final response = await apiClient.post(
      ApiConfig.payments,
      data: payment.toJson(),
    );
    if (response is Map && response['id'] != null) {
      return response['id'].toString();
    }
    return '';
  }
}

