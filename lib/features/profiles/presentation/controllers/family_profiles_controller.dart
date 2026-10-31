import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/family_profiles_repository.dart';
import '../../domain/entities/family_member_entity.dart';

final familyProfilesRepositoryProvider = Provider<FamilyProfilesRepository>((ref) {
  final hive = ref.watch(hiveStorageProvider);
  return FamilyProfilesRepository(hiveStorage: hive);
});

class FamilyProfilesState {
  final bool isLoading;
  final List<FamilyMemberEntity> members;

  const FamilyProfilesState({
    this.isLoading = false,
    this.members = const [],
  });
}

final familyProfilesControllerProvider =
    StateNotifierProvider<FamilyProfilesController, FamilyProfilesState>((ref) {
  final repository = ref.watch(familyProfilesRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final controller = FamilyProfilesController(repository: repository, userId: user?.id);
  if (user != null) {
    controller.loadMembers();
  }
  return controller;
});

class FamilyProfilesController extends StateNotifier<FamilyProfilesState> {
  final FamilyProfilesRepository repository;
  final String? userId;

  FamilyProfilesController({required this.repository, this.userId})
      : super(const FamilyProfilesState());

  void loadMembers() {
    if (userId == null) return;
    final list = repository.getMembers(userId!);
    state = FamilyProfilesState(isLoading: false, members: list);
  }

  Future<void> addMember(FamilyMemberEntity member) async {
    await repository.addMember(member);
    loadMembers();
  }

  Future<void> removeMember(String memberId) async {
    if (userId == null) return;
    await repository.removeMember(userId!, memberId);
    loadMembers();
  }
}
