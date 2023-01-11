import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/add_network/application/add_access_point_controller.dart';
import 'package:verifi/src/features/add_network/domain/new_access_point_model.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class AddAccessPointControllerStub extends AddAccessPointController {
  // A future that never finishes to simulate loading.
  FutureOr<NewAccessPoint?>? _initialValue =
      Completer<NewAccessPoint?>().future;

  List<NewAccessPoint> addedAccessPoints = [];

  @override
  FutureOr<NewAccessPoint?> build() async {
    return _initialValue;
  }

  void setInitialValue(FutureOr<NewAccessPoint?> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<NewAccessPoint?> newState) {
    state = newState;
  }

  @override
  Future<void> addAccessPoint(NewAccessPoint newAccessPoint) async {
    addedAccessPoints.add(newAccessPoint);
  }
}
