import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/data/nearby_users/nearby_users_repository.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_layer_controller.dart';
import 'package:verifi/src/features/map/presentation/map_layers/user_layer/user_layer_controller.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../presentation/flutter_map/map_flutter_map.dart';
import 'center_zoom_controller.dart';

part 'map_service.g.dart';

class MapService {
  final Ref ref;
  final MapController _mapController;
  CenterZoomController? _centerZoomController;
  late final StreamSubscription<MapEvent> _mapEventSubscription;

  MapController get mapController => _mapController;

  MapService(
    this.ref, {
    @visibleForTesting MapController? mapController,
  }) : _mapController = mapController ?? MapController() {
    _mapEventSubscription = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventRotateEnd ||
          (event is MapEventMove && event.id == CenterZoomAnimation.finished) ||
          (event is MapEventMove &&
              event.id == MapFlutterMap.initialLocationMove)) {
        updateMap();
      }
    });
    ref.onDispose(() {
      _mapEventSubscription.cancel();
      _mapController.dispose();
    });
  }

  void associateMap(
    TickerProvider vsync, {
    @visibleForTesting CenterZoomController? centerZoomController,
  }) {
    _centerZoomController = centerZoomController ??
        CenterZoomController(
          vsync: vsync,
          mapController: _mapController,
          animationOptions: const AnimationOptions.animate(
            curve: Curves.linear,
            velocity: 1,
          ),
        );
  }

  void disassociateMap() {
    _centerZoomController?.dispose();
    _centerZoomController = null;
  }

  void updateMap() async {
    await Future.wait([
      ref
          .read(accessPointLayerControllerProvider.notifier)
          .updateAccessPoints(),
      ref.read(userLayerControllerProvider.notifier).updateUsers(),
    ]);
  }

  void moveMapToCenter(LatLng center, {double? zoom}) {
    if (_centerZoomController != null) {
      _centerZoomController!.moveTo(
        CenterZoom(
          center: center,
          zoom: zoom ?? _mapController.zoom,
        ),
      );
    } else {
      _mapController.move(center, zoom ?? _mapController.zoom);
    }
  }

  Future<List<AccessPoint>> getNearbyAccessPoints() async {
    if (_mapController.zoom < 12) {
      return <AccessPoint>[];
    }
    final center = _mapController.center;
    final bounds = _mapController.bounds!;
    final radiusInKm =
        const Haversine().distance(center, bounds.northEast!) / 1000.0;

    return await ref
        .read(accessPointRepositoryProvider)
        .getAccessPointsWithinRadiusStream(center, radiusInKm)
        .first;
  }

  Future<List<UserProfile>> getNearbyUsers() async {
    if (_mapController.zoom < 12) {
      return <UserProfile>[];
    }
    final center = _mapController.center;
    final bounds = _mapController.bounds!;
    final radiusInKm =
        const Haversine().distance(center, bounds.northEast!) / 1000.0;

    return await ref
        .read(nearbyUsersRepositoryProvider)
        .getUsersWithinRadiusStream(center, radiusInKm)
        .first;
  }
}

@Riverpod(keepAlive: true)
MapService mapService(MapServiceRef ref) {
  return MapService(ref);
}

@Riverpod(keepAlive: true)
MapController mapController(MapControllerRef ref) {
  return ref.watch(mapServiceProvider).mapController;
}
