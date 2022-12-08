import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/map/center_zoom_controller.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

// Maintains global state of map position and map controller.
class MapCubit extends Cubit<MapState> {
  final WifiRepository _wifiRepository;
  final MapController _mapController;
  late final StreamSubscription<MapEvent> _mapEventSubscription;
  CenterZoomController? _centerZoomController;

  MapCubit(this._wifiRepository)
      : _mapController = MapController(),
        super(const MapState()) {
    _mapEventSubscription = _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventRotateEnd ||
          (event is MapEventMove && event.id == CenterZoomAnimation.finished)) {
        if (_mapController.zoom > 12.0) {
          update();
        } else {
          clear();
        }
      }
    });
  }

  MapController get mapController => _mapController;

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

  void update() async {
    emit(state.copyWith(
      center: _mapController.center,
      zoom: _mapController.zoom,
      accessPoints: await _nearbyAccessPoints(),
    ));
  }

  Future<List<AccessPoint>> _nearbyAccessPoints() {
    final bounds = _mapController.bounds!;
    final GeoFirePoint currentGeoPoint = _wifiRepository.geo.point(
      latitude: _mapController.center.latitude,
      longitude: _mapController.center.longitude,
    );
    double radius = currentGeoPoint.haversineDistance(
      lat: bounds.northEast!.latitude,
      lng: bounds.northEast!.longitude,
    );
    return MapUtils.getNearbyAccessPoints(
      _wifiRepository,
      currentGeoPoint,
      radius,
    );
  }

  void clear() {
    emit(state.copyWith(
      center: _mapController.center,
      zoom: _mapController.zoom,
      accessPoints: [],
      users: [],
    ));
  }

  void move(LatLng center, [double? zoom]) {
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

  @override
  Future<void> close() {
    _mapEventSubscription.cancel();
    _mapController.dispose();
    return super.close();
  }
}
