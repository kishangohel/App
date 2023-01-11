import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isConnectedToWiFiProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (result) => result == ConnectivityResult.wifi,
      );
});
