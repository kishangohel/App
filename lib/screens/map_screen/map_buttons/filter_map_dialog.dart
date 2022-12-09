import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/map/map_filter.dart';

import '../../../blocs/map/map.dart';

class FilterMapDialog extends StatelessWidget {
  // This must be passed in since the dialog is not a child widget of the map
  //and therefore can't access the MapCubit via the context.
  final MapCubit mapCubit;

  const FilterMapDialog({
    super.key,
    required this.mapCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      bloc: mapCubit,
      builder: (context, state) => AlertDialog(
        title: const Text("Filter map"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              secondary: const Icon(Icons.person),
              title: const Text("Users"),
              value: state.showProfiles,
              onChanged: (bool? value) {
                _setFilter(
                  showProfiles: value == true,
                  showAccessPoints: state.showAccessPoints,
                );
              },
            ),
            CheckboxListTile(
              secondary: const Icon(Icons.wifi),
              title: const Text("Wifi"),
              value: mapCubit.state.showAccessPoints,
              onChanged: (bool? value) {
                _setFilter(
                  showProfiles: state.showProfiles,
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
    );
  }

  void _setFilter({
    required bool showProfiles,
    required bool showAccessPoints,
  }) {
    if (showProfiles && showAccessPoints) {
      mapCubit.applyFilter(MapFilter.none);
    } else if (showProfiles && !showAccessPoints) {
      mapCubit.applyFilter(MapFilter.excludeAccessPoints);
    } else if (!showProfiles && showAccessPoints) {
      mapCubit.applyFilter(MapFilter.excludeProfiles);
    } else {
      mapCubit.applyFilter(MapFilter.excludeAll);
    }
  }
}
