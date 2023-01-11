import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'connectivity_repository.g.dart';

class ConnectivityRepository {
  final networkInfo = NetworkInfo();

  Future<String?> getWifiName() async => await networkInfo.getWifiName();

  Stream<ConnectivityResult> onConnectivityChanged =
      Connectivity().onConnectivityChanged;

  Future<ConnectivityResult> get connectivityResult async =>
      await Connectivity().checkConnectivity();
}

@Riverpod(keepAlive: true)
ConnectivityRepository connectivityRepository(ConnectivityRepositoryRef ref) {
  return ConnectivityRepository();
}

final connectivityChangesProvider = StreamProvider<ConnectivityResult>(
  (ref) => ref.watch(connectivityRepositoryProvider).onConnectivityChanged,
);

final connectivityStatusProvider = FutureProvider<ConnectivityResult>(
  (ref) => ref.watch(connectivityRepositoryProvider).connectivityResult,
);
