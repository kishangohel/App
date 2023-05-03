import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/floating_action_button.dart';

import 'flutter_map/map_flutter_map.dart';
import 'map_buttons/map_buttons.dart';

class MapScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapFlutterMap(),
          MapButtons(),
        ],
      ),
      floatingActionButton: const MapFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
