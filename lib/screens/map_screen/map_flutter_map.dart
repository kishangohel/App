import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/map_screen/widgets/cluster_layer.dart';
import 'package:verifi/screens/map_screen/widgets/mapbox_tile_layer.dart';

class MapFlutterMap extends StatefulWidget {
  static const maxZoom = 19.0;

  @override
  State<StatefulWidget> createState() => _MapFlutterMapState();
}

class _MapFlutterMapState extends State<MapFlutterMap>
    with WidgetsBindingObserver {
  static const _initialZoom = 16.0;

  LatLng _initialLocation = LatLng(40.77957, -73.96320);

  @override
  void initState() {
    super.initState();

    final cp = context.read<LocationCubit>().state;
    if (cp != null) {
      setState(() => _initialLocation = LatLng(cp.latitude, cp.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: context.read<MapCubit>().mapController,
      options: MapOptions(
        maxZoom: MapFlutterMap.maxZoom,
        interactiveFlags: InteractiveFlag.all - InteractiveFlag.rotate,
        center: _initialLocation,
        zoom: _initialZoom,
      ),
      children: [
        MapboxTileLayer(),
        ClusterLayer(),
      ],
    );
  }
}
