import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/hive_storage_service.dart';
import '../storage/secure_storage_service.dart';

/// Proveedor de almacenamiento seguro
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Proveedor del cliente HTTP de PayID
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storageService: storage);
});

/// Proveedor del almacenamiento local Hive
final hiveStorageProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService.instance;
});

/// Proveedor de conectividad de red
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Estado de conexión actual simplificado
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => !results.contains(ConnectivityResult.none),
    loading: () => true,
    error: (_, _) => true,
  );
});
