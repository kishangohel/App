import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:verifi/models/place.dart';
import 'package:verifi/repositories/place_repository.dart';

class PlacesCubit extends Cubit<List<Place>> {
  final PlaceRepository _placeRepository;
  PlacesCubit(this._placeRepository) : super(<Place>[]);

  Future<void> searchNearbyPlaces(
    String query,
    Position location,
    int radius,
  ) async {
    final predictions = await _placeRepository.searchNearbyPlaces(
      Location(lat: location.latitude, lng: location.longitude),
      query,
      radius,
    );
    final places = predictions
        .map<Place>((prediction) => Place(
              placeId: prediction.placeId!,
              name: prediction.description!,
            ))
        .toList();
    emit(places);
  }
}
