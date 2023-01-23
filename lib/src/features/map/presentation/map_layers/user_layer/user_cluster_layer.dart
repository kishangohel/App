import 'package:flutter/material.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/domain/user_profile_cluster.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import 'user_cluster_marker.dart';
import 'user_layer_controller.dart';
import 'user_marker.dart';
import 'user_profile_info_sheet.dart';

class UserClusterLayer extends ConsumerStatefulWidget {
  @override
  ConsumerState<UserClusterLayer> createState() => _UserClusterLayerState();
}

class _UserClusterLayerState extends ConsumerState<UserClusterLayer> {
  late final SuperclusterMutableController _clustersController;
  List<UserMarker>? _initialMarkers;

  @override
  void initState() {
    super.initState();
    _clustersController = SuperclusterMutableController();
    _setMarkers(ref.read(userLayerControllerProvider));
  }

  @override
  void dispose() {
    _clustersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Perform marker updates.
    ref.listen<AsyncValue<List<UserMarker>>>(
        userLayerControllerProvider, (previous, next) => _setMarkers(next));

    return SuperclusterLayer.mutable(
      minimumClusterSize: 3,
      initialMarkers: _initialMarkers ?? [],
      clusterDataExtractor: (marker) => UserProfileCluster.fromUser(
        (marker as UserMarker).profile,
      ),
      // Prevent creation from occurring in an isolate which is unnecessary
      // given the small size of the clusters and takes extra time to create an
      // isolate.
      wrapIndexCreation: (config) => Future.value(createSupercluster(config)),
      maxClusterRadius: (UserClusterMarker.size * 2.5).toInt(),
      loadingOverlayBuilder: (_) => const SizedBox.shrink(),
      controller: _clustersController,
      clusterWidgetSize: const Size(
        UserClusterMarker.size,
        UserClusterMarker.size,
      ),
      onMarkerTap: (marker) {
        ref.read(mapServiceProvider).moveMapToCenter(marker.point);
        _showMarkerInfoSheet(
          context,
          (marker as UserMarker).profile,
        );
      },
      builder: (context, location, count, clusterData) => UserClusterMarker(
        location: location,
        count: count,
        userCluster: clusterData as UserProfileCluster,
      ),
    );
  }

  void _setMarkers(AsyncValue<List<UserMarker>> asyncValue) {
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

  void _showMarkerInfoSheet(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => UserProfileInfoSheet(profile),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      useRootNavigator: true,
    );
  }
}
