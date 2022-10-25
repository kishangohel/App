import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_connect/auto_connect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
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
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/logging_bloc_delegate.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/firebase_options.dart';
import 'package:verifi/models/models.dart';
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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup hydrated bloc storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  // Setup bloc observer
  Bloc.observer = LoggingBlocObserver();
  // disable debugPrint in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  // Initialize shared preferences
  await sharedPrefs.init();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Activate Firebase App Check
  // await FirebaseAppCheck.instance.activate();
  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // If Android, use hybrid composition for Google Maps
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  // Setup auto connect
  await AutoConnect.initialize();
  // Setup Coinbase
  await initCoinbaseSDK();

  // If debug mode, setup test environment
  Profile? profile;
  if (kDebugMode) {
    profile = await setupTestEnvironment(signInTestUser: true);
    debugPrint("Profile: ${profile.toString()}");
  }
  // Run the app
  // If release mode or [signInTestUser] is false, profile will be null.
  runApp(VeriFi(profile));
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
Future<Profile?> setupTestEnvironment({bool signInTestUser = true}) async {
  debugPrint("Setting up test environment");
  // CHANGE ME TO YOUR EMULATOR ENDPOINT
  const String emulatorEndpoint = "192.168.12.152";
  // Setup Firebase emulators
  FirebaseAuth.instance.useAuthEmulator(
    emulatorEndpoint,
    9099,
  );
  FirebaseFirestore.instance.useFirestoreEmulator(
    emulatorEndpoint,
    8080,
  );
  // If on iOS, get local network access and reset auth key
  // We have to do this b/c iOS keychain saves auth token, which causes errors
  // if you restart the emulator and a new auth token gets created.
  if (Platform.isIOS) {
    // await getLocalNetworkAccess();
    await FirebaseAuth.instance.signOut();
  }
  if (signInTestUser) {
    // Sign in to Firebase via test phone number
    const verificationCodesEndpoint =
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
        imageBitmap: await ImageUtils.rawVectorToBytes(avatar, 100.0),
      ),
    );
    // Return profile to pass to VeriFi app during Bloc setup
    return profile;
  } else {
    return null;
  }
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

/// Initialize Coinbase SDK. This can only be called once.
Future<void> initCoinbaseSDK() async {
  //TODO: Move this to wallet connect bloc and ensure only initialized once
  // i.e. save bool for isInitialized or something so this  doesn't break the
  // whole app on hot restarts
  await CoinbaseWalletSDK.shared.configure(
    Configuration(
      ios: IOSConfiguration(
        host: Uri.parse('https://wallet.coinbase.com/wsegue'),
        // 'verifi://' is the required scheme to get Coinbase Wallet to
        // switch back to our app after successfully connecting or signing
        callback: Uri.parse('verifi://'),
      ),
      android: AndroidConfiguration(
        domain: Uri.parse("https://verifi.world"),
      ),
    ),
  );
}
