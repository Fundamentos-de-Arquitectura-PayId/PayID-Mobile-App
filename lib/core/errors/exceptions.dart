/// Excepciones lanzadas por DataSources y Clientes HTTP
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ServerException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final bool isLocked;
  final DateTime? lockoutEndUtc;

  AuthException({
    required this.message,
    this.statusCode,
    this.isLocked = false,
    this.lockoutEndUtc,
  });

  @override
  String toString() => 'AuthException: $message (locked: $isLocked)';
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

