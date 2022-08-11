import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/map_screen/map_google_map.dart';
import 'package:verifi/screens/map_screen/map_buttons.dart';
import 'package:verifi/screens/map_screen/map_search_bar.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapGoogleMap(
            // default to Washington, D.C. if current location not set
            context.read<LocationCubit>().state ??
                const LatLng(38.8937335, -77.0847867),
          ),
          MapButtons(),
        ],
      ),
      appBar: MapSearchBar(),
      extendBodyBehindAppBar: true,
    );
  }
}
