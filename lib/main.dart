import 'dart:async';
import 'dart:convert';

import 'package:auto_connect/auto_connect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:verifi/blocs/logging_bloc_delegate.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/firebase_options.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/widgets/app.dart';

/// The entrypoint of application.
///
/// The following are initialized before [runApp] is called:
///
/// * [AutoConnect]
/// * [BlocObserver]
/// * [FirebaseCrashlytics]
/// * [Firebase]
/// * [FirebaseAppCheck]
/// * [HydratedBloc]
/// * [HydratedStorage]
/// * [SharedPrefs]
/// * Firebase emulators, if in debug mode
/// * [GoogleMapsFlutterAndroid] if on Android

const String emulatorEndpoint = "192.168.12.152";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup hydrated bloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  // Setup bloc observer
  Bloc.observer = LoggingBlocObserver();
  // disable debug print in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  // Initialize shared preferences
  await sharedPrefs.init();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Use Firebase App Check
  await FirebaseAppCheck.instance.activate();
  // Use auth emulator in debug mode
  if (kDebugMode) {
    FirebaseAuth.instance.useAuthEmulator(
      emulatorEndpoint,
      9099,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorEndpoint,
      8080,
    );
  }
  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Use hybrid composition if on Android
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  // Setup auto connect
  AutoConnect.initialize();

  Profile? profile;
  if (kDebugMode) {
    profile = await authenticateTestUser();
  }
  // Run the app
  runApp(VeriFi(profile));
}

Future<Profile> authenticateTestUser() async {
  const verificationCodesEndpoint =
      "http://$emulatorEndpoint:9099/emulator/v1/projects/verifi-5db5b/verificationCodes";
  final authCompleter = Completer<String>();
  final fbAuth = FirebaseAuth.instance;
  await fbAuth.verifyPhoneNumber(
    phoneNumber: "+1 650-555-3434",
    verificationCompleted: (PhoneAuthCredential credential) async {
      final userCred = await fbAuth.signInWithCredential(credential);
      authCompleter.complete(userCred.user!.uid);
    },
    verificationFailed: (FirebaseAuthException e) {},
    codeSent: (String verificationId, int? resendToken) async {
      final resp = await http.get(Uri.parse(verificationCodesEndpoint));
      final result = jsonDecode(resp.body);
      final code = result["verificationCodes"].last["code"]!;
      final creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      final userCred = await fbAuth.signInWithCredential(creds);
      authCompleter.complete(userCred.user!.uid);
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
  final uid = await authCompleter.future;
  return Profile(
    id: uid,
    ethAddress: "0x0123456789abcdef0123456789abcdef01234567",
    displayName: "test-user",
    pfp: "assets/profile_avatars/People-01.png",
  );
}
