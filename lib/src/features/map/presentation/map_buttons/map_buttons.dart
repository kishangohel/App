import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/data/location/current_location_provider.dart';

class MapButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      right: 0,
      child: Column(
        children: [
          LocationMapButton(),
          const SizedBox(height: 10),
          FilterMapButton(),
        ],
      ),
    );
  }
}

class LocationMapButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        Icons.my_location,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      onPressed: () {
        if (ref.read(locationRepositoryProvider).currentLocation != null) {
          ref.read(mapControllerProvider).move(
                ref.read(locationRepositoryProvider).currentLocation!,
                18,
              );
        }
      },
    );
  }
}

class FilterMapButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapFilter = ref.watch(mapFilterControllerProvider);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        mapFilter.whenData<IconData>((filter) {
          return filter == MapFilter.none
              ? Icons.filter_alt_off
              : Icons.filter_alt;
        }).value,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      onPressed: () {
        ref.read(mapFilterControllerProvider).whenData((filter) {
          showDialog(
            context: context,
            builder: (context) => const FilterMapDialog(),
          );
        });
      },
    );
  }
}

class FilterMapDialog extends ConsumerWidget {
  const FilterMapDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
            .watch(mapFilterControllerProvider)
            .whenData<Widget>(
              (filter) => AlertDialog(
                title: const Text("Filter map"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      secondary: const Icon(Icons.person),
                      title: const Text("Users"),
                      value: filter.showProfiles,
                      onChanged: (bool? value) {
                        _setFilter(
                          ref,
                          showProfiles: value == true,
                          showAccessPoints: filter.showAccessPoints,
                        );
                      },
                    ),
                    CheckboxListTile(
                      secondary: const Icon(Icons.wifi),
                      title: const Text("Wifi"),
                      value: filter.showAccessPoints,
                      onChanged: (bool? value) {
                        _setFilter(
                          ref,
                          showProfiles: filter.showProfiles,
                          showAccessPoints: value == true,
                        );
                      },
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            )
            .value ??
        const SizedBox.shrink();
  }

  void _setFilter(
    WidgetRef ref, {
    required bool showProfiles,
    required bool showAccessPoints,
  }) {
    final mapFilterController = ref.read(mapFilterControllerProvider.notifier);
    if (showProfiles && showAccessPoints) {
      mapFilterController.applyFilter(MapFilter.none);
    } else if (showProfiles && !showAccessPoints) {
      mapFilterController.applyFilter(MapFilter.excludeAccessPoints);
    } else if (!showProfiles && showAccessPoints) {
      mapFilterController.applyFilter(MapFilter.excludeProfiles);
    } else {
      mapFilterController.applyFilter(MapFilter.excludeAll);
    }
  }
}
