import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';

class MapGoogleMap extends StatelessWidget {
  final LatLng initialMapPosition;

  const MapGoogleMap(this.initialMapPosition);

  @override
  Widget build(BuildContext context) {
    final _initialCameraPosition =
        CameraPosition(target: initialMapPosition, zoom: 16.0);
    return Focus(
      autofocus: true,
      child: GoogleMap(
        mapToolbarEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        markers: context
                .watch<MapCubit>()
                .state
                .wifis
                ?.map((wifi) => wifi.toMarker(context))
                .toSet() ??
            <Marker>{},
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        onCameraMove: (cp) {
          context.read<MapCubit>().currentPosition = cp;
        },
        onCameraIdle: () async {
          final zoom =
              await context.read<MapCubit>().mapController?.getZoomLevel();
          if (zoom != null) {
            if (zoom > 12.0) {
              context.read<MapCubit>().update();
            } else {
              context.read<MapCubit>().clear();
            }
            print("Zoom level: $zoom");
          }
        },
        onMapCreated: (controller) {
          BlocProvider.of<MapCubit>(context).initialize(
            controller,
          );
        },
      ),
    );
  }
}
