import 'package:flutter/material.dart';
import 'package:verifi/screens/map_screen/map_google_map.dart';
import 'package:verifi/screens/map_screen/map_buttons.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapGoogleMap(),
        MapButtons(),
      ],
    );
  }
}
