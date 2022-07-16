import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/logging_bloc_delegate.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/widgets/app.dart';

import 'firebase_options.dart';

/// The entrypoint of application.
///
/// [Firebase], [HydratedBloc], [HydratedStorage], [BlocObserver], and
/// [Crashlytics] are all initialized here.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // disable printing in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  await sharedPrefs.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Use auth emulator in debug mode
  if (kDebugMode) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  final storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

  HydratedBlocOverrides.runZoned(
    () => runApp(VeriFi()),
    blocObserver: LoggingBlocDelegate(),
    storage: storage,
  );
}

// Root-level callback dispatcher for VeriFi background channel.
//
// This function must sit at the same level as [main] in order to be
// called by the background [Isolate] process. Once the background channel
// is initialized, native background services can talk to our Flutter code, and
// vice-versa.
void callbackDispatcher() async {
  debugPrint("callback dispatcher called from Flutter");
  const backgroundChannel =
      MethodChannel("world.verifi.app/background_channel");
  WidgetsFlutterBinding.ensureInitialized();
  backgroundChannel.setMethodCallHandler((call) async {
    debugPrint("Received coordinates from platform background channel");
    final int handle = call.arguments["world.verifi.app.CALLBACK_HANDLE"];
    List fenceIds = call.arguments["world.verifi.app.FENCE_IDS"];
    fenceIds = fenceIds.cast<String>();
    final double lat = call.arguments["world.verifi.app.LAT"];
    final double lng = call.arguments["world.verifi.app.LNG"];
    final Function? callback = PluginUtilities.getCallbackFromHandle(
      CallbackHandle.fromRawHandle(handle),
    );
    assert(callback != null);
    if (callback == null) {
      return false;
    }
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    final nearbyWifi = await WifiUtils.getNearbyWifi(
      WifiRepository(),
      GeoFirePoint(lat, lng),
      0.1, // 100 meters
    );
    final wifis = nearbyWifi
        .map((wifi) =>
            [wifi.wifiDetails?.ssid ?? "", wifi.wifiDetails?.password])
        .toList();
    backgroundChannel.invokeMethod("add_suggestions", wifis);
    callback(fenceIds as List<String?>, LatLng(lat, lng));
    return true;
  });
  backgroundChannel.invokeMethod("initialized");
}

class Notification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future showNotificationWithoutSound(LatLng location) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      '1',
      'location-bg',
      channelDescription: 'fetch location in background',
      playSound: false,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
      presentSound: false,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Location fetched',
      location.toString(),
      platformChannelSpecifics,
      payload: '',
    );
  }

  Notification() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
