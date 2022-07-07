import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/widgets/map_screen/map_google_map.dart';
import 'package:verifi/widgets/map_screen/map_buttons.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapGoogleMap(
          // get current location or previously saved location
          // default to Washington D.C. if neither is set
          LatLng(
            context.read<LocationCubit>().state?.latitude ?? 38.8937335,
            context.read<LocationCubit>().state?.longitude ?? -77.0847867,
          ),
        ),
        MapButtons(),
      ],
    );
  }
}
