import 'dart:async';

import 'package:auto_connect/auto_connect.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:verifi/access_point_callbacks_prod.dart';
import 'package:verifi/blocs/logging_bloc_delegate.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/firebase_options_prod.dart';
import 'package:verifi/widgets/app.dart';

/// The entrypoint of the application.
///
void main() async {
  await initialize();
  // Setup auto connect
  await AutoConnect.initialize(
    locationEventCallback: updateNearbyAccessPoints,
    accessPointEventCallback: notifyAccessPointConnectionResult,
  );
  // disable debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  // Run the app
  // If release mode or [_signInTestUser] is false, profile will be null and
  // user will go through standard onboarding process.
  runApp(const VeriFi());
}

/// Initialize various dependencies.
///
/// The following dependencies are initialized:
///   * [Firebase]
///   * [HydratedBloc]
///   * [BlocObserver]
///   * [SharedPrefs]
///   * [FirebaseAppCheck]
///   * [FirebaseCrashlytics]
///
Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup hydrated bloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  // Setup bloc observer
  Bloc.observer = LoggingBlocObserver();
  // Initialize shared preferences
  await sharedPrefs.init();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate();
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
}
