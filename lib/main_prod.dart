import 'dart:async';

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
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  // disable debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Run the app
  runApp(const VeriFi());
}

/// Initialize various dependencies.
///
/// The following dependencies are initialized:
///   * [Firebase]
///   * [FirebaseAppCheck]
///   * [FirebaseCrashlytics]
///
Future<void> initializeDependencies() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate();
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}
