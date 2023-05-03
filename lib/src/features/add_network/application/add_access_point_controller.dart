import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/add_network/domain/new_access_point_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/add_access_point_controller.g.dart';

@riverpod
class AddAccessPointController extends _$AddAccessPointController {
  @override
  FutureOr<NewAccessPoint?> build() async {
    return null;
  }

  Future<void> addAccessPoint(NewAccessPoint newAccessPoint) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) {
        throw Exception('User is not logged in');
      }
      await ref.read(accessPointRepositoryProvider).addAccessPoint(
            userId: user.id,
            newAccessPoint: newAccessPoint,
          );
      return newAccessPoint;
    });
  }
}
