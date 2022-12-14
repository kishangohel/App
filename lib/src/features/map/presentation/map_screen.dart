import 'package:flutter/material.dart';

import 'flutter_map/map_flutter_map.dart';
import 'map_buttons/map_buttons.dart';

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
