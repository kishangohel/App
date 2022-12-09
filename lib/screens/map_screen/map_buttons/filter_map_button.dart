import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/map/map_filter.dart';
import 'package:verifi/screens/map_screen/map_buttons/filter_map_dialog.dart';

class FilterMapButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mapCubit = context.watch<MapCubit>();
    final mapFilter = mapCubit.state.mapFilter;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Icon(
        mapFilter == MapFilter.none ? Icons.filter_alt_off : Icons.filter_alt,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => FilterMapDialog(mapCubit: mapCubit),
        );
      },
    );
  }
}
