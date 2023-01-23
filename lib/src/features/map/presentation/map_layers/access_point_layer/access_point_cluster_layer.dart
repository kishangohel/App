import 'package:flutter/material.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/presentation/access_point_info_sheet.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/domain/access_point_cluster.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_layer_controller.dart';

import 'access_point_cluster_marker.dart';
import 'access_point_marker.dart';

class AccessPointClusterLayer extends ConsumerStatefulWidget {
  @override
  ConsumerState<AccessPointClusterLayer> createState() =>
      _AccessPointClusterLayerState();
}

class _AccessPointClusterLayerState
    extends ConsumerState<AccessPointClusterLayer> {
  late final SuperclusterMutableController _clustersController;
  List<AccessPointMarker>? _initialMarkers;

  @override
  void initState() {
    super.initState();
    _clustersController = SuperclusterMutableController();
    _setMarkers(ref.read(accessPointLayerControllerProvider));
  }

  @override
  void dispose() {
    _clustersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Perform marker updates.
    ref.listen<AsyncValue<List<AccessPointMarker>>>(
        accessPointLayerControllerProvider,
        (previous, next) => _setMarkers(next));

    return SuperclusterLayer.mutable(
      initialMarkers: _initialMarkers ?? [],
      clusterDataExtractor: (marker) => AccessPointCluster.fromAccessPoint(
        (marker as AccessPointMarker).accessPoint,
      ),
      // Prevent creation from occurring in an isolate which is unnecessary
      // given the small size of the clusters and takes extra time to create an
      // isolate.
      wrapIndexCreation: (config) => Future.value(createSupercluster(config)),
      loadingOverlayBuilder: (_) => const SizedBox.shrink(),
      maxClusterRadius: (AccessPointClusterMarker.radius * 2.5).toInt(),
      controller: _clustersController,
      clusterWidgetSize: const Size(
        AccessPointClusterMarker.radius,
        AccessPointClusterMarker.radius,
      ),
      onMarkerTap: (marker) {
        ref.read(mapServiceProvider).moveMapToCenter(marker.point);
        _showMarkerInfoSheet(
          context,
          (marker as AccessPointMarker).accessPoint,
        );
      },
      builder: (context, location, count, clusterData) =>
          AccessPointClusterMarker(
        location: location,
        count: count,
        accessPointCluster: clusterData as AccessPointCluster,
      ),
    );
  }

  void _setMarkers(AsyncValue<List<AccessPointMarker>> asyncValue) {
    asyncValue.when(
      data: (data) {
        if (_initialMarkers == null) {
          setState(() {
            _initialMarkers = data;
          });
        }

        _clustersController.replaceAll(data);
      },
      error: (error, stackTrace) {
        debugPrint(error.toString());
        debugPrintStack(stackTrace: stackTrace);
      },
      loading: () {},
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
}
