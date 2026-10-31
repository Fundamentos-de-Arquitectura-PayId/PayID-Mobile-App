/// Entidad de usuario para la capa de dominio de PayID
class UserEntity {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String dni;
  final DateTime fechaNacimiento;
  final bool esUniversitario;
  final bool premium;

  const UserEntity({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    required this.dni,
    required this.fechaNacimiento,
    required this.esUniversitario,
    this.premium = false,
  });

  /// Retorna las iniciales del usuario (ej: "Juan Pérez" -> "JP")
  String get initials {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Retorna el primer nombre del usuario
  String get firstName {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts[0] : nombre;
  }
}

