import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/map/map.dart';
import 'package:verifi/blocs/map_markers_helper.dart';
import 'package:verifi/blocs/wifi_utils.dart';
import 'package:verifi/models/wifi.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/blocs/strings.dart';

// Maintains global state of map position and map controller.
// Markers are yielded via MapLoaded.
class MapCubit extends Cubit<MapState> {
  final WifiRepository _remoteRepository;
  final PlacesRepository _placesRepository;
  GoogleMapController? mapController;

  // This should be directly updated by the map whenever onMapChanged occurs
  CameraPosition? currentPosition;
  BitmapDescriptor? marker;
  FocusNode? focus;

  MapCubit(
    this._remoteRepository,
    this._placesRepository,
  ) : super(const MapState());

  void initialize(
    GoogleMapController controller,
    BuildContext context,
  ) async {
    mapController = controller;
    mapController?.setMapStyle(
        (MediaQuery.of(context).platformBrightness == Brightness.light)
            ? lightMapStyle
            : darkMapStyle);
    await MapMarkersHelper.initMarker(context);
    marker = await MapMarkersHelper.getMarker();
  }

  void update() async {
    if (currentPosition == null) {
      return;
    }
    final bounds = await mapController!.getVisibleRegion();
    final GeoFirePoint currentGeoPoint = _remoteRepository.geo.point(
      latitude: currentPosition!.target.latitude,
      longitude: currentPosition!.target.longitude,
    );
    double radius = currentGeoPoint.haversineDistance(
      lat: bounds.northeast.latitude,
      lng: bounds.northeast.longitude,
    );
    double zoom = await mapController!.getZoomLevel();
    List<Wifi> wifis = await WifiUtils.getNearbyWifiWithPlaceDetails(
      _remoteRepository,
      _placesRepository,
      currentGeoPoint,
      radius,
    );
    wifis = await WifiUtils.transformToClusters(
      wifis,
      zoom,
      marker!,
    );
    emit(state.copyWith(wifis: wifis));
  }

  void clear() {
    emit(state.copyWith(wifis: []));
  }
}
