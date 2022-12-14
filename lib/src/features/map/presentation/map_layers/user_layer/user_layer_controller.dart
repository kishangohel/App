import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/map/application/map_service.dart';

import 'user_marker.dart';

part 'user_layer_controller.g.dart';

@Riverpod(keepAlive: true)
class UserLayerController extends _$UserLayerController {
  @override
  FutureOr<List<UserMarker>> build() async => [];

  MapService get mapService => ref.read(mapServiceProvider);

  Future<void> updateUsers() async {
    state = await AsyncValue.guard<List<UserMarker>>(() async {
      final users = await mapService.getNearbyUsers();
      return users
          .where((user) => user.lastLocation != null)
          .map((user) => UserMarker(point: user.lastLocation!, profile: user))
          .toList();
    });
  }
}
