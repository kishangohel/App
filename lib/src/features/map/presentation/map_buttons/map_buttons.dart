import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/location_map_button.dart';

class MapButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.4,
      right: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocationMapButton(),
          const SizedBox(height: 20),
          FilterMapButton(),
        ],
      ),
    );
  }
}
