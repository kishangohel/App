import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/models/place.dart';
import 'package:verifi/repositories/places_repository.dart';

class PlacesCubit extends Cubit<List<Place>> {
  final PlacesRepository _placesRepository;
  PlacesCubit(this._placesRepository) : super(<Place>[]);

  Future<List<Place>> searchNearbyPlaces(
    String query,
    LatLng location,
  ) async {
    final predictions = await _placesRepository.searchNearbyPlaces(
      LatLon(location.latitude, location.longitude),
      query,
    );
    if (predictions == null) {
      return <Place>[];
    }
    final places = predictions
        .map<Place>((prediction) => Place(
              placeId: prediction.placeId!,
              name: prediction.description!,
            ))
        .toList();
    return places;
  }
}
