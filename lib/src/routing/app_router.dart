import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/achievement/presentation/achievements_screen.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen.dart';
import 'package:verifi/src/features/authentication/presentation/sign_in/sign_in_screen.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_code_screen.dart';
import 'package:verifi/src/features/map/presentation/map_screen.dart';
import 'package:verifi/src/features/menu/presentation/menu_screen.dart';
import 'package:verifi/src/features/onboarding/data/onboarding_state_provider.dart';
import 'package:verifi/src/features/onboarding/presentation/features_screen.dart';
import 'package:verifi/src/features/onboarding/presentation/permissions_screen.dart';
import 'package:verifi/src/features/onboarding/presentation/welcome_screen.dart';
import 'package:verifi/src/features/profile/presentation/profile_screen.dart';
import 'package:verifi/src/home_screen.dart';

part '_generated/app_router.g.dart';

enum AppRoute {
  signIn,
  smsCode,
  displayName,
  achievements,
  veriMap,
  profile,
  menu,
  onboarding,
  features,
  permissions,
  loading,
  error,
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final authUser = ref.watch(firebaseAuthStateChangesProvider);
  final isOnboarded = ref.watch(onboardingStateProvider);
  // print("Auth user: ${authUser.value}");
  // print("isOnboarded: ${isOnboarded.value}");
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/profile',
    debugLogDiagnostics: true,
    redirect: (context, routerState) {
      // If user has not onboarded, redirect to onboarding
      final isOnboardedRedirect = isOnboarded.when<String?>(
        data: (data) => data ? null : '/onboarding',
        error: (_, __) => '/loading',
        loading: () => '/loading',
      );
      if (isOnboardedRedirect != null &&
          !routerState.location.startsWith('/onboarding')) {
        return isOnboardedRedirect;
      }
      // If user is not signed in, redirect to auth screen
      final authRedirect = authUser.when(
        data: (data) => (data != null) ? null : '/signIn',
        error: (_, __) => '/loading',
        loading: () => '/loading',
      );
      if (authRedirect != null &&
          !routerState.location.startsWith('/onboarding') &&
          !routerState.location.startsWith('/signIn')) {
        return authRedirect;
      }
      return null;
    },
    restorationScopeId: 'app',
    routes: [
      // Application shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/veriMap',
            name: AppRoute.veriMap.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: MapScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: AppRoute.profile.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/achievements',
            name: AppRoute.achievements.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: AchievementsScreen(),
            ),
          ),
          GoRoute(
            path: '/menu',
            name: AppRoute.menu.name,
            pageBuilder: (context, state) => NoTransitionPage(
              child: MenuScreen(),
            ),
          ),
        ],
      ),
      // Authentication
      GoRoute(
        path: '/signIn',
        name: AppRoute.signIn.name,
        builder: (context, state) => const SignInScreen(),
        routes: [
          GoRoute(
            path: 'smsCode',
            name: AppRoute.smsCode.name,
            builder: (context, state) => SmsCodeScreen(),
          ),
          GoRoute(
            path: 'displayName',
            name: AppRoute.displayName.name,
            builder: (context, state) => const DisplayNameScreen(),
          ),
        ],
      ),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        builder: (context, state) => WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'features',
            name: AppRoute.features.name,
            builder: (context, state) => const FeaturesScreen(),
          ),
          GoRoute(
            path: 'permissions',
            name: AppRoute.permissions.name,
            builder: (context, state) => const PermissionsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/loading',
        name: AppRoute.loading.name,
        builder: (context, state) => Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    ],
  );
}
