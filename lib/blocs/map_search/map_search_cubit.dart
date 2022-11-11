import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';

import 'map_search.dart';

class MapSearchCubit extends Cubit<MapSearchState> {
  final PlaceRepository _placeRepository;
  final WifiRepository _wifiRepository;

  MapSearchCubit(
    this._placeRepository,
    this._wifiRepository,
  ) : super(const MapSearchState());

  Future<void> updateQuery(Location location, String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(predictions: null));
    }
    final predictions = await _placeRepository.searchNearbyPlaces(
      location,
      query,
      50,
    );
    emit(state.copyWith(predictions: predictions));
  }

  Future<PlaceDetails> _getPlaceDetails(String placeId) {
    return _placeRepository.getPlaceDetails(placeId, true);
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
    final ap = AccessPoint(
      id: (details[1] as WifiDetails).id,
      placeDetails: details[0] as PlaceDetails,
      wifiDetails: details[1] as WifiDetails,
    );
    emit(state.copyWith(selectedPlace: ap, predictions: [], loading: false));
  }
}
