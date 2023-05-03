import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/access_point_connection_controller.g.dart';

@riverpod
class AccessPointConnectionController
    extends _$AccessPointConnectionController {
  @override
  FutureOr<String?> build() async => null;

  Future<void> connectOrVerify(AccessPoint accessPoint) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final verifying = !accessPoint.isVerified;

      // Ensure that the user is logged in
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('Must be logged in');
      }

      // Run the connection/verification.
      // final result = await ref
      //     .read(autoConnectRepositoryProvider)
      //     .connectToAccessPoint(accessPoint);
      // if (result != 'Success') throw Exception(result);
      //
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
