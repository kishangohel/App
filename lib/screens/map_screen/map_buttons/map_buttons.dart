import 'package:flutter/material.dart';
import 'package:verifi/screens/map_screen/map_buttons/filter_map_button.dart';
import 'package:verifi/screens/map_screen/map_buttons/location_map_button.dart';

class MapButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocationMapButton(),
          const SizedBox(height: 12),
          FilterMapButton(),
        ],
      ),
    );
  }
}
