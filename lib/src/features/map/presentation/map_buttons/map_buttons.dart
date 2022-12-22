import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/location_map_button.dart';

class MapButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.1,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
          left: 8.0,
          // right: 4.0,
          top: 32.0,
          bottom: 32.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.elliptical(140, 90),
            bottomLeft: Radius.elliptical(140, 90),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocationMapButton(),
            const SizedBox(height: 20),
            FilterMapButton(),
          ],
        ),
      ),
    );
  }
}
