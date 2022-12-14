import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The outer Widget for the VeriFi application.
/// Contains the BottomNavigationBar that is used for primary navigation.
///
/// [child] is populated by GoRouter via [ShellRoute].
class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'VeriMap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _getSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.startsWith('/veriMap')) {
      return 0;
    }
    if (location.startsWith('/profile')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/veriMap');
        break;
      case 1:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
