import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/wifi_utils.dart';
import 'package:verifi/firebase_options.dart';
import 'package:verifi/models/wifi.dart';
import 'package:verifi/repositories/wifi_repository.dart';

class GeofencingCubit extends Cubit<int> {
  GeofencingCubit() : super(0);

  static Future<void> registerNearbyGeofences() async {
    const platform = MethodChannel("world.verifi.app/channel");
    final permissionGranted = await Permission.location.isGranted;
    if (permissionGranted == false) {
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    List<Wifi> wifis = await WifiUtils.getNearbyWifi(
      WifiRepository(),
      GeoFirePoint(position.latitude, position.longitude),
      1.0, // get everything within 1km
    );
    if (wifis.length > 1024) {
      wifis = wifis.sublist(0, 1024);
    }
    final List<List<dynamic>> geofenceData = wifis
        .map((wifi) => [
              wifi.wifiDetails!.placeId,
              wifi.wifiDetails!.location.latitude,
              wifi.wifiDetails!.location.longitude,
            ])
        .toList();
    debugPrint("Registering geofences: $geofenceData");
    platform.invokeMethod(
      "registerGeofences",
      [
        PluginUtilities.getCallbackHandle(geoFenceCallback)!.toRawHandle(),
        geofenceData,
      ],
    );
  }

  static Future<bool> geoFenceCallback(LatLng l) async {
    debugPrint("geoFenceCallback called");
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final instance = FirebaseAnalytics.instance;
    await instance.logEvent(
      name: "arrived_at",
      parameters: {
        "lat": l.latitude,
        "lng": l.longitude,
      },
    );
    debugPrint("arrived_at analytic sent");
    await registerNearbyGeofences();
    return Future.value(true);
  }
}
