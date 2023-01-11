import 'package:auto_connect/auto_connect.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/domain/access_point_connection_state.dart';

part 'access_point_connection_controller.g.dart';

@riverpod
class AccessPointConnectionController
    extends _$AccessPointConnectionController {
  @override
  FutureOr<AccessPointConnectionState> build() async =>
      const AccessPointConnectionState();

  MapService get mapService => ref.read(mapServiceProvider);

  Future<void> connect(AccessPoint accessPoint) async {
    if (!state.hasValue) return;
    final value = state.value!;

    if (value.connecting) return;

    state = AsyncData(value.copyWith(connecting: true));

    state = await AsyncValue.guard(() async {
      final result = await AutoConnect.verifyAccessPoint(
        wifi: WiFi(
          ssid: accessPoint.ssid,
          password: accessPoint.password ?? "",
        ),
      );
      return value.copyWith(connecting: false, connectionResult: result);
    });
  }
}
