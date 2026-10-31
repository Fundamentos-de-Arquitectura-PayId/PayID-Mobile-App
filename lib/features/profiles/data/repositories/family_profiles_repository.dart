import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/family_member_entity.dart';

class FamilyProfilesRepository {
  final HiveStorageService hiveStorage;

  FamilyProfilesRepository({required this.hiveStorage});

  List<FamilyMemberEntity> getMembers(String userId) {
    final list = hiveStorage.getFamilyMembers(userId);
    return list.map((item) => FamilyMemberEntity.fromJson(item)).toList();
  }

  Future<void> addMember(FamilyMemberEntity member) async {
    final list = hiveStorage.getFamilyMembers(member.parentUserId);
    list.add(member.toJson());
    await hiveStorage.saveFamilyMembers(member.parentUserId, list);
  }

  Future<void> removeMember(String parentUserId, String memberId) async {
    final list = hiveStorage.getFamilyMembers(parentUserId);
    list.removeWhere((item) => item['id'] == memberId);
    await hiveStorage.saveFamilyMembers(parentUserId, list);
  }
}
