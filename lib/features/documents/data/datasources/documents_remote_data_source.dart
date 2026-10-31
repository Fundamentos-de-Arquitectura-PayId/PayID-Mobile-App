import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/document_model.dart';

abstract class DocumentsRemoteDataSource {
  Future<List<DocumentModel>> getDocumentsByUser(String userId);
  Future<DocumentModel> createDocument(CreateDocumentRequest request);
}

class DocumentsRemoteDataSourceImpl implements DocumentsRemoteDataSource {
  final ApiClient apiClient;

  DocumentsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DocumentModel>> getDocumentsByUser(String userId) async {
    final response = await apiClient.get(ApiConfig.documentsByUser(userId));
    if (response is List) {
      return response
          .map((item) => DocumentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  @override
  Future<DocumentModel> createDocument(CreateDocumentRequest request) async {
    final response = await apiClient.post(
      ApiConfig.documents,
      data: request.toJson(),
    );
    return DocumentModel.fromJson(Map<String, dynamic>.from(response));
  }
}

