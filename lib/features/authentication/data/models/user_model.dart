import '../../domain/entities/user_entity.dart';

/// Modelo de usuario serializable para el backend de ASP.NET Core
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nombre,
    required super.email,
    super.telefono,
    required super.dni,
    required super.fechaNacimiento,
    required super.esUniversitario,
    super.premium,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      dni: json['dni']?.toString() ?? '',
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.tryParse(json['fechaNacimiento'].toString()) ?? DateTime.now()
          : DateTime.now(),
      esUniversitario: json['esUniversitario'] == true,
      premium: json['premium'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'dni': dni,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'esUniversitario': esUniversitario,
      'premium': premium,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      nombre: entity.nombre,
      email: entity.email,
      telefono: entity.telefono,
      dni: entity.dni,
      fechaNacimiento: entity.fechaNacimiento,
      esUniversitario: entity.esUniversitario,
      premium: entity.premium,
    );
  }
}

