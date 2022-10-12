import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/display_name_textfield/display_name_textfield_bloc.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/blocs/theme/theme_state.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/repositories/nftport_repository.dart';
import 'package:verifi/repositories/repositories.dart';
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

/// The top-level [Widget] for the VeriFi application.
///
/// This should only be built by calling [runApp] in [main].
///
///
///
/// The widget is a [StatefulWidget] in order to setup communication with
/// [Isolate]s via [SendPort] and [ReceivePort].
///
/// Once the [IsolateNameServer] is setup and listening for callbacks,
/// [platform.invokeMethod] is called with the "initialize" method to initialize
/// the platform-specific code.
///
/// This widget provides all of the [Bloc]s and [Repository]s to their children.
class VeriFi extends StatefulWidget {
  final Profile? testProfile;
  const VeriFi(this.testProfile);

  @override
  State<StatefulWidget> createState() => VeriFiState();
}

class VeriFiState extends State<VeriFi> {
  DateTime onboardingPreBackPressTime = DateTime.now();
  @override
  void initState() {
    super.initState();
    onboardingPreBackPressTime = DateTime.now();
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
        RepositoryProvider<NftPortRepository>(
          create: (context) => NftPortRepository(),
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
          BlocProvider<LocationCubit>(
            create: (context) => LocationCubit(
              RepositoryProvider.of<UsersRepository>(context),
              RepositoryProvider.of<AuthenticationRepository>(context),
            ),
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
          BlocProvider<NftsCubit>(
            create: (context) => NftsCubit(
              RepositoryProvider.of<NftPortRepository>(context),
            ),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) {
              final cubit = ProfileCubit(
                RepositoryProvider.of<UsersRepository>(context),
              );
              if (kDebugMode && widget.testProfile != null) {
                cubit.setProfile(widget.testProfile!);
              }
              return cubit;
            },
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
        ],
        child: VeriFiApp(),
      ),
    );
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class VeriFiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          theme: themeState.lightTheme,
          darkTheme: themeState.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: _initialRoute(context),
          routes: {
            '/home': (context) => Home(),
            '/onboarding': (context) => const IntroScreen(),
            '/onboarding/readyWeb3': (context) => ReadyWeb3Screen(),
            '/onboarding/terms': (context) => TermsScreen(),
            '/onboarding/displayName': (context) => DisplayNameScreen(),
            '/onboarding/phone': (context) => const PhoneNumberScreen(),
            '/onboarding/sms': (context) => SmsCodeScreen(),
            '/onboarding/permissions': (context) => PermissionsScreen(),
            '/onboarding/wallet': (context) => ConnectWalletScreen(),
            '/onboarding/wallet/sign': (context) => SignWalletScreen(),
            '/onboarding/pfpNft': (context) => PfpNftScreen(),
            '/onboarding/finalSetup': (context) => FinalSetupScreen(),
          },
          navigatorObservers: [_VeriFiNavigatorObserver()],
        );
      },
    );
  }

  String? _initialRoute(BuildContext context) {
    // Have to call [FirebaseAuth] directly to force update [AuthenticationCubit]
    FirebaseAuth.instance.currentUser;
    bool isLoggedIn = context.read<AuthenticationCubit>().isLoggedIn;
    if (false == isLoggedIn) {
      return '/onboarding';
    } else if (false == sharedPrefs.permissionsComplete) {
      return '/onboarding/permissions';
    } else if (context.read<ProfileCubit>().displayName == null) {
      return '/onboarding/readyWeb3';
    } else if (false == sharedPrefs.onboardingComplete) {
      return '/onboarding/finalSetup';
    } else {
      return '/home';
    }
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
