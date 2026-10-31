import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/register_request_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
  );
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository: repository);
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authControllerProvider).user;
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthController({required this.repository}) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final isAuth = await repository.isAuthenticated();
    if (isAuth) {
      final user = await repository.getCurrentUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    }
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      final user = await repository.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        isLocked: false,
        clearErrors: true,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        isLocked: e.isLocked,
        lockoutEndUtc: e.lockoutEndUtc,
      );
      return false;
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        validationErrors: e.errors,
      );
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al iniciar sesión.',
      );
      return false;
    }
  }

  Future<bool> register(RegisterRequestModel request) async {
    state = state.copyWith(isLoading: true, clearErrors: true);
    try {
      await repository.register(request);
      state = state.copyWith(
        isLoading: false,
        clearErrors: true,
      );
      return true;
    } on ServerException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        validationErrors: e.errors,
      );
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error inesperado al registrar la cuenta.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await repository.logout();
    state = const AuthState();
  }
}

