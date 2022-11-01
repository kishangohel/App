import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';

class MapButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      right: 0,
      child: SizedBox(
        child: ElevatedButton(
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
            if (context.read<LocationCubit>().state != null) {
              final location = LatLng(
                context.read<LocationCubit>().state!.latitude,
                context.read<LocationCubit>().state!.longitude,
              );
              BlocProvider.of<MapCubit>(context).mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(location, 18),
                  );
            }
          },
        ),
      ),
    );
  }
}
