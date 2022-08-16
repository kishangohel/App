import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/logging_bloc_delegate.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/firebase_options.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/widgets/app.dart';

/// The entrypoint of application.
///
/// [Firebase], [HydratedBloc], [HydratedStorage], [BlocObserver], and
/// [Crashlytics] are all initialized here.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  Bloc.observer = LoggingBlocObserver();
  // disable printing in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  await sharedPrefs.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  // Use auth emulator in debug mode
  // if (kDebugMode) {
  //   FirebaseAuth.instance.setSettings(
  //     appVerificationDisabledForTesting: true,
  //   );
  //   FirebaseAuth.instance.useAuthEmulator(
  //     '/192.168.12.216',
  //     9099,
  //   );
  //   FirebaseFirestore.instance.useFirestoreEmulator(
  //     '192.168.12.216',
  //     8080,
  //   );
  // }

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(VeriFi());
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
    final double lat = call.arguments["world.verifi.app.GF_LAT"];
    final double lng = call.arguments["world.verifi.app.GF_LNG"];
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
    debugPrint("Adding WiFi suggestions");
    backgroundChannel.invokeMethod("add_suggestions", wifis);
    callback(LatLng(lat, lng));
    return true;
  });
  backgroundChannel.invokeMethod("initialized");
}
