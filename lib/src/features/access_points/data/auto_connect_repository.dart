import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_generated/auto_connect_repository.g.dart';

/// A repository which wraps teh AutoConnect plugin to allow us to mock it in
/// tests. All calls to AutoConnect should pass through this repository, with
/// the exception of initialize which is called outside of the riverpod
/// container. If the desired AutoConnect method is missing it should be added.
class AutoConnectRepository {
  final AutoConnectRepositoryRef ref;

  AutoConnectRepository(this.ref);

  // Future<String> connectToAccessPoint(AccessPoint accessPoint) {
  //   return AutoConnect.connectToAccessPoint(
  //     wifi: WiFi(
  //       ssid: accessPoint.ssid,
  //       password: accessPoint.password ?? "",
  //     ),
  //   );
  // }
  //
  // void removeAllGeofences() {
  //   AutoConnect.removeAllGeofences();
  // }
}

@riverpod
AutoConnectRepository autoConnectRepository(AutoConnectRepositoryRef ref) {
  return AutoConnectRepository(ref);
}
