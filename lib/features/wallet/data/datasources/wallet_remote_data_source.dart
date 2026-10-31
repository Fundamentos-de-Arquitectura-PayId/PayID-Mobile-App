import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_models.dart';

abstract class WalletRemoteDataSource {
  Future<List<PaymentCardModel>> getPaymentCards(String userId);
  Future<String> createPaymentCard(CreatePaymentCardRequest request);
  Future<bool> updatePaymentBalance({
    required String cardId,
    required double newBalance,
    required String description,
    required double transactionAmount,
  });
  Future<bool> payDebt(String cardId);

  Future<List<TransportCardModel>> getTransportCards(String userId);
  Future<String> createTransportCard(CreateTransportCardRequest request);
  Future<Map<String, dynamic>> rechargeTransportCard({
    required String transportCardId,
    String? paymentCardId,
    required double amount,
  });
  Future<List<TransactionModel>> getTransportTransactions(String transportCardId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient apiClient;

  WalletRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PaymentCardModel>> getPaymentCards(String userId) async {
    final response = await apiClient.get(ApiConfig.paymentCardsByUser(userId));
    if (response is List) {
      return response
          .map((item) => PaymentCardModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  @override
  Future<String> createPaymentCard(CreatePaymentCardRequest request) async {
    final response = await apiClient.post(
      ApiConfig.paymentCards,
      data: request.toJson(),
    );
    if (response is Map && response['id'] != null) {
      return response['id'].toString();
    }
    return '';
  }

  @override
  Future<bool> updatePaymentBalance({
    required String cardId,
    required double newBalance,
    required String description,
    required double transactionAmount,
  }) async {
    final response = await apiClient.put(
      ApiConfig.paymentCardsUpdateBalance,
      data: {
        'cardId': cardId,
        'newBalance': newBalance,
        'description': description,
        'transactionAmount': transactionAmount,
      },
    );
    return response is Map && response['success'] == true;
  }

  @override
  Future<bool> payDebt(String cardId) async {
    final response = await apiClient.put(
      ApiConfig.paymentCardsPayDebt,
      data: {'cardId': cardId},
    );
    return response is Map && response['success'] == true;
  }

  @override
  Future<List<TransportCardModel>> getTransportCards(String userId) async {
    final response = await apiClient.get(ApiConfig.transportCardsByUser(userId));
    if (response is List) {
      return response
          .map((item) => TransportCardModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  @override
  Future<String> createTransportCard(CreateTransportCardRequest request) async {
    final response = await apiClient.post(
      ApiConfig.transportCards,
      data: request.toJson(),
    );
    if (response is Map && response['id'] != null) {
      return response['id'].toString();
    }
    return '';
  }

  @override
  Future<Map<String, dynamic>> rechargeTransportCard({
    required String transportCardId,
    String? paymentCardId,
    required double amount,
  }) async {
    final response = await apiClient.post(
      ApiConfig.transportCardsRecharge(transportCardId),
      data: {
        'paymentCardId': ?paymentCardId,
        'amount': amount,
      },
    );
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<List<TransactionModel>> getTransportTransactions(String transportCardId) async {
    final response = await apiClient.get(ApiConfig.transportCardsTransactions(transportCardId));
    if (response is List) {
      return response
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }
}
