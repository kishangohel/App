import 'package:flutter/material.dart';
import 'package:verifi/screens/map_screen/map_buttons.dart';

import 'map_flutter_map.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapFlutterMap(),
        MapButtons(),
      ],
    );
  }
}
