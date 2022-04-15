import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/wifi.dart';
import 'package:verifi/models/wifi_details.dart';
import 'package:verifi/repositories/repositories.dart';

import 'map_search.dart';

class MapSearchCubit extends Cubit<MapSearchState> {
  final PlacesRepository _placesRepository;
  final WifiRepository _wifiRepository;

  MapSearchCubit(
    this._placesRepository,
    this._wifiRepository,
  ) : super(const MapSearchState());

  Future<void> updateQuery(LatLon location, String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(predictions: null));
    }
    final predictions = await _placesRepository.searchNearbyPlaces(
      location,
      query,
    );
    emit(state.copyWith(predictions: predictions));
  }

  Future<DetailsResult?> _getPlaceDetails(String placeId) {
    return _placesRepository.getPlaceDetails(placeId, true);
  }

  Future<WifiDetails?> _getWifiDetails(String placeId) {
    return _wifiRepository.getWifiMarkerAtPlaceId(placeId);
  }

  Future<void> getWifiAtPlaceId(String placeId) async {
    emit(state.copyWith(loading: true));
    List<dynamic> details = await Future.wait([
      _getPlaceDetails(placeId),
      _getWifiDetails(placeId),
    ]);
    final wifi = Wifi(
      id: (details[1] as WifiDetails).id,
      placeDetails: details[0] as DetailsResult?,
      wifiDetails: details[1] as WifiDetails?,
    );
    emit(state.copyWith(selectedPlace: wifi, predictions: [], loading: false));
  }
}
