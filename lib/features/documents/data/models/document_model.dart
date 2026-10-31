import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.userId,
    required super.documentNumber,
    required super.fullName,
    required super.type,
    required super.status,
    required super.issueDate,
    super.expirationDate,
    super.filePath,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      documentNumber: json['documentNumber']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      type: _intToType(json['type']),
      status: _intToStatus(json['status']),
      issueDate: json['issueDate'] != null
          ? DateTime.tryParse(json['issueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'].toString())
          : null,
      filePath: json['filePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'documentNumber': documentNumber,
      'fullName': fullName,
      'type': _typeToInt(type),
      'status': _statusToInt(status),
      'issueDate': issueDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'filePath': filePath,
    };
  }

  static DocumentType _intToType(dynamic value) {
    final int val = value is int ? value : int.tryParse(value?.toString() ?? '1') ?? 1;
    switch (val) {
      case 2:
        return DocumentType.carnetExtranjeria;
      case 3:
        return DocumentType.pasaporte;
      case 4:
        return DocumentType.carnetUniversitario;
      case 1:
      default:
        return DocumentType.dni;
    }
  }

  static int _typeToInt(DocumentType type) {
    switch (type) {
      case DocumentType.dni:
        return 1;
      case DocumentType.carnetExtranjeria:
        return 2;
      case DocumentType.pasaporte:
        return 3;
      case DocumentType.carnetUniversitario:
        return 4;
    }
  }

  static DocumentStatus _intToStatus(dynamic value) {
    final int val = value is int ? value : int.tryParse(value?.toString() ?? '0') ?? 0;
    switch (val) {
      case 1:
        return DocumentStatus.verified;
      case 2:
        return DocumentStatus.rejected;
      case 0:
      default:
        return DocumentStatus.pending;
    }
  }

  static int _statusToInt(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 0;
      case DocumentStatus.verified:
        return 1;
      case DocumentStatus.rejected:
        return 2;
    }
  }
}

class CreateDocumentRequest {
  final String userId;
  final String documentNumber;
  final String fullName;
  final DocumentType type;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String? filePath;

  const CreateDocumentRequest({
    required this.userId,
    required this.documentNumber,
    required this.fullName,
    required this.type,
    required this.issueDate,
    this.expirationDate,
    this.filePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'documentNumber': documentNumber,
      'fullName': fullName,
      'type': DocumentModel._typeToInt(type),
      'issueDate': issueDate.toIso8601String(),
      if (expirationDate != null) 'expirationDate': expirationDate!.toIso8601String(),
      if (filePath != null) 'filePath': filePath,
    };
  }
}

