import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/payment_card_entity.dart';
import '../../domain/entities/transport_card_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/wallet_models.dart';
import '../../data/repositories/wallet_repository_impl.dart';

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSourceImpl(apiClient: apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final remote = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepositoryImpl(remoteDataSource: remote);
});

class WalletState {
  final bool isLoading;
  final List<PaymentCardEntity> paymentCards;
  final List<TransportCardEntity> transportCards;
  final String? errorMessage;
  final bool isOperationInProgress;

  const WalletState({
    this.isLoading = false,
    this.paymentCards = const [],
    this.transportCards = const [],
    this.errorMessage,
    this.isOperationInProgress = false,
  });

  double get totalPaymentBalance {
    return paymentCards.fold(0.0, (acc, card) => acc + card.balance);
  }

  double get totalTransportBalance {
    return transportCards.fold(0.0, (acc, card) => acc + card.balance);
  }

  double get totalDebt {
    return paymentCards.fold(0.0, (acc, card) => acc + card.debtAmount);
  }

  WalletState copyWith({
    bool? isLoading,
    List<PaymentCardEntity>? paymentCards,
    List<TransportCardEntity>? transportCards,
    String? errorMessage,
    bool? isOperationInProgress,
    bool clearError = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      paymentCards: paymentCards ?? this.paymentCards,
      transportCards: transportCards ?? this.transportCards,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOperationInProgress: isOperationInProgress ?? this.isOperationInProgress,
    );
  }
}

final walletControllerProvider =
    StateNotifierProvider<WalletController, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final controller = WalletController(repository: repository, userId: user?.id);
  if (user != null) {
    controller.loadWallet();
  }
  return controller;
});

class WalletController extends StateNotifier<WalletState> {
  final WalletRepository repository;
  final String? userId;

  WalletController({required this.repository, this.userId})
      : super(const WalletState());

  Future<void> loadWallet() async {
    if (userId == null || userId!.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final paymentsFuture = repository.getPaymentCards(userId!);
      final transportsFuture = repository.getTransportCards(userId!);

      final results = await Future.wait([paymentsFuture, transportsFuture]);

      state = state.copyWith(
        isLoading: false,
        paymentCards: results[0] as List<PaymentCardEntity>,
        transportCards: results[1] as List<TransportCardEntity>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar la información de la billetera.',
      );
    }
  }

  Future<bool> createPaymentCard(CreatePaymentCardRequest request) async {
    state = state.copyWith(isOperationInProgress: true, clearError: true);
    try {
      await repository.createPaymentCard(request);
      await loadWallet();
      state = state.copyWith(isOperationInProgress: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isOperationInProgress: false,
        errorMessage: 'No se pudo registrar la tarjeta de pago.',
      );
      return false;
    }
  }

  Future<bool> createTransportCard(CreateTransportCardRequest request) async {
    state = state.copyWith(isOperationInProgress: true, clearError: true);
    try {
      await repository.createTransportCard(request);
      await loadWallet();
      state = state.copyWith(isOperationInProgress: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isOperationInProgress: false,
        errorMessage: 'No se pudo registrar la tarjeta de transporte.',
      );
      return false;
    }
  }

  Future<bool> rechargeTransport({
    required String transportCardId,
    String? paymentCardId,
    required double amount,
  }) async {
    state = state.copyWith(isOperationInProgress: true, clearError: true);
    try {
      await repository.rechargeTransportCard(
        transportCardId: transportCardId,
        paymentCardId: paymentCardId,
        amount: amount,
      );
      await loadWallet();
      state = state.copyWith(isOperationInProgress: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isOperationInProgress: false,
        errorMessage: 'Error al recargar tarjeta: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> payDebt(String cardId) async {
    state = state.copyWith(isOperationInProgress: true, clearError: true);
    try {
      final success = await repository.payDebt(cardId);
      if (success) {
        await loadWallet();
      }
      state = state.copyWith(isOperationInProgress: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isOperationInProgress: false,
        errorMessage: 'Saldo insuficiente o error al pagar la deuda.',
      );
      return false;
    }
  }
}
