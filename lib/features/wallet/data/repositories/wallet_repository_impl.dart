import '../../domain/entities/payment_card_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transport_card_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/wallet_models.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PaymentCardEntity>> getPaymentCards(String userId) {
    return remoteDataSource.getPaymentCards(userId);
  }

  @override
  Future<String> createPaymentCard(CreatePaymentCardRequest request) {
    return remoteDataSource.createPaymentCard(request);
  }

  @override
  Future<bool> updatePaymentBalance({
    required String cardId,
    required double newBalance,
    required String description,
    required double transactionAmount,
  }) {
    return remoteDataSource.updatePaymentBalance(
      cardId: cardId,
      newBalance: newBalance,
      description: description,
      transactionAmount: transactionAmount,
    );
  }

  @override
  Future<bool> payDebt(String cardId) {
    return remoteDataSource.payDebt(cardId);
  }

  @override
  Future<List<TransportCardEntity>> getTransportCards(String userId) {
    return remoteDataSource.getTransportCards(userId);
  }

  @override
  Future<String> createTransportCard(CreateTransportCardRequest request) {
    return remoteDataSource.createTransportCard(request);
  }

  @override
  Future<Map<String, dynamic>> rechargeTransportCard({
    required String transportCardId,
    String? paymentCardId,
    required double amount,
  }) {
    return remoteDataSource.rechargeTransportCard(
      transportCardId: transportCardId,
      paymentCardId: paymentCardId,
      amount: amount,
    );
  }

  @override
  Future<List<TransactionEntity>> getTransportTransactions(String transportCardId) {
    return remoteDataSource.getTransportTransactions(transportCardId);
  }
}
