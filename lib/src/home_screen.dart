import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'home_screen_controller.dart';

/// The outer Widget for the VeriFi application.
/// Contains the BottomNavigationBar that is used for primary navigation.
///
/// [child] is populated by GoRouter via [ShellRoute].
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
        iconSize: 20,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidTrophy),
            icon: Icon(FontAwesomeIcons.trophy),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidMap),
            icon: Icon(FontAwesomeIcons.map),
            label: 'VeriMap',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(FontAwesomeIcons.solidUser),
            icon: Icon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context, ref),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.startsWith('/achievements')) {
      return 0;
    }
    if (location.startsWith('/veriMap')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) {
    switch (index) {
      case 0:
        ref
            .read(homeScreenControllerProvider.notifier)
            .setPage('/achievements');
        GoRouter.of(context).go('/achievements');
        break;
      case 1:
        ref.read(homeScreenControllerProvider.notifier).setPage('/veriMap');
        GoRouter.of(context).go('/veriMap');
        break;
      case 2:
        ref.read(homeScreenControllerProvider.notifier).setPage('/profile');
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
