import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/veripoints_controller.g.dart';

@riverpod
class VeriPointsController extends _$VeriPointsController {
  ProfileRepository get profileRepository =>
      ref.read(profileRepositoryProvider);

  @override
  FutureOr<int> build() async => 0;

  Future<void> getVeriPoints() async {
    state = await AsyncValue.guard<int>(
      () => profileRepository.getVeriPoints(
        ref.read(firebaseAuthRepositoryProvider).currentUser!.uid,
      ),
    );
  }
}
