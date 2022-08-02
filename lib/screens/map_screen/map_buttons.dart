import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';

class MapButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      // 100% right, 70% up
      top: 100,
      right: 0,
      child: SizedBox(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(14),
            primary: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          child: Icon(
            Icons.my_location,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            if (context.read<LocationCubit>().state != null) {
              BlocProvider.of<MapCubit>(context)
                  .mapController
                  ?.animateCamera(CameraUpdate.newLatLngZoom(
                    context.read<LocationCubit>().state!,
                    18,
                  ));
            }
          },
        ),
      ),
    );
  }
}
