import '../entities/user_entity.dart';
import '../../data/models/register_request_model.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String emailOrPhone,
    required String password,
  });

  Future<String> register(RegisterRequestModel request);

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();

  Future<bool> isAuthenticated();
}

