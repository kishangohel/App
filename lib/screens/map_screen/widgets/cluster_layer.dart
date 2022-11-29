import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/blocs/map/map_cubit.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/models/access_point_cluster.dart';
import 'package:verifi/screens/map_screen/marker_info_sheet.dart';
import 'package:verifi/screens/map_screen/widgets/access_point_cluster_marker.dart';
import 'package:verifi/screens/map_screen/widgets/access_point_marker.dart';

class ClusterLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SuperclusterLayer.mutable(
      clusterDataExtractor: (marker) => AccessPointCluster.fromAccessPoint(
        (marker as AccessPointMarker).accessPoint,
      ),
      loadingOverlayBuilder: (_) => const SizedBox.shrink(),
      controller: context.read<MapCubit>().clustersController,
      clusterWidgetSize: const Size(
        AccessPointClusterMarker.radius,
        AccessPointClusterMarker.radius,
      ),
      onMarkerTap: (marker) => _showMarkerInfoSheet(
        context,
        (marker as AccessPointMarker).accessPoint,
      ),
      builder: (context, count, clusterData) => AccessPointClusterMarker(
        count: count,
        accessPointCluster: clusterData as AccessPointCluster,
      ),
    );
  }

  void _showMarkerInfoSheet(BuildContext context, AccessPoint ap) {
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
