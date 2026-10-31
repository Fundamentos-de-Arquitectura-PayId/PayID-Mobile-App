import '../entities/document_entity.dart';
import '../../data/models/document_model.dart';

abstract class DocumentsRepository {
  Future<List<DocumentEntity>> getDocuments(String userId, {bool forceRefresh = false});
  Future<DocumentEntity> createDocument(CreateDocumentRequest request);
  String? getLastSyncTime(String userId);
}

