enum DocumentType {
  dni, // 1
  carnetExtranjeria, // 2
  pasaporte, // 3
  carnetUniversitario, // 4
}

enum DocumentStatus {
  pending, // 0
  verified, // 1
  rejected, // 2
}

class DocumentEntity {
  final String id;
  final String userId;
  final String documentNumber;
  final String fullName;
  final DocumentType type;
  final DocumentStatus status;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? filePath;

  const DocumentEntity({
    required this.id,
    required this.userId,
    required this.documentNumber,
    required this.fullName,
    required this.type,
    required this.status,
    required this.issueDate,
    this.expirationDate,
    this.filePath,
  });

  String get typeName {
    switch (type) {
      case DocumentType.dni:
        return 'DNI (Documento Nacional)';
      case DocumentType.carnetExtranjeria:
        return 'Carné de Extranjería';
      case DocumentType.pasaporte:
        return 'Pasaporte';
      case DocumentType.carnetUniversitario:
        return 'Carné Universitario';
    }
  }

  String get shortTypeName {
    switch (type) {
      case DocumentType.dni:
        return 'DNI';
      case DocumentType.carnetExtranjeria:
        return 'C.E.';
      case DocumentType.pasaporte:
        return 'Pasaporte';
      case DocumentType.carnetUniversitario:
        return 'Carné Univ.';
    }
  }

  String get statusName {
    switch (status) {
      case DocumentStatus.verified:
        return 'Vigente y Verificado';
      case DocumentStatus.pending:
        return 'En Proceso de Validación';
      case DocumentStatus.rejected:
        return 'Observado / Rechazado';
    }
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final now = DateTime.now();
    final diff = expirationDate!.difference(now).inDays;
    return diff >= 0 && diff <= 30;
  }
}

