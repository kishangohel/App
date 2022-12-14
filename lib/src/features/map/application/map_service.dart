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
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

import 'center_zoom_controller.dart';

part 'map_service.g.dart';

class MapService {
  final Ref ref;
  final _mapController = MapController();
  CenterZoomController? _centerZoomController;
  late final StreamSubscription<MapEvent> _mapEventSubscription;

  MapController get mapController => _mapController;

  MapService(this.ref) {
    _mapEventSubscription = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventRotateEnd ||
          (event is MapEventMove &&
              event.id == CenterZoomAnimation.finished)) {
        updateMap();
      }
    });
    ref.onDispose(() {
      _mapEventSubscription.cancel();
      _mapController.dispose();
    });
  }

  void associateMap(TickerProvider vsync) {
    _centerZoomController = CenterZoomController(
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
    ref.read(accessPointLayerControllerProvider.notifier).updateAccessPoints();
    ref.read(userLayerControllerProvider.notifier).updateUsers();
  }

  void moveMapToCenter(LatLng center, [double? zoom]) {
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
    final accessPointRepo = ref.read(accessPointRepositoryProvider);
    final bounds = _mapController.bounds!;
    final GeoFirePoint currentGeoPoint = accessPointRepo.geo.point(
      latitude: _mapController.center.latitude,
      longitude: _mapController.center.longitude,
    );
    final radiusInKm = currentGeoPoint.haversineDistance(
      lat: bounds.northEast!.latitude,
      lng: bounds.northEast!.longitude,
    );
    final docs = await accessPointRepo
        .getAccessPointsWithinRadiusStream(currentGeoPoint, radiusInKm)
        .first;

    return docs
        .map<AccessPoint>((doc) => AccessPoint.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<List<UserProfile>> getNearbyUsers() async {
    if (_mapController.zoom < 12) {
      return <UserProfile>[];
    }
    final nearbyUsersRepo = ref.read(nearbyUsersRepositoryProvider);
    final bounds = _mapController.bounds!;
    final GeoFirePoint currentGeoPoint = nearbyUsersRepo.geo.point(
      latitude: _mapController.center.latitude,
      longitude: _mapController.center.longitude,
    );
    final radiusInKm = currentGeoPoint.haversineDistance(
      lat: bounds.northEast!.latitude,
      lng: bounds.northEast!.longitude,
    );
    final docs = await nearbyUsersRepo
        .getUsersWithinRadiusStream(currentGeoPoint, radiusInKm)
        .first;

    return docs
        .map<UserProfile>((doc) => UserProfile.fromDocumentSnapshot(doc))
        .toList();
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
