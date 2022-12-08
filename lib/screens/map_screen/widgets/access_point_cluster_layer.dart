import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/blocs/map/map.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/models/access_point_cluster.dart';
import 'package:verifi/screens/map_screen/access_point_info_sheet.dart';
import 'package:verifi/screens/map_screen/widgets/access_point_cluster_marker.dart';
import 'package:verifi/screens/map_screen/widgets/access_point_marker.dart';

class AccessPointClusterLayer extends StatefulWidget {
  @override
  State<AccessPointClusterLayer> createState() =>
      _AccessPointClusterLayerState();
}

class _AccessPointClusterLayerState extends State<AccessPointClusterLayer> {
  late final SuperclusterMutableController _clustersController;
  List<AccessPointMarker> _initialMarkers = [];

  @override
  void initState() {
    super.initState();
    _clustersController = SuperclusterMutableController();
    _updateMarkers();
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
          oldState.accessPoints != newState.accessPoints,
      listener: (context, state) => _updateMarkers(state),
      child: SuperclusterLayer.mutable(
        initialMarkers: _initialMarkers,
        clusterDataExtractor: (marker) => AccessPointCluster.fromAccessPoint(
          (marker as AccessPointMarker).accessPoint,
        ),
        loadingOverlayBuilder: (_) => const SizedBox.shrink(),
        controller: _clustersController,
        clusterWidgetSize: const Size(
          AccessPointClusterMarker.radius,
          AccessPointClusterMarker.radius,
        ),
        onMarkerTap: (marker) {
          context.read<MapCubit>().move(marker.point);
          _showMarkerInfoSheet(
            context,
            (marker as AccessPointMarker).accessPoint,
          );
        },
        builder: (context, count, clusterData) => AccessPointClusterMarker(
          count: count,
          accessPointCluster: clusterData as AccessPointCluster,
        ),
      ),
    );
  }

  void _showMarkerInfoSheet(BuildContext context, AccessPoint ap) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccessPointInfoSheet(ap),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      useRootNavigator: true,
    );
  }

  void _updateMarkers([MapState? mapState]) {
    mapState ??= context.read<MapCubit>().state;

    // Make sure access points are sorted stably otherwise clusters may move
    // around slightly.
    final sortedAccessPoints = mapState.accessPoints
      ?..sort((ap1, ap2) => ap1.id.compareTo(ap2.id));

    if (sortedAccessPoints != null) {
      final accessPointMarkers =
          sortedAccessPoints.map(AccessPointMarker.fromAccessPoint).toList();
      _initialMarkers = accessPointMarkers;
      _clustersController.replaceAll(accessPointMarkers);
    }
  }
}
