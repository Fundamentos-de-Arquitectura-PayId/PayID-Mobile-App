class FamilyMemberEntity {
  final String id;
  final String parentUserId;
  final String fullName;
  final String relationship; // "Hijo/a", "Cónyuge", "Padre/Madre", "Hermano/a"
  final String dni;
  final DateTime birthDate;
  final bool isStudent;
  final String? notes;

  const FamilyMemberEntity({
    required this.id,
    required this.parentUserId,
    required this.fullName,
    required this.relationship,
    required this.dni,
    required this.birthDate,
    required this.isStudent,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentUserId': parentUserId,
      'fullName': fullName,
      'relationship': relationship,
      'dni': dni,
      'birthDate': birthDate.toIso8601String(),
      'isStudent': isStudent,
      'notes': notes,
    };
  }

  factory FamilyMemberEntity.fromJson(Map<String, dynamic> json) {
    return FamilyMemberEntity(
      id: json['id']?.toString() ?? '',
      parentUserId: json['parentUserId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'Familiar',
      dni: json['dni']?.toString() ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isStudent: json['isStudent'] == true,
      notes: json['notes']?.toString(),
    );
  }

  /// Construye la entidad desde la respuesta de `/api/family/members`.
  /// `isStudent` y `notes` no existen en el backend; se completan desde la caché local.
  factory FamilyMemberEntity.fromApiJson(
    Map<String, dynamic> json, {
    bool isStudent = false,
    String? notes,
  }) {
    return FamilyMemberEntity(
      id: json['id']?.toString() ?? '',
      parentUserId: json['guardianUserId']?.toString() ?? '',
      fullName: json['name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'Familiar',
      dni: json['documentNumber']?.toString() ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isStudent: isStudent,
      notes: notes,
    );
  }

  /// Cuerpo `FamilyMemberInput` esperado por el backend.
  Map<String, dynamic> toApiJson() {
    return {
      'name': fullName,
      'relationship': relationship,
      'documentType': 'DNI',
      'documentNumber': dni,
      'birthDate': DateTime.utc(birthDate.year, birthDate.month, birthDate.day)
          .toIso8601String(),
    };
  }
}
