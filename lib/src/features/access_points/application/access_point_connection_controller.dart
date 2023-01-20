import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/data/auto_connect_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part 'access_point_connection_controller.g.dart';

@riverpod
class AccessPointConnectionController
    extends _$AccessPointConnectionController {
  @override
  FutureOr<String?> build() async => null;

  Future<void> connectOrVerify(AccessPoint accessPoint) async {
    if (state.isLoading) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final verifying = !accessPoint.isVerified;

      // Ensure that the user is logged in
      final currentUser = ref.read(currentUserProvider).valueOrNull;
      if (currentUser == null) throw 'Must be logged in';

      // Run the connection/verification.
      final result = await ref
          .read(autoConnectRepositoryProvider)
          .verifyAccessPoint(accessPoint);
      if (result != 'Success') throw result;

      // Update the AccessPoint to note that it has been validated.
      if (verifying) {
        await ref
            .read(accessPointRepositoryProvider)
            .networkValidatedByUser(accessPoint, currentUser);
      }

      // Update state.
      return verifying ? 'Validation successful!' : 'Connection successful!';
    });
  }
}
