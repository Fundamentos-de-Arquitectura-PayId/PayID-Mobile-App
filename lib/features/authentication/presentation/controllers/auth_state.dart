import '../../domain/entities/user_entity.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserEntity? user;
  final String? errorMessage;
  final Map<String, dynamic>? validationErrors;
  final bool isLocked;
  final DateTime? lockoutEndUtc;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.validationErrors,
    this.isLocked = false,
    this.lockoutEndUtc,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserEntity? user,
    String? errorMessage,
    Map<String, dynamic>? validationErrors,
    bool? isLocked,
    DateTime? lockoutEndUtc,
    bool clearErrors = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      validationErrors: clearErrors ? null : (validationErrors ?? this.validationErrors),
      isLocked: isLocked ?? this.isLocked,
      lockoutEndUtc: lockoutEndUtc ?? this.lockoutEndUtc,
    );
  }
}

