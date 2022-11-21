import 'package:flutter/material.dart';
import 'package:verifi/screens/profile_screen/profile_screen.dart';
import 'package:verifi/screens/map_screen/add_network/add_network_fab.dart';
import 'package:verifi/screens/map_screen/map_screen.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  late List<Widget> _bodyChildren;

  @override
  void initState() {
    super.initState();
    _bodyChildren = [
      MapScreen(),
      ProfileBody(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _bodyChildren,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: buildBottomNavBarItems(),
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      extendBodyBehindAppBar: (_currentIndex == 0) ? true : false,
    );
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.map),
        label: "WiFi Map",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_rounded),
        label: "My Profile",
      ),
    ];
  }

  PreferredSizeWidget? buildAppBar() {
    switch (_currentIndex) {
      case 0:
        // return MapSearchBar();
        return null;
      case 1:
        return ProfileAppBar();
      default:
        return null;
    }
  }

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 0:
        return AddNetworkFab();
      case 1:
        return null;
      case 2:
        return null;
      default:
        return null;
    }
  }
}
