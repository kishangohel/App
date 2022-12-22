import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';

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
