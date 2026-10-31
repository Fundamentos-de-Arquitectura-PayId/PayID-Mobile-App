import 'package:hive_flutter/hive_flutter.dart';

/// Servicio de almacenamiento local con Hive para soporte offline y datos locales
class HiveStorageService {
  HiveStorageService._();
  static final HiveStorageService instance = HiveStorageService._();

  static const String documentsBoxName = 'payid_documents_cache';
  static const String familyProfilesBoxName = 'payid_family_profiles';
  static const String notificationsBoxName = 'payid_notifications_cache';
  static const String settingsBoxName = 'payid_settings';

  late Box<dynamic> documentsBox;
  late Box<dynamic> familyProfilesBox;
  late Box<dynamic> notificationsBox;
  late Box<dynamic> settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    documentsBox = await Hive.openBox(documentsBoxName);
    familyProfilesBox = await Hive.openBox(familyProfilesBoxName);
    notificationsBox = await Hive.openBox(notificationsBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  // --- Operaciones de Documentos Offline ---
  Future<void> saveDocuments(String userId, List<Map<String, dynamic>> docs) async {
    await documentsBox.put('docs_$userId', docs);
    await documentsBox.put('docs_sync_time_$userId', DateTime.now().toIso8601String());
  }

  List<Map<String, dynamic>> getDocuments(String userId) {
    final raw = documentsBox.get('docs_$userId');
    if (raw == null) return [];
    return (raw as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  String? getDocumentsLastSyncTime(String userId) {
    return documentsBox.get('docs_sync_time_$userId') as String?;
  }

  // --- Operaciones de Perfiles Familiares Locales (US2) ---
  Future<void> saveFamilyMembers(String userId, List<Map<String, dynamic>> members) async {
    await familyProfilesBox.put('family_$userId', members);
  }

  List<Map<String, dynamic>> getFamilyMembers(String userId) {
    final raw = familyProfilesBox.get('family_$userId');
    if (raw == null) return [];
    return (raw as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  // --- Operaciones de Notificaciones Locales / Estado de Lectura ---
  Future<void> saveReadNotificationIds(List<String> ids) async {
    await notificationsBox.put('read_notification_ids', ids);
  }

  List<String> getReadNotificationIds() {
    final raw = notificationsBox.get('read_notification_ids');
    if (raw == null) return [];
    return List<String>.from(raw as List);
  }
}

