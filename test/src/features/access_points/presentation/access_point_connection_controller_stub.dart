import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/application/access_point_connection_controller.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class AccessPointConnectionControllerStub
    extends AccessPointConnectionController {
  FutureOr<String?>? _initialValue;

  List<AccessPoint> accessPointsConnectedTo = [];

  @override
  FutureOr<String?> build() async {
    // A future that never finishes to simulate loading.
    return _initialValue ?? Completer<String?>().future;
  }

  void setInitialValue(FutureOr<String?> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<String?> newState) {
    state = newState;
  }

  @override
  Future<void> connectOrVerify(AccessPoint accessPoint) async {
    accessPointsConnectedTo.add(accessPoint);
  }
}
