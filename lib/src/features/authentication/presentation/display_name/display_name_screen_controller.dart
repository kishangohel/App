import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/widgets/display_name_text_field_controller.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/display_name_screen_controller.g.dart';

@riverpod
class DisplayNameScreenController extends _$DisplayNameScreenController {
  @override
  FutureOr<bool> build() => false;

  Future<void> completeSetup() async {
    final displayName = ref.read(displayNameTextFieldControllerProvider);
    if (displayName.isEmpty) return;

    final uid = ref.read(firebaseAuthRepositoryProvider).currentUser?.uid;
    if (uid == null) return;

    state = const AsyncLoading<bool>();
    state = await AsyncValue.guard<bool>(() async {
      await ref
          .read(firebaseAuthRepositoryProvider)
          .updateDisplayName(displayName);
      ref.read(profileRepositoryProvider).createUserProfile(
            userId: uid,
            displayName: displayName,
          );
      return true;
    });
  }
}
