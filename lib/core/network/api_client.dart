import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage_service.dart';

/// Cliente HTTP principal basado en Dio para interactuar con la API REST de PayID
class ApiClient {
  final Dio dio;
  final SecureStorageService storageService;

  ApiClient({
    required this.storageService,
    Dio? customDio,
  }) : dio = customDio ?? Dio() {
    dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Permitir que códigos de error específicos sean procesados por el interceptor
        return status != null && status < 500;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return _processResponse(response);
    } on DioException catch (e) {
      throw _processDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _processDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _processDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _processDioError(e);
    }
  }

  dynamic _processResponse(Response response) {
    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    // Manejo de errores específicos del backend de PayID
    if (statusCode == 401) {
      String message = 'Credenciales incorrectas.';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
      throw AuthException(message: message, statusCode: 401);
    }

    if (statusCode == 423) {
      // Bloqueo por 5 intentos fallidos (US22)
      String message = 'Cuenta bloqueada temporalmente por intentos fallidos.';
      DateTime? lockoutEndUtc;
      if (data is Map) {
        if (data['message'] != null) message = data['message'].toString();
        if (data['lockoutEndUtc'] != null) {
          lockoutEndUtc = DateTime.tryParse(data['lockoutEndUtc'].toString());
        }
      }
      throw AuthException(
        message: message,
        statusCode: 423,
        isLocked: true,
        lockoutEndUtc: lockoutEndUtc,
      );
    }

    if (statusCode == 409) {
      String message = 'La cuenta ya está registrada.';
      Map<String, dynamic>? errors;
      if (data is Map) {
        if (data['message'] != null) message = data['message'].toString();
        if (data['errors'] is Map) {
          errors = Map<String, dynamic>.from(data['errors']);
        }
      }
      throw ServerException(message: message, statusCode: 409, errors: errors);
    }

    if (statusCode == 400) {
      String message = 'Datos inválidos.';
      Map<String, dynamic>? errors;
      if (data is Map) {
        if (data['message'] != null) message = data['message'].toString();
        if (data['errors'] is Map) {
          errors = Map<String, dynamic>.from(data['errors']);
        }
      } else if (data is String) {
        message = data;
      }
      throw ServerException(message: message, statusCode: 400, errors: errors);
    }

    if (statusCode == 404) {
      throw ServerException(
        message: data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Recurso no encontrado.',
        statusCode: 404,
      );
    }

    throw ServerException(
      message: 'Error en el servidor ($statusCode). Inténtalo más tarde.',
      statusCode: statusCode,
    );
  }

  Exception _processDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'No se pudo conectar con el servidor de PayID. Verifica tu conexión de red.',
      );
    }

    if (e.response != null) {
      return _processResponse(e.response!);
    }

    return ServerException(
      message: e.message ?? 'Error inesperado de comunicación.',
    );
  }
}
