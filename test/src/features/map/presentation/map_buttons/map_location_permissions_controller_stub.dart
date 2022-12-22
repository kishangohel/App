import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/map_location_permissions_controller.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class MapLocationPermissionsControllerStub
    extends MapLocationPermissionsController {
  FutureOr<LocationPermission>? _initialValue;

  @override
  FutureOr<LocationPermission> build() async {
    // A future that never finishes to simulate loading.
    return _initialValue ?? Completer<LocationPermission>().future;
  }

  void setInitialValue(FutureOr<LocationPermission> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<LocationPermission> newState) {
    state = newState;
  }
}
