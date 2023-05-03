import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:verifi/src/app.dart';
import 'package:verifi/src/configs/firebase_options_dev.dart';
import 'package:verifi/src/notifications/fcm.dart';
import 'package:verifi/src/services/network_monitor/network_monitor_service.dart';

/// The entrypoint of the application.
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Process environment variables
  String? localIp = const bool.hasEnvironment('VERIFI_DEV_LOCAL_IP')
      ? const String.fromEnvironment('VERIFI_DEV_LOCAL_IP')
      : null;
  bool? testUserLogin = const bool.hasEnvironment('VERIFI_DEV_TEST_USER_LOGIN')
      ? const bool.fromEnvironment('VERIFI_DEV_TEST_USER_LOGIN')
      : true;
  // Initialize dependencies
  await initializeDependencies(emulatorEndpoint: localIp);
  // disable debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  // Make sure stack traces are demangled in debug mode
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };
  // If relevant environment variables are set, log in as test user.
  if (localIp != null && testUserLogin == true) {
    debugPrint("Logging in as test_user");
    await _skipOnboarding();
    await _logInAsTestUser(emulatorEndpoint: localIp);
  }
  // Sign out if test user login set to false (iOS tries to auto-login)
  else if (localIp != null && testUserLogin == false) {
    await FirebaseAuth.instance.signOut();
  }
  // Run the app
  runApp(
    const ProviderScope(
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
///   * [FirebaseMessaging]
///   * [FlutterLocalNotificationsPlugin]
///
/// If [emulatorEndpoint] is set, the app communicates with the Firebase Auth
/// and Firebase Firestore emulators. Otherwise, it communicates with the
/// remote Firebase backend.
///
Future<void> initializeDependencies({String? emulatorEndpoint}) async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate();
  // Pass all uncaught errors from the framework to Firebase Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Use Firebase local emulator if `emulatorEndpoint` is set
  if (emulatorEndpoint != null) {
    await FirebaseAuth.instance.useAuthEmulator(
      emulatorEndpoint,
      9099,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorEndpoint,
      8080,
    );
    FirebaseFunctions.instance.useFunctionsEmulator(
      emulatorEndpoint,
      5001,
    );
  }
  // Initialize Firebase Cloud Messaging
  await FCM.init();
  // Start network monitoring service if required permissions granted
  if (await Permission.location.isGranted &&
      await Permission.notification.isGranted) {
    await NetworkMonitorService.startService();
  }
}

/// Sign in to test_user.
///
Future<void> _logInAsTestUser({
  required String emulatorEndpoint,
}) async {
  // Sign in to Firebase via test phone number
  final verificationCodesEndpoint =
      "http://$emulatorEndpoint:9099/emulator/v1/projects/verifi-dev/verificationCodes";
  final firebaseAuth = FirebaseAuth.instance;

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
}

Future<void> _skipOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("onboarded", true);
}
