import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/achievement/application/achievement_progresses_controller.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class AchievementProgressesControllerStub
    extends AchievementProgressesController {
  FutureOr<List<AchievementProgress>?>? _initialValue;

  List<AccessPoint> accessPointsConnectedTo = [];

  @override
  FutureOr<List<AchievementProgress>?> build() async {
    // A future that never finishes to simulate loading.
    return _initialValue ?? Completer<List<AchievementProgress>?>().future;
  }

  void setInitialValue(FutureOr<List<AchievementProgress>?> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<List<AchievementProgress>?> newState) {
    state = newState;
  }
}
