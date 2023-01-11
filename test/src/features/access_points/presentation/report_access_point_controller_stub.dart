import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/application/report_access_point_controller.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class ReportAccessPointControllerStub extends ReportAccessPointController {
  // A future that never finishes to simulate loading.
  FutureOr<AccessPointReport?>? _initialValue =
      Completer<AccessPointReport?>().future;

  dynamic errorStub;

  List<AccessPointReport> accessPointReports = [];

  @override
  Future<void> reportAccessPoint(AccessPointReport accessPointReport) async {
    accessPointReports.add(accessPointReport);
  }

  @override
  FutureOr<AccessPointReport?> build() async {
    if (errorStub != null) throw errorStub;
    return _initialValue;
  }

  void setInitialValue(FutureOr<AccessPointReport?> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<AccessPointReport?> newState) {
    state = newState;
  }
}
