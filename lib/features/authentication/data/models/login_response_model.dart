import 'user_model.dart';

/// Respuesta de login que devuelve el backend en `POST /api/auth/login`
class LoginResponseModel {
  final UserModel user;
  final String token;

  const LoginResponseModel({
    required this.user,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] ?? {})),
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}
