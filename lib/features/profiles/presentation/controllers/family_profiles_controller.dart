import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import 'package:payid_mobile/features/authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/family_profiles_repository.dart';
import '../../domain/entities/family_member_entity.dart';

final familyProfilesRepositoryProvider = Provider<FamilyProfilesRepository>((ref) {
  return FamilyProfilesRepository(
    apiClient: ref.watch(apiClientProvider),
    hiveStorage: ref.watch(hiveStorageProvider),
  );
});

class FamilyProfilesState {
  final bool isLoading;
  final List<FamilyMemberEntity> members;
  final String? errorMessage;

  const FamilyProfilesState({
    this.isLoading = false,
    this.members = const [],
    this.errorMessage,
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

  Future<void> loadMembers() async {
    if (userId == null) return;
    // Muestra la caché de inmediato mientras llega la respuesta del servidor
    state = FamilyProfilesState(
      isLoading: true,
      members: repository.getCachedMembers(userId!),
    );
    try {
      final list = await repository.getMembers(userId!);
      if (mounted) state = FamilyProfilesState(members: list);
    } catch (e) {
      if (mounted) {
        state = FamilyProfilesState(
          members: state.members,
          errorMessage: _message(e),
        );
      }
    }
  }

  /// Lanza la excepción para que la pantalla muestre el error.
  Future<FamilyMemberEntity> addMember(FamilyMemberEntity member) async {
    final created = await repository.addMember(member);
    if (mounted) {
      state = FamilyProfilesState(members: [...state.members, created]);
    }
    return created;
  }

  Future<void> removeMember(String memberId) async {
    if (userId == null) return;
    try {
      await repository.removeMember(userId!, memberId);
      if (mounted) {
        state = FamilyProfilesState(
          members: state.members.where((m) => m.id != memberId).toList(),
        );
      }
    } catch (e) {
      if (mounted) {
        state = FamilyProfilesState(members: state.members, errorMessage: _message(e));
      }
    }
  }

  String _message(Object e) {
    try {
      return (e as dynamic).message as String;
    } catch (_) {
      return 'No se pudo sincronizar los perfiles familiares.';
    }
  }
}
