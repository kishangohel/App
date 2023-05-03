import 'package:flutter/material.dart';
import 'package:verifi/src/services/network_monitor/network_monitor_service.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Text("Menu Screen"),
          ElevatedButton(
            onPressed: () {
              NetworkMonitorService.startService();
            },
            child: const Text("Start service"),
          ),
          ElevatedButton(
            onPressed: () {
              NetworkMonitorService.stopService();
            },
            child: const Text("Stop service"),
          ),
        ],
      ),
    );
  }
}
