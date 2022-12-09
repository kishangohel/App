import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/map_screen/widgets/access_point_cluster_layer.dart';
import 'package:verifi/screens/map_screen/widgets/mapbox_tile_layer.dart';
import 'package:verifi/screens/map_screen/widgets/profile_cluster_layer.dart';

class MapFlutterMap extends StatefulWidget {
  static const maxZoom = 19.0;

  @override
  State<StatefulWidget> createState() => _MapFlutterMapState();
}

class _MapFlutterMapState extends State<MapFlutterMap>
    with TickerProviderStateMixin<MapFlutterMap> {
  static const _initialZoom = 16.0;

  LatLng _initialLocation = LatLng(40.77957, -73.96320);

  @override
  void initState() {
    super.initState();

    final location = context.read<LocationCubit>().state;
    if (location != null) {
      setState(() {
        _initialLocation = LatLng(location.latitude, location.longitude);
      });
    }
  }

  @override
  void dispose() {
    context.read<MapCubit>().disassociateMap();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapCubit = context.read<MapCubit>();
    return FlutterMap(
      mapController: mapCubit.mapController,
      options: MapOptions(
          maxZoom: MapFlutterMap.maxZoom,
          interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
          center: _initialLocation,
          zoom: _initialZoom,
          onMapReady: () {
            mapCubit.associateMap(this);
            mapCubit.update();
          }),
      children: [
        MapboxTileLayer(),
        AccessPointClusterLayer(),
        ProfileClusterLayer(),
      ],
    );
  }
}
