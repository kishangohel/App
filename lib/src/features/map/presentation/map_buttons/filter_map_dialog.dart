import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';

class FilterMapDialog extends ConsumerWidget {
  const FilterMapDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(mapFilterControllerProvider);
    return AlertDialog(
      title: const Text("Filter map"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            key: const Key('filter_map_dialog_checkbox_profiles'),
            secondary: const Icon(Icons.person),
            title: const Text("Users"),
            value: filter.value?.showProfiles ?? false,
            onChanged: (filter.value != null)
                ? (bool? value) {
                    _setFilter(
                      ref,
                      showProfiles: value == true,
                      showAccessPoints: filter.value!.showAccessPoints,
                    );
                  }
                : null,
          ),
          CheckboxListTile(
            key: const Key('filter_map_dialog_checkbox_access_points'),
            secondary: const Icon(Icons.wifi),
            title: const Text("Wifi"),
            value: filter.value?.showAccessPoints ?? false,
            onChanged: (filter.value != null)
                ? (bool? value) {
                    _setFilter(
                      ref,
                      showProfiles: filter.value!.showProfiles,
                      showAccessPoints: value == true,
                    );
                  }
                : null,
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
    );
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
