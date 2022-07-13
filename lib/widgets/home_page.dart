import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/app_tab.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/screens/profile_screen/profile_screen.dart';
import 'package:verifi/widgets/feed_screen/feed_screen.dart';
import 'package:verifi/widgets/map_screen/add_network_fab.dart';
import 'package:verifi/widgets/map_screen/map_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late List<Widget> _bodyChildren;

  @override
  void initState() {
    super.initState();
    _bodyChildren = [
      FeedScreen(),
      MapScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TabBloc, AppTab>(
      listener: (context, appTabState) {
        setState(() => _currentIndex = appTabState.tab.index);
      },
      child: Scaffold(
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
        floatingActionButton: buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: "WiFi Feed",
      ),
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
        return null;
      case 1:
        return null;
      case 2: 
        return null; 
      default:
        return null;
    }
  }

  Widget? buildFab() {
    switch (_currentIndex) {
      case 0:
        return null;
      case 1:
        return AddNetworkFab();
      case 2:
        return null;
      default:
        return null;
    }
  }
}
