import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/achievement/presentation/achievements_screen.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_screen.dart';
import 'package:verifi/src/features/map/presentation/map_screen.dart';
import 'package:verifi/src/features/profile/presentation/profile_screen.dart';
import 'package:verifi/src/home_screen.dart';
import 'package:verifi/src/home_screen_controller.dart';

part 'app_router.g.dart';

enum AppRoute {
  phone,
  sms,
  displayName,
  veriMap,
  profile,
  loading,
  error,
  achievements,
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

@Riverpod(keepAlive: true)
GoRouter goRouter(GoRouterRef ref) {
  final authStateChanges = ref.watch(authStateChangesProvider);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ref.read(homeScreenControllerProvider),
    debugLogDiagnostics: true,
    redirect: (context, routerState) async {
      String? redirect;
      // Check if user is logged in
      redirect = authStateChanges.when<String?>(
        // if user is not signed in, redirect to auth screen
        data: (user) {
          if (user == null) {
            if (false == routerState.subloc.contains('/auth')) {
              return '/auth';
            }
          } else {
            // If user is authenticated, but does not have display name,
            // proceed to onboarding
            if (null == user.displayName || '' == user.displayName) {
              return '/onboarding';
            }
          }
          return null;
        },
        loading: () => '/loading',
        error: (_, __) => null,
      );
      if (redirect != null) return redirect;
      // passthrough everything else
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
        ],
      ),
      // Authentication and onboarding
      GoRoute(
        path: '/auth',
        name: AppRoute.phone.name,
        builder: (context, state) => const PhoneScreen(),
        routes: [
          GoRoute(
            path: 'sms',
            name: AppRoute.sms.name,
            builder: (context, state) => const SmsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.displayName.name,
        builder: (context, state) => DisplayNameScreen(),
      ),
      GoRoute(
        path: '/loading',
        name: AppRoute.loading.name,
        builder: (context, state) => Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ],
  );
}
