import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_location_permissions_controller.g.dart';

@Riverpod(keepAlive: true)
class MapLocationPermissionsController
    extends _$MapLocationPermissionsController {
  @override
  FutureOr<LocationPermission> build() async {
    final permission = await Geolocator.checkPermission();
    return permission;
  }

  Future<void> requestPermission() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await Geolocator.requestPermission(),
    );
  }
}
