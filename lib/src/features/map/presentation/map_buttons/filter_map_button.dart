import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/application/map_filter_controller.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_dialog.dart';

class FilterMapButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapFilter = ref.watch(mapFilterControllerProvider);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 4.0,
        padding: const EdgeInsets.all(14),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: mapFilter.when(
        data: (filter) {
          return () {
            showDialog(
              context: context,
              builder: (context) => const FilterMapDialog(),
            );
          };
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      ),
      child: Icon(
        !mapFilter.hasValue || mapFilter.valueOrNull == MapFilter.none
            ? Icons.filter_alt_off
            : Icons.filter_alt,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
