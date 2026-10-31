import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';
import '../../data/datasources/documents_remote_data_source.dart';
import '../../data/models/document_model.dart';
import '../../data/repositories/documents_repository_impl.dart';

final documentsRemoteDataSourceProvider = Provider<DocumentsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DocumentsRemoteDataSourceImpl(apiClient: apiClient);
});

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final remote = ref.watch(documentsRemoteDataSourceProvider);
  final hive = ref.watch(hiveStorageProvider);
  return DocumentsRepositoryImpl(remoteDataSource: remote, hiveStorage: hive);
});

class DocumentsState {
  final bool isLoading;
  final List<DocumentEntity> documents;
  final bool isOfflineMode;
  final String? lastSyncTime;
  final String? errorMessage;
  final DocumentType? selectedFilter;

  const DocumentsState({
    this.isLoading = false,
    this.documents = const [],
    this.isOfflineMode = false,
    this.lastSyncTime,
    this.errorMessage,
    this.selectedFilter,
  });

  DocumentsState copyWith({
    bool? isLoading,
    List<DocumentEntity>? documents,
    bool? isOfflineMode,
    String? lastSyncTime,
    String? errorMessage,
    DocumentType? selectedFilter,
    bool clearFilter = false,
  }) {
    return DocumentsState(
      isLoading: isLoading ?? this.isLoading,
      documents: documents ?? this.documents,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }

  List<DocumentEntity> get filteredDocuments {
    if (selectedFilter == null) return documents;
    return documents.where((d) => d.type == selectedFilter).toList();
  }
}

final documentsControllerProvider =
    StateNotifierProvider<DocumentsController, DocumentsState>((ref) {
  final repository = ref.watch(documentsRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final controller = DocumentsController(repository: repository, userId: user?.id);
  if (user != null) {
    controller.loadDocuments();
  }
  return controller;
});

class DocumentsController extends StateNotifier<DocumentsState> {
  final DocumentsRepository repository;
  final String? userId;

  DocumentsController({
    required this.repository,
    this.userId,
  }) : super(const DocumentsState());

  Future<void> loadDocuments({bool forceRefresh = false}) async {
    if (userId == null || userId!.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final docs = await repository.getDocuments(userId!, forceRefresh: forceRefresh);
      final lastSync = repository.getLastSyncTime(userId!);
      state = state.copyWith(
        isLoading: false,
        documents: docs,
        isOfflineMode: false,
        lastSyncTime: lastSync,
      );
    } catch (_) {
      // Fallback a caché offline
      final lastSync = repository.getLastSyncTime(userId!);
      state = state.copyWith(
        isLoading: false,
        isOfflineMode: true,
        lastSyncTime: lastSync,
        errorMessage: state.documents.isEmpty
            ? 'Sin conexión. No hay documentos en caché local.'
            : null,
      );
    }
  }

  Future<bool> registerDocument(CreateDocumentRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final created = await repository.createDocument(request);
      state = state.copyWith(
        isLoading: false,
        documents: [created, ...state.documents],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo registrar el documento en el servidor.',
      );
      return false;
    }
  }

  void setFilter(DocumentType? type) {
    if (type == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(selectedFilter: type);
    }
  }
}
