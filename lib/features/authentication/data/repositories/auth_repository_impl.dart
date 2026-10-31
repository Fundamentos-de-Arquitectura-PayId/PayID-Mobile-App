import 'dart:convert';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<UserEntity> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );

    // Guardar token JWT y datos del usuario de forma segura
    await secureStorage.saveToken(response.token);
    await secureStorage.saveUserId(response.user.id);
    await secureStorage.saveUserData(jsonEncode(response.user.toJson()));

    return response.user;
  }

  @override
  Future<String> register(RegisterRequestModel request) async {
    return await remoteDataSource.register(request);
  }

  @override
  Future<void> logout() async {
    await secureStorage.clearAll();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final jsonString = await secureStorage.getUserData();
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final map = jsonDecode(jsonString);
      return UserModel.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}

