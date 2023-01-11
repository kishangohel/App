import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class MapFilterControllerStub extends MapFilterController {
  // A future that never finishes to simulate loading.
  FutureOr<MapFilter> _initialValue = Completer<MapFilter>().future;

  @override
  FutureOr<MapFilter> build() async {
    // A future that never finishes to simulate loading.
    return _initialValue;
  }

  void setInitialValue(FutureOr<MapFilter> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<MapFilter> newState) {
    state = newState;
  }

  @override
  Future<void> applyFilter(MapFilter filter) async {
    state = AsyncValue.data(filter);
  }
}
