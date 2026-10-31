import '../entities/payment_card_entity.dart';
import '../entities/transaction_entity.dart';
import '../entities/transport_card_entity.dart';
import '../../data/models/wallet_models.dart';

abstract class WalletRepository {
  Future<List<PaymentCardEntity>> getPaymentCards(String userId);
  Future<String> createPaymentCard(CreatePaymentCardRequest request);
  Future<bool> updatePaymentBalance({
    required String cardId,
    required double newBalance,
    required String description,
    required double transactionAmount,
  });
  Future<bool> payDebt(String cardId);

  Future<List<TransportCardEntity>> getTransportCards(String userId);
  Future<String> createTransportCard(CreateTransportCardRequest request);
  Future<Map<String, dynamic>> rechargeTransportCard({
    required String transportCardId,
    String? paymentCardId,
    required double amount,
  });
  Future<List<TransactionEntity>> getTransportTransactions(String transportCardId);
}

