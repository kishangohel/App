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
          ),
          child: const Icon(
            Icons.my_location,
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
