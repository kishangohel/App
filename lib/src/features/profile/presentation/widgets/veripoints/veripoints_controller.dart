import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part 'veripoints_controller.g.dart';

@riverpod
class VeriPointsController extends _$VeriPointsController {
  AuthenticationRepository get authRepository =>
      ref.read(authRepositoryProvider);
  ProfileRepository get profileRepository =>
      ref.read(profileRepositoryProvider);

  @override
  FutureOr<int> build() async => 0;

  Future<void> getVeriPoints() async {
    state = await AsyncValue.guard<int>(
      () => profileRepository.getVeriPoints(
        authRepository.currentUser!.uid,
      ),
    );
  }
}
