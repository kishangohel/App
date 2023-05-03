import 'package:flutter/services.dart';

class NetworkMonitorService {
  static const platform = MethodChannel('world.verifi.app');
  static const startNetworkMonitorMethod = 'startNetworkMonitor';
  static const stopNetworkMonitorMethod = 'stopNetworkMonitor';

  static Future<void> startService() async {
    await platform.invokeMethod(startNetworkMonitorMethod);
  }

  static Future<void> stopService() async {
    await platform.invokeMethod(stopNetworkMonitorMethod);
  }
}
