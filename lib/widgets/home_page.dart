import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:verifi/access_point_callbacks.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/app_tab.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/screens/map_screen/map_search_bar.dart';
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
    return MultiBlocListener(
      listeners: [
        BlocListener<TabBloc, AppTab>(
          listener: (context, appTabState) {
            setState(() => _currentIndex = appTabState.tab.index);
          },
        ),
        BlocListener<LocationCubit, Position?>(
          listener: (context, location) async {
            if (location != null) {
              context.read<ProfileCubit>().updateLocation(location);
              updateNearbyAccessPoints(location.latitude, location.longitude);
            }
          },
          listenWhen: (_, current) {
            return current != null;
          },
        ),
      ],
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
        floatingActionButton: _buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        extendBodyBehindAppBar: (_currentIndex == 0) ? true : false,
      ),
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
        return MapSearchBar();
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
