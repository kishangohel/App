import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/create_profile/create_profile_cubit.dart';
import 'package:verifi/blocs/intro_pages/intro_pages_cubit.dart';
import 'package:verifi/main.dart' as main;
import 'package:verifi/models/wifi.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/screens/onboarding/connect_wallet_screen.dart';
import 'package:verifi/screens/onboarding/permissions_screen.dart';
import 'package:verifi/screens/onboarding/phone_number_screen.dart';
import 'package:verifi/screens/onboarding/profile_picture_select_screen.dart';
import 'package:verifi/screens/onboarding/sign_wallet_screen.dart';
import 'package:verifi/screens/onboarding/sms_code_screen.dart';
import 'package:verifi/screens/onboarding/intro_screen.dart';
import 'package:verifi/widgets/home_page.dart';

// The top-level [Widget] for the VeriFi application.
//
// This should only be built by calling [runApp] in [main].
//
// The widget is a [StatefulWidget] in order to setup communication with
// [Isolate]s via [SendPort] and [ReceivePort].
//
// Once the [IsolateNameServer] is setup and listening for callbacks,
// [platform.invokeMethod] is called with the "initialize" method to initialize
// the platform-specific code.
//
// This widget provides all of the [Bloc]s and [Repository]s to their children.
class VeriFi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VeriFiState();
}

class _VeriFiState extends State<VeriFi> {
  static const platform = MethodChannel("world.verifi.app/channel");
  String userUid = "";
  FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  // Initializes platform-specific code and starts activity recognition service.
  //
  // Asks for [Permission.locationAlways]
  void initPlatformState() async {
    final int? dispatcherHandle =
        PluginUtilities.getCallbackHandle(main.callbackDispatcher)
            ?.toRawHandle();
    await platform.invokeMethod("initialize", <dynamic>[dispatcherHandle]);
    await getLocationAlwaysPermission();
    registerNearbyGeofences();
  }

  static Future<bool> callback(List<String?> ids, LatLng l) async {
    // main.Notification().showNotificationWithoutSound(l);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    // Only allow app to be used in portrait mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>(
          create: (context) => AuthenticationRepository(),
        ),
        RepositoryProvider<UsersRepository>(
          create: (context) => UsersRepository(),
        ),
        RepositoryProvider<PlacesRepository>(
          create: (context) => PlacesRepository(),
        ),
        RepositoryProvider<WifiRepository>(
          create: (context) => WifiRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AddNetworkCubit>(
            create: (context) => AddNetworkCubit(
              RepositoryProvider.of<WifiRepository>(context),
            ),
          ),
          BlocProvider<AuthenticationCubit>(
            create: (context) => AuthenticationCubit(
              RepositoryProvider.of<AuthenticationRepository>(context),
            )..logout(),
          ),
          BlocProvider<CreateProfileCubit>(
            create: (context) => CreateProfileCubit(
              RepositoryProvider.of<UsersRepository>(context),
              RepositoryProvider.of<AuthenticationRepository>(context),
            ),
          ),
          BlocProvider<FeedFilterBloc>(
            create: (context) => FeedFilterBloc(),
          ),
          BlocProvider<IntroPagesCubit>(
            create: (context) => IntroPagesCubit(),
          ),
          BlocProvider<LocationCubit>(
            create: (context) => LocationCubit(),
          ),
          BlocProvider<MapCubit>(
            create: (context) => MapCubit(
              RepositoryProvider.of<WifiRepository>(context),
              RepositoryProvider.of<PlacesRepository>(context),
            ),
          ),
          BlocProvider<MapSearchCubit>(
            create: (context) => MapSearchCubit(
              RepositoryProvider.of<PlacesRepository>(context),
              RepositoryProvider.of<WifiRepository>(context),
            ),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) => ProfileCubit(
              RepositoryProvider.of<UsersRepository>(context),
            ),
          ),
          BlocProvider<TabBloc>(
            create: (context) => TabBloc(),
          ),
          BlocProvider<WalletConnectCubit>(
            create: (context) => WalletConnectCubit(),
          ),
          BlocProvider<WifiFeedCubit>(
            create: (context) => WifiFeedCubit(
              RepositoryProvider.of<WifiRepository>(context),
              RepositoryProvider.of<PlacesRepository>(context),
            ),
          ),
        ],
        child: VeriFiApp(),
      ),
    );
  }

  Future<void> getLocationAlwaysPermission() async {
    final granted = await Permission.locationAlways.isGranted;
    if (granted) return;
    await Permission.locationWhenInUse.request();
    Permission.locationAlways.request();
  }

  Future<void> registerNearbyGeofences() async {
    Position position = await Geolocator.getCurrentPosition();
    List<Wifi> wifis = await WifiUtils.getNearbyWifi(
      WifiRepository(),
      GeoFirePoint(position.latitude, position.longitude),
      1.0, // get everything within 1km
    );
    if (wifis.length > 1024) {
      wifis = wifis.sublist(0, 1024);
    }
    final List<List<dynamic>> geofenceData = wifis
        .map((wifi) => [
              wifi.wifiDetails!.placeId,
              wifi.wifiDetails!.location.latitude,
              wifi.wifiDetails!.location.longitude,
            ])
        .toList();

    platform.invokeMethod(
      "registerGeofence",
      [
        PluginUtilities.getCallbackHandle(callback)!.toRawHandle(),
        geofenceData,
      ],
    );
  }
}

class VeriFiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _veriFiAppTheme(),
      darkTheme: _veriFiAppDarkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/onboarding',
      routes: {
        '/home': (context) => HomePage(),
        '/onboarding': (context) => IntroScreen(),
        '/onboarding/phone': (context) => PhoneNumberScreen(),
        '/onboarding/sms': (context) => SmsCodeScreen(),
        '/onboarding/wallet': (context) => ConnectWalletScreen(),
        '/onboarding/wallet/sign': (context) => SignWalletScreen(),
        '/onboarding/pfp': (context) => ProfilePictureSelectScreen(),
        '/onboarding/permissions': (context) => PermissionsScreen(),
      },
    );
  }
}

ThemeData _veriFiAppTheme() {
  return ThemeData.from(
    colorScheme: ColorScheme.light(
      primary: Colors.deepOrange[400]!,
      secondary: Colors.blueGrey[400]!,
    ),
    textTheme: GoogleFonts.juraTextTheme(),
  );
}

ThemeData _veriFiAppDarkTheme() {
  return ThemeData.from(
    colorScheme: ColorScheme.dark(
      primary: Colors.deepOrange[400]!,
      surface: Colors.deepOrange[600]!,
      secondary: Colors.blueGrey[400]!,
      outline: Colors.white,
    ),
    textTheme: GoogleFonts.juraTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
  );
}
