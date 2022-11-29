import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/location/location_cubit.dart';
import 'package:verifi/blocs/profile/profile_cubit.dart';
import 'package:verifi/screens/map_screen/widgets/user_marker.dart';

import '../../../blocs/map/map.dart';

class UserMarkerLayer extends StatefulWidget {
  @override
  State<UserMarkerLayer> createState() => _UserMarkerLayerState();
}

class _UserMarkerLayerState extends State<UserMarkerLayer> {
  late List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _updateUserMarker();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapCubit, MapState>(
      listener: (context, state) => _updateUserMarker(),
      child: MarkerLayer(
        markers: _markers,
      ),
    );
  }

  void _updateUserMarker() {
    final locationState = context.read<LocationCubit>().state;
    final pfp = context.read<ProfileCubit>().pfp;

    if (locationState != null && pfp != null) {
      setState(() {
        _markers = [
          UserMarker(
            point: LatLng(locationState.latitude, locationState.longitude),
            pfp: pfp,
          ),
        ];
      });
    }
  }
}
