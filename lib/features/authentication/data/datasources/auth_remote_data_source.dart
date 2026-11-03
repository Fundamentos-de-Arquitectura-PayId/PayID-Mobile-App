import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String emailOrPhone,
    required String password,
  });

  Future<String> register(RegisterRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LoginResponseModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConfig.authLogin,
      data: {
        'email': emailOrPhone,
        'telefono': emailOrPhone,
        'password': password,
      },
    );

    return LoginResponseModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<String> register(RegisterRequestModel request) async {
    final response = await apiClient.post(
      ApiConfig.authRegister,
      data: request.toJson(),
    );

    if (response is Map && response['id'] != null) {
      return response['id'].toString();
    }
    return '';
  }
}
