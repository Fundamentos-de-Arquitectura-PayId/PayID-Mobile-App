/// Clases de fallo para capas de dominio y presentación
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;

  const ServerFailure(
    super.message, {
    this.statusCode,
    this.validationErrors,
  });
}

class AuthFailure extends Failure {
  final bool isLocked;
  final DateTime? lockoutEndUtc;

  const AuthFailure(
    super.message, {
    this.isLocked = false,
    this.lockoutEndUtc,
  });
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

