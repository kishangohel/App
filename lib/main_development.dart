import 'dart:async';
import 'dart:convert';

import 'package:appspector/appspector.dart';
import 'package:auto_connect/auto_connect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:verifi/src/app.dart';
import 'package:verifi/src/configs/firebase_options_dev.dart';

/// The entrypoint of the application.
void main() async {
  String? localIp = const bool.hasEnvironment('VERIFI_DEV_LOCAL_IP')
      ? const String.fromEnvironment('VERIFI_DEV_LOCAL_IP')
      : null;
  await initialize(emulatorEndpoint: localIp);
  // disable debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Log in as test user.
  if (localIp != null) {
    await _logInAsTestUser(emulatorEndpoint: localIp);
  }

  // Initialize AutoConnect
  await AutoConnect.initialize(
    locationEventCallback: (lat, lon) {
      debugPrint(
        'AutoConnect locationEventCallback triggered: {lat: $lat, lon: $lon}',
      );
    },
    accessPointEventCallback: (accessPointId, ssid, connectionResult) {
      debugPrint(
        'AutoConnect accessPointEventCallback triggered: {accessPointId: $accessPointId, ssid: $ssid, connectionResult: $connectionResult}',
      );
    },
  );

  // Run the app
  runApp(
    ProviderScope(
      child: VeriFi(),
    ),
  );
}

/// Initialize various dependencies.
///
/// The following dependencies are initialized:
///   * [Firebase]
///   * [FirebaseAppCheck]
///   * [FirebaseCrashlytics]
///
/// If [emulatorEndpoint] is set, the app communicates with the Firebase Auth
/// and Firebase Firestore emulators. Otherwise, it communicates with the
/// remote Firebase backend.
Future<void> initialize({String? emulatorEndpoint}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate();
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Setup AppSpector
  initializeAppSpector();
  // Use emulator if [emulatorEndpoint] is set
  if (emulatorEndpoint != null) {
    FirebaseAuth.instance.useAuthEmulator(
      emulatorEndpoint,
      9099,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorEndpoint,
      8080,
    );
  }
}

void initializeAppSpector() {
  final config = Config()
    ..iosApiKey = "ios_MTk1NDViNmQtNzYzMy00MDlhLWE5NDQtNjBkMGUxMGFhZGYx"
    ..androidApiKey =
        "android_ZjUwMWU1ZmMtNmI4Mi00MDc5LTllNWEtNTA2NDRhYjJkY2Vl";
  AppSpectorPlugin.run(config);
}

/// Sign in to test_user.
Future<void> _logInAsTestUser({
  required String emulatorEndpoint,
}) async {
  debugPrint("Loggin in test_user");

  // Sign in to Firebase via test phone number
  final verificationCodesEndpoint =
      "http://$emulatorEndpoint:9099/emulator/v1/projects/verifi-dev/verificationCodes";
  final firebaseAuth = FirebaseAuth.instance;

  debugPrint("Verifying test_user phone number");
  await firebaseAuth.verifyPhoneNumber(
    phoneNumber: "+1 6505553434",
    verificationCompleted: (PhoneAuthCredential credential) async {
      await firebaseAuth.signInWithCredential(credential);
    },
    verificationFailed: (FirebaseAuthException exception) {
      throw exception;
    },
    codeSent: (String verificationId, int? resendToken) async {
      final resp = await http.get(Uri.parse(verificationCodesEndpoint));
      final code = jsonDecode(resp.body)["verificationCodes"].last["code"]!;
      final credentials = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      await firebaseAuth.signInWithCredential(credentials);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      debugPrint("Test_user SMS verification auto-retrieval timed out");
    },
  );

  debugPrint("Test_user logged in");
}
