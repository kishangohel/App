import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_connect/auto_connect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/access_point_callbacks.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/logging_bloc_delegate.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/firebase_options.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/widgets/app.dart';

/// The entrypoint of the application.
///
void main() async {
  String? _emulatorEndpoint;
  bool? _setupTestEnvironment;
  Profile? _profile;
  if (kDebugMode) {
    _emulatorEndpoint = "192.168.12.152";
    _setupTestEnvironment = false;
  }
  await initialize(emulatorEndpoint: _emulatorEndpoint);
  if ((null != _emulatorEndpoint) && (true == _setupTestEnvironment)) {
    _profile = await setupTestEnvironment(emulatorEndpoint: _emulatorEndpoint);
  }
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
  runApp(VeriFi(_profile));
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
/// If [emulatorEndpoint] is set, the app communicates with the Firebase Auth
/// and Firebase Firestore emulators. Otherwise, it communicates with the
/// Firebase backend.
///
Future<void> initialize({String? emulatorEndpoint}) async {
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
  if (kReleaseMode) {
    await FirebaseAppCheck.instance.activate();
  }
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
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
    // Get local network access before trying to interact with Firebase
    // Also need to force sign out to clear out keys stored on iOS device
    // that may be from previous emulator instance
    if (Platform.isIOS) {
      await getLocalNetworkAccess();
      await FirebaseAuth.instance.signOut();
    }
  }
}

/// Sets up application for testing.
///
/// The following steps are taken:
/// 1. Setup Firebase to use emulators (auth + firestore)
/// 2. If on iOS, get local network access.
///    - This sleeps for 10 seconds to give dev time to click pop-up before
///      continuing.
/// 3. If [signInTestUser] is true, sign in to test-user and return Profile.
///    Otherwise, return null and go through full onboarding process.
Future<Profile> setupTestEnvironment({
  required String emulatorEndpoint,
}) async {
  debugPrint("Setting up test environment");
  // If on iOS, reset auth key
  // We have to do this b/c iOS keychain saves auth token, which causes errors
  // if you restart the emulator and a new auth token gets created.
  // Sign in to Firebase via test phone number
  final verificationCodesEndpoint =
      "http://$emulatorEndpoint:9099/emulator/v1/projects/bionic-water-366401/verificationCodes";
  final authCompleter = Completer<String>();
  final fbAuth = FirebaseAuth.instance;
  debugPrint("Verifying phone number");
  fbAuth.verifyPhoneNumber(
    phoneNumber: "+1 6505553434",
    verificationCompleted: (PhoneAuthCredential credential) async {
      final userCred = await fbAuth.signInWithCredential(credential);
      authCompleter.complete(userCred.user?.uid);
    },
    verificationFailed: (FirebaseAuthException e) {
      debugPrint("Verification failed: ${e.message?.toString()}");
    },
    codeSent: (String verificationId, int? resendToken) async {
      final resp = await http.get(Uri.parse(verificationCodesEndpoint));
      final result = jsonDecode(resp.body);
      final code = result["verificationCodes"].last["code"]!;
      final creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      final userCred = await fbAuth.signInWithCredential(creds);
      authCompleter.complete(userCred.user?.uid);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      debugPrint("Auto retrieval timed out");
    },
  );
  final uid = await authCompleter.future;
  debugPrint("Phone number verified");
  // Generate test Profile with auth token as id
  const ethAddress = "0x0123456789abcdef0123456789abcdef01234567";
  const displayName = "testuser";
  final avatar = randomAvatarString(displayName, trBackground: true);
  final profile = Profile(
    id: uid,
    ethAddress: ethAddress,
    displayName: displayName,
    pfp: Pfp(
      id: displayName,
      name: displayName,
      image: SvgProvider(avatar, source: SvgSource.raw),
      imageBitmap: await ImageUtils.rawVectorToBytes(avatar, 70.0),
    ),
  );
  // Return profile to pass to VeriFi app during Bloc setup
  return profile;
}

Future<void> getLocalNetworkAccess() async {
  try {
    var deviceIp = await NetworkInfo().getWifiIP();
    Duration? timeOutDuration = const Duration(milliseconds: 500);
    await Socket.connect(deviceIp, 80, timeout: timeOutDuration);
  } catch (e) {
    // Give dev time to accept local network pop-up before continuing
    sleep(const Duration(seconds: 10));
  }
  return;
}
