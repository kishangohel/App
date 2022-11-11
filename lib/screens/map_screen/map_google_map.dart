import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/map_styles.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/screens/map_screen/marker_info_sheet.dart';

class MapGoogleMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapGoogleMapState();
}

class _MapGoogleMapState extends State<MapGoogleMap>
    with WidgetsBindingObserver {
  LatLng _initialLocation = const LatLng(40.77957, -73.96320);

  @override
  void initState() {
    super.initState();
    // Used for dynamically changing map style for light/dark mode
    WidgetsBinding.instance.addObserver(this);
    final cp = context.read<LocationCubit>().state;
    if (cp != null) {
      setState(() => _initialLocation = LatLng(cp.latitude, cp.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    final _initialCameraPosition = CameraPosition(
      target: _initialLocation,
      zoom: 16.0,
    );

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
                position: LatLng(
                  context.read<LocationCubit>().state!.latitude,
                  context.read<LocationCubit>().state!.longitude,
                ),
                onTap: () {
                  context.read<MapCubit>().mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            context.read<LocationCubit>().state!.latitude,
                            context.read<LocationCubit>().state!.longitude,
                          ),
                          19,
                        ),
                      );
                }),
          );
        }
        final accessPoints = state.accessPoints?.map(
          (ap) {
            return ap.toMarker(
              context,
              showMarkerInfoSheet,
            );
          },
        );
        if (accessPoints != null) {
          _markers.addAll(accessPoints);
        }

        return GoogleMap(
          mapToolbarEnabled: false,
          initialCameraPosition: _initialCameraPosition,
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
          // Dismiss keyboard and unfocus search bar if user taps anywhere
          // on the map
          onTap: (LatLng location) {
            FocusManager.instance.primaryFocus?.unfocus();
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

  void showMarkerInfoSheet(AccessPoint ap) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MarkerInfoSheet(ap),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      useRootNavigator: true,
    );
  }
}
