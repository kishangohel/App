import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:verifi/src/routing/app_router.dart';

import 'home_screen_controller.dart';

/// The outer Widget for the VeriFi application.
/// Contains the BottomNavigationBar that is used for primary navigation.
///
/// [child] is populated by GoRouter via [ShellRoute].
///
class HomeScreen extends ConsumerWidget {
  final Widget child;
  const HomeScreen({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidTrophy),
            icon: Icon(FontAwesomeIcons.lightTrophy),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidMap),
            icon: Icon(FontAwesomeIcons.lightMap),
            label: 'VeriMap',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidUser),
            icon: Icon(FontAwesomeIcons.lightUser),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidBars),
            icon: Icon(FontAwesomeIcons.lightBars),
            label: 'More',
          ),
        ],
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onItemTapped(
          ref.read(homeScreenControllerProvider.notifier),
          GoRouter.of(context),
          index,
        ),
      ),
    );
  }

  int _getSelectedIndex(
    BuildContext context,
  ) {
    final String location = GoRouter.of(context).location;
    if (location.contains('/achievements')) {
      return 0;
    }
    if (location.startsWith('/veriMap')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    if (location.startsWith('/menu')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(
    HomeScreenController controller,
    GoRouter router,
    int index,
  ) {
    switch (index) {
      case 0:
        controller.setPage('/achievements');
        router.goNamed(AppRoute.achievements.name);
        break;
      case 1:
        controller.setPage('/veriMap');
        router.goNamed(AppRoute.veriMap.name);
        break;
      case 2:
        controller.setPage('/profile');
        router.goNamed(AppRoute.profile.name);
        break;
      case 3:
        controller.setPage('/menu');
        router.goNamed(AppRoute.menu.name);
        break;
    }
  }
}
