import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

// Maintains global state of map position and map controller.
// Markers are yielded via MapLoaded.
class MapCubit extends Cubit<MapState> {
  final WifiRepository _wifiRepository;
  final MapController mapController;
  late final StreamSubscription<MapEvent> _mapEventSubscription;

  FocusNode? focus;

  MapCubit(this._wifiRepository)
      : mapController = MapController(),
        super(const MapState()) {
    _mapEventSubscription = mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventRotateEnd) {
        if (mapController.zoom > 12.0) {
          update();
        } else {
          clear();
        }
      }
    });
  }

  void update() async {
    final bounds = mapController.bounds!;
    final GeoFirePoint currentGeoPoint = _wifiRepository.geo.point(
      latitude: mapController.center.latitude,
      longitude: mapController.center.longitude,
    );
    double radius = currentGeoPoint.haversineDistance(
      lat: bounds.northEast!.latitude,
      lng: bounds.northEast!.longitude,
    );
    final accessPoints = await MapUtils.getNearbyAccessPoints(
      _wifiRepository,
      currentGeoPoint,
      radius,
    );
    emit(state.copyWith(accessPoints: accessPoints));
  }

  void clear() {
    emit(state.copyWith(accessPoints: [], users: []));
  }

  @override
  Future<void> close() {
    _mapEventSubscription.cancel();
    mapController.dispose();
    return super.close();
  }
}
