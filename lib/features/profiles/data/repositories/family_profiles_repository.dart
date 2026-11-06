import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/family_member_entity.dart';

/// Perfiles familiares sincronizados con `/api/family/members` (US2).
///
/// El backend es la fuente de verdad. Hive guarda una copia para uso sin
/// conexión y los campos que el backend no maneja (`isStudent`, `notes`).
class FamilyProfilesRepository {
  final ApiClient apiClient;
  final HiveStorageService hiveStorage;

  FamilyProfilesRepository({
    required this.apiClient,
    required this.hiveStorage,
  });

  List<FamilyMemberEntity> getCachedMembers(String userId) {
    return hiveStorage
        .getFamilyMembers(userId)
        .map(FamilyMemberEntity.fromJson)
        .toList();
  }

  /// El usuario se toma del JWT, así que `userId` solo se usa para la caché.
  Future<List<FamilyMemberEntity>> getMembers(String userId) async {
    try {
      final response = await apiClient.get(ApiConfig.familyMembers);
      final cached = {for (final m in getCachedMembers(userId)) m.id: m};
      final members = (response is List ? response : const [])
          .map((item) {
            final json = Map<String, dynamic>.from(item as Map);
            final local = cached[json['id']?.toString()];
            return FamilyMemberEntity.fromApiJson(
              json,
              isStudent: local?.isStudent ?? false,
              notes: local?.notes,
            );
          })
          .toList();
      await _saveCache(userId, members);
      return members;
    } on NetworkException {
      return getCachedMembers(userId);
    }
  }

  Future<FamilyMemberEntity> addMember(FamilyMemberEntity member) async {
    final response = await apiClient.post(
      ApiConfig.familyMembers,
      data: member.toApiJson(),
    );
    final created = FamilyMemberEntity.fromApiJson(
      Map<String, dynamic>.from(response as Map),
      isStudent: member.isStudent,
      notes: member.notes,
    );
    final list = getCachedMembers(member.parentUserId)..add(created);
    await _saveCache(member.parentUserId, list);
    return created;
  }

  Future<void> removeMember(String parentUserId, String memberId) async {
    await apiClient.delete(ApiConfig.familyMember(memberId));
    final list = getCachedMembers(parentUserId)
      ..removeWhere((m) => m.id == memberId);
    await _saveCache(parentUserId, list);
  }

  Future<void> _saveCache(String userId, List<FamilyMemberEntity> members) {
    return hiveStorage.saveFamilyMembers(
      userId,
      members.map((m) => m.toJson()).toList(),
    );
  }
}
