import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/models/models.dart';

import '../../../blocs/map/map.dart';

class UserMarker extends Marker {
  static const size = Size(40, 40);
  final Pfp pfp;

  UserMarker({
    required super.point,
    required this.pfp,
  }) : super(
          width: size.width,
          height: size.height,
          builder: (context) {
            return GestureDetector(
              onTap: () {
                final locationState = context.read<LocationCubit>().state!;
                // TODO: animate
                context.read<MapCubit>().mapController.move(
                      LatLng(
                        locationState.latitude,
                        locationState.longitude,
                      ),
                      19,
                    );
              },
              child: Image(
                image: pfp.image,
                width: size.width,
                height: size.height,
              ),
            );
          },
        );
}
