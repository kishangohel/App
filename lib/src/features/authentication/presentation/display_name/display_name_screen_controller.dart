import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part 'display_name_screen_controller.g.dart';

@riverpod
class DisplayNameScreenController extends _$DisplayNameScreenController {
  @override
  Future<String?> build() async => null;

  ProfileRepository get profileRepo => ref.read(profileRepositoryProvider);
  AuthenticationRepository get authRepo => ref.read(authRepositoryProvider);

  Future<void> submitDisplayName(String displayName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard<String?>(() async {
      final error = await profileRepo.validateDisplayName(displayName);
      if (error != null) {
        return error;
      }
      await profileRepo.createUserProfile(
        userId: authRepo.currentUser!.uid,
        displayName: displayName,
      );
      authRepo.updateDisplayName(displayName);
      return null;
    });
  }
}
