import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/map_styles.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

// Maintains global state of map position and map controller.
// Markers are yielded via MapLoaded.
class MapCubit extends Cubit<MapState> {
  final WifiRepository _wifiRepository;
  final PlaceRepository _placeRepository;
  GoogleMapController? mapController;

  // This should be directly updated by the map whenever onMapChanged occurs
  CameraPosition? currentPosition;
  Map<String, BitmapDescriptor>? apMarkers;
  FocusNode? focus;

  MapCubit(
    this._wifiRepository,
    this._placeRepository,
  ) : super(const MapState()) {
    MapMarkersHelper.getMarkers().then((value) => apMarkers = value);
  }

  void initialize(
    GoogleMapController controller,
    BuildContext context,
  ) async {
    mapController = controller;
    mapController?.setMapStyle(
        (MediaQuery.of(context).platformBrightness == Brightness.light)
            ? lightMapStyle
            : darkMapStyle);
  }

  void update(BuildContext context) async {
    const clusterTextColor = Colors.white;
    if (currentPosition == null) {
      return;
    }
    final bounds = await mapController!.getVisibleRegion();
    final GeoFirePoint currentGeoPoint = _wifiRepository.geo.point(
      latitude: currentPosition!.target.latitude,
      longitude: currentPosition!.target.longitude,
    );
    double radius = currentGeoPoint.haversineDistance(
      lat: bounds.northeast.latitude,
      lng: bounds.northeast.longitude,
    );
    double zoom = await mapController!.getZoomLevel();
    List<AccessPoint> accessPoints = await MapUtils.getNearbyAccessPoints(
      _wifiRepository,
      currentGeoPoint,
      radius,
    );
    accessPoints = await MapUtils.transformToClusters(
      accessPoints,
      zoom,
      apMarkers!,
      clusterTextColor,
    );
    emit(state.copyWith(accessPoints: accessPoints));
  }

  void clear() {
    emit(state.copyWith(accessPoints: [], users: []));
  }
}
