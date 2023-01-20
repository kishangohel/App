import 'dart:async';

import 'package:auto_connect/auto_connect.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:verifi/src/app.dart';
import 'package:verifi/src/configs/firebase_options_prod.dart';

/// The entrypoint of the application.
///
void main() async {
  await initialize();
  // disable debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialize AutoConnect
  await AutoConnect.initialize(
    locationEventCallback: (lat, lon) {},
    accessPointEventCallback: (accessPointId, ssid, connectionResult) {},
  );

  // Run the app
  // If release mode or [_signInTestUser] is false, profile will be null and
  // user will go through standard onboarding process.
  runApp(VeriFi());
}

/// Initialize various dependencies.
///
/// The following dependencies are initialized:
///   * [Firebase]
///   * [FirebaseAppCheck]
///   * [FirebaseCrashlytics]
Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate();
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}
