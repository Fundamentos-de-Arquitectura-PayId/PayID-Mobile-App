import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../../data/datasources/payments_remote_data_source.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payments_repository_impl.dart';

final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentsRemoteDataSourceImpl(apiClient: apiClient);
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final remote = ref.watch(paymentsRemoteDataSourceProvider);
  return PaymentsRepositoryImpl(remoteDataSource: remote);
});

class PaymentsState {
  final bool isLoading;
  final List<PaymentEntity> payments;
  final String? errorMessage;
  final bool isCreating;

  const PaymentsState({
    this.isLoading = false,
    this.payments = const [],
    this.errorMessage,
    this.isCreating = false,
  });

  PaymentsState copyWith({
    bool? isLoading,
    List<PaymentEntity>? payments,
    String? errorMessage,
    bool? isCreating,
    bool clearError = false,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

final paymentsControllerProvider =
    StateNotifierProvider<PaymentsController, PaymentsState>((ref) {
  final repository = ref.watch(paymentsRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final controller = PaymentsController(repository: repository, userId: user?.id);
  if (user != null) {
    controller.loadPayments();
  }
  return controller;
});

class PaymentsController extends StateNotifier<PaymentsState> {
  final PaymentsRepository repository;
  final String? userId;

  PaymentsController({required this.repository, this.userId})
      : super(const PaymentsState());

  Future<void> loadPayments() async {
    if (userId == null || userId!.isEmpty) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await repository.getPayments(userId!);
      list.sort((a, b) => b.fecha.compareTo(a.fecha));
      state = state.copyWith(isLoading: false, payments: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el historial de pagos.',
      );
    }
  }

  Future<bool> createPayment({
    required String servicio,
    required double monto,
  }) async {
    if (userId == null) return false;

    state = state.copyWith(isCreating: true, clearError: true);
    try {
      final model = PaymentModel(
        id: '',
        servicio: servicio,
        monto: monto,
        fecha: DateTime.now(),
        userId: userId!,
      );

      await repository.createPayment(model);
      await loadPayments();
      state = state.copyWith(isCreating: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        errorMessage: 'Error al registrar el pago.',
      );
      return false;
    }
  }
}
