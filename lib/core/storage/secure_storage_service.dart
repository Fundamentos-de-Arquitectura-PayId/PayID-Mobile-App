import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenamiento seguro de credenciales y tokens JWT
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'payid_jwt_token';
  static const String _keyUserId = 'payid_user_id';
  static const String _keyUserData = 'payid_user_data_json';
  static const String _keyOnboardingSeen = 'payid_onboarding_seen';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> saveUserData(String jsonString) async {
    await _storage.write(key: _keyUserData, value: jsonString);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: _keyUserData);
  }

  Future<void> setOnboardingSeen(bool seen) async {
    await _storage.write(key: _keyOnboardingSeen, value: seen ? 'true' : 'false');
  }

  Future<bool> isOnboardingSeen() async {
    final value = await _storage.read(key: _keyOnboardingSeen);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserData);
  }
}
