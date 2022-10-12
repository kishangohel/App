import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/map_styles.dart';

class MapGoogleMap extends StatefulWidget {
  final LatLng initialMapPosition;

  const MapGoogleMap(this.initialMapPosition);

  @override
  State<StatefulWidget> createState() => _MapGoogleMapState();
}

class _MapGoogleMapState extends State<MapGoogleMap>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final _initialCameraPosition =
        CameraPosition(target: widget.initialMapPosition, zoom: 16.0);

    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        // init markers
        Set<Marker> _markers = <Marker>{};
        if (context.read<LocationCubit>().state != null &&
            context.read<ProfileCubit>().pfp?.imageBitmap != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('user'),
              icon: BitmapDescriptor.fromBytes(
                context.read<ProfileCubit>().pfp!.imageBitmap,
              ),
              position: context.read<LocationCubit>().state!,
            ),
          );
        }
        final accessPoints =
            state.accessPoints?.map((ap) => ap.toMarker(context));
        if (accessPoints != null) {
          _markers.addAll(accessPoints);
        }

        return GoogleMap(
          mapToolbarEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          // myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _markers,
          onCameraMove: (cp) {
            context.read<MapCubit>().currentPosition = cp;
          },
          onCameraIdle: () async {
            final zoom =
                await context.read<MapCubit>().mapController?.getZoomLevel();
            if (zoom != null) {
              if (zoom > 12.0) {
                context.read<MapCubit>().update(context);
              } else {
                context.read<MapCubit>().clear();
              }
            }
          },
          onMapCreated: (controller) {
            context.read<MapCubit>().initialize(
                  controller,
                  context,
                );
          },
        );
      },
    );
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  Future _setMapStyle() async {
    final theme = WidgetsBinding.instance.window.platformBrightness;
    if (theme == Brightness.dark) {
      context.read<MapCubit>().mapController?.setMapStyle(darkMapStyle);
    } else {
      context.read<MapCubit>().mapController?.setMapStyle(lightMapStyle);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
