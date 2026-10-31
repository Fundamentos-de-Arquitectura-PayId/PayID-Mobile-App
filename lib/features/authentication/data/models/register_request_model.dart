/// DTO para el comando de registro en `POST /api/auth/register`
class RegisterRequestModel {
  final String nombre;
  final String? email;
  final String? telefono;
  final String password;
  final String dni;
  final DateTime fechaNacimiento;
  final bool esUniversitario;

  const RegisterRequestModel({
    required this.nombre,
    this.email,
    this.telefono,
    required this.password,
    required this.dni,
    required this.fechaNacimiento,
    required this.esUniversitario,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
      'password': password,
      'dni': dni,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'esUniversitario': esUniversitario,
    };
  }
}

