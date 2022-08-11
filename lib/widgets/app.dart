import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/display_name_textfield/display_name_textfield_bloc.dart';
import 'package:verifi/blocs/intro_pages/intro_pages_cubit.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/blocs/theme/theme_state.dart';
import 'package:verifi/main.dart' as main;
import 'package:verifi/models/wifi.dart';
import 'package:verifi/repositories/opensea_repository.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/screens/onboarding/pfp_avatar_screen.dart';
import 'package:verifi/screens/onboarding/pfp_nft_screen.dart';
import 'package:verifi/screens/onboarding/ready_web3_screen.dart';
import 'package:verifi/screens/onboarding/connect_wallet_screen.dart';
import 'package:verifi/screens/onboarding/display_name_screen.dart';
import 'package:verifi/screens/onboarding/permissions_screen.dart';
import 'package:verifi/screens/onboarding/phone_number_screen.dart';
import 'package:verifi/screens/onboarding/final_setup_screen.dart';
import 'package:verifi/screens/onboarding/sign_wallet_screen.dart';
import 'package:verifi/screens/onboarding/sms_code_screen.dart';
import 'package:verifi/screens/onboarding/intro_screen.dart';
import 'package:verifi/screens/onboarding/terms_screen.dart';
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
        RepositoryProvider<OpenSeaRepository>(
          create: (context) => OpenSeaRepository(useTestNet: true),
        ),
        RepositoryProvider<PlacesRepository>(
          create: (context) => PlacesRepository(),
        ),
        RepositoryProvider<UsersRepository>(
          create: (context) => UsersRepository(),
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
            ),
          ),
          BlocProvider<DisplayNameTextfieldBloc>(
            create: (context) => DisplayNameTextfieldBloc(
              RepositoryProvider.of<UsersRepository>(context),
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
          BlocProvider<NftsCubit>(
            create: (context) => NftsCubit(
              RepositoryProvider.of<OpenSeaRepository>(context),
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
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<AuthenticationCubit, AuthenticationState>(
          builder: (context, authState) {
            return MaterialApp(
              theme: themeState.lightTheme,
              darkTheme: themeState.darkTheme,
              themeMode: ThemeMode.system,
              // initialRoute: '/home',
              home: _initialRoute(authState, context),
              routes: {
                '/home': (context) => Home(),
                '/onboarding': (context) => IntroScreen(),
                '/onboarding/readyWeb3': (context) => ReadyWeb3Screen(),
                '/onboarding/terms': (context) => TermsScreen(),
                '/onboarding/displayName': (context) => DisplayNameScreen(),
                '/onboarding/phone': (context) => PhoneNumberScreen(),
                '/onboarding/sms': (context) => SmsCodeScreen(),
                '/onboarding/permissions': (context) => PermissionsScreen(),
                '/onboarding/wallet': (context) => ConnectWalletScreen(),
                '/onboarding/wallet/sign': (context) => SignWalletScreen(),
                '/onboarding/pfpNft': (context) => PfpNftScreen(),
                '/onboarding/pfpAvatar': (context) => PfpAvatarScreen(),
                '/onboarding/finalSetup': (context) => FinalSetupScreen(),
              },
              navigatorObservers: [_VeriFiNavigatorObserver()],
            );
          },
        );
      },
    );
  }

  Widget _initialRoute(AuthenticationState authState, BuildContext context) {
    if (authState.user == null) {
      return IntroScreen();
    }
    return Home();
  }
}

class _VeriFiNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route poppedRoute, Route? newRoute) {
    debugPrint("""Route popped
Popped route: ${poppedRoute.settings.name}
New route: ${newRoute?.settings.name}""");
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint("""Route pushed
Previous route: ${previousRoute?.settings.name}
New route: ${route.settings.name}""");
  }

  @override
  void didRemove(Route removedRoute, Route? newRoute) {
    debugPrint("""Route removed 
Route removed: ${removedRoute.settings.name}
New route: ${newRoute?.settings.name}""");
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    debugPrint("""Route replaced
Old route: ${oldRoute?.settings.name}
New route: ${newRoute?.settings.name}""");
  }
}
