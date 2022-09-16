import 'package:flutter/material.dart';

Future<void> geofenceCallback(double lat, double lng) async {
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> connectedWiFiCallback(String ssid) async {
  WidgetsFlutterBinding.ensureInitialized();
}
