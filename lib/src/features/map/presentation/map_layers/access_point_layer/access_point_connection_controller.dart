import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  Future<void> connect() async {
    if (!state.hasValue) return;
    final value = state.value!;

    if (value.connecting) return;

    state = AsyncData(value.copyWith(connecting: true));

    state = await AsyncValue.guard(() async {
      // TODO: Uncomment when plugin is published and add result to state.
      // final result = await AutoConnect.verifyAccessPoint(
      //   wifi: WiFi(
      //     ssid: value.accessPoint.ssid,
      //     password: value.accessPoint.password ?? "",
      //   ),
      // );
      await Future.delayed(const Duration(seconds: 2));
      const result = 'A FAKE CONNECTION RESULT';
      return value.copyWith(connecting: false, connectionResult: result);
    });
  }
}
