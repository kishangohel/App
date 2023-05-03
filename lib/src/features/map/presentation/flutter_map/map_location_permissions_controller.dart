import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_generated/map_location_permissions_controller.g.dart';

@Riverpod(keepAlive: true)
class MapLocationPermissionsController
    extends _$MapLocationPermissionsController {
  @override
  FutureOr<LocationPermission> build() async {
    return await Geolocator.checkPermission();
  }

  Future<void> requestPermission() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => await Geolocator.requestPermission(),
    );
  }
}

extension LocationPermissionExtension on LocationPermission {
  bool get isAllowed {
    switch (this) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return true;
      default:
        return false;
    }
  }

  bool get isDenied => !isAllowed;

  bool get isDeniedPermanently => this == LocationPermission.deniedForever;
}
