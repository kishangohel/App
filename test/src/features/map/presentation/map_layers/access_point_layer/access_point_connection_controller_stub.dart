import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/domain/access_point_connection_state.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_connection_controller.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class AccessPointConnectionControllerStub
    extends AccessPointConnectionController {
  FutureOr<AccessPointConnectionState>? _initialValue;

  List<AccessPoint> accessPointsConnectedTo = [];

  @override
  FutureOr<AccessPointConnectionState> build() async {
    // A future that never finishes to simulate loading.
    return _initialValue ?? Completer<AccessPointConnectionState>().future;
  }

  void setInitialValue(FutureOr<AccessPointConnectionState> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<AccessPointConnectionState> newState) {
    state = newState;
  }

  @override
  Future<void> connect(AccessPoint accessPoint) async {
    accessPointsConnectedTo.add(accessPoint);
  }
}
