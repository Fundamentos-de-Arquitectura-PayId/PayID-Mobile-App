import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';
import '../datasources/documents_remote_data_source.dart';
import '../models/document_model.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsRemoteDataSource remoteDataSource;
  final HiveStorageService hiveStorage;

  DocumentsRepositoryImpl({
    required this.remoteDataSource,
    required this.hiveStorage,
  });

  @override
  Future<List<DocumentEntity>> getDocuments(String userId, {bool forceRefresh = false}) async {
    try {
      final remoteList = await remoteDataSource.getDocumentsByUser(userId);

      // Guardar en Hive para soporte offline (US11)
      final rawMaps = remoteList.map((doc) => doc.toJson()).toList();
      await hiveStorage.saveDocuments(userId, rawMaps);

      return remoteList;
    } catch (_) {
      // Si falla la red, cargar de la caché local
      final localMaps = hiveStorage.getDocuments(userId);
      if (localMaps.isNotEmpty) {
        return localMaps.map((map) => DocumentModel.fromJson(map)).toList();
      }
      rethrow;
    }
  }

  @override
  Future<DocumentEntity> createDocument(CreateDocumentRequest request) async {
    final created = await remoteDataSource.createDocument(request);

    // Actualizar caché local
    final currentDocs = hiveStorage.getDocuments(request.userId);
    currentDocs.insert(0, created.toJson());
    await hiveStorage.saveDocuments(request.userId, currentDocs);

    return created;
  }

  @override
  String? getLastSyncTime(String userId) {
    return hiveStorage.getDocumentsLastSyncTime(userId);
  }
}
