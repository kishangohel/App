import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/models/pfp_cluster.dart';
import 'package:verifi/screens/map_screen/profile_info_sheet.dart';
import 'package:verifi/screens/map_screen/widgets/pfp_cluster_marker.dart';
import 'package:verifi/screens/map_screen/widgets/profile_marker.dart';

class ProfileClusterLayer extends StatefulWidget {
  @override
  State<ProfileClusterLayer> createState() => _ProfileClusterLayerState();
}

class _ProfileClusterLayerState extends State<ProfileClusterLayer> {
  List<ProfileMarker> _initialMarkers = [];
  late final SuperclusterMutableController _clustersController;

  @override
  void initState() {
    super.initState();
    _clustersController = SuperclusterMutableController();
    _updateUserMarker();
  }

  @override
  void dispose() {
    _clustersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapCubit, MapState>(
      listenWhen: (oldState, newState) =>
          oldState.center != newState.center ||
          oldState.zoom != newState.zoom ||
          oldState.showProfiles != newState.showProfiles,
      listener: (context, state) => _updateUserMarker(state),
      child: SuperclusterLayer.mutable(
        minimumClusterSize: 3,
        initialMarkers: _initialMarkers,
        clusterDataExtractor: (marker) => PfpCluster.fromPfp(
          (marker as ProfileMarker).profile.pfp!,
        ),
        loadingOverlayBuilder: (_) => const SizedBox.shrink(),
        controller: _clustersController,
        clusterWidgetSize: const Size(
          PfpClusterMarker.size,
          PfpClusterMarker.size,
        ),
        onMarkerTap: (marker) {
          context.read<MapCubit>().move(marker.point);
          _showMarkerInfoSheet(
            context,
            (marker as ProfileMarker).profile,
          );
        },
        builder: (context, count, clusterData) => PfpClusterMarker(
          count: count,
          pfpCluster: clusterData as PfpCluster,
        ),
      ),
    );
  }

  void _updateUserMarker([MapState? mapState]) {
    if (mapState != null) {
      if (!mapState.showProfiles ||
          (mapState.zoom != null && mapState.zoom! <= 12.0)) {
        _clustersController.clear();
        return;
      }
    }

    final locationState = context.read<LocationCubit>().state;
    final profile = context.read<ProfileCubit>().state;

    if (locationState != null) {
      final markers = [
        ProfileMarker(
          point: LatLng(locationState.latitude, locationState.longitude),
          profile: profile,
        ),
      ];
      _initialMarkers = markers;
      _clustersController.replaceAll(markers);
    }
  }

  void _showMarkerInfoSheet(BuildContext context, Profile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ProfileInfoSheet(profile),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      useRootNavigator: true,
    );
  }
}
