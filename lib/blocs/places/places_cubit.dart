import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/models/place.dart';
import 'package:verifi/repositories/place_repository.dart';

class PlacesCubit extends Cubit<List<Place>> {
  final PlaceRepository _placeRepository;
  PlacesCubit(this._placeRepository) : super(<Place>[]);

  Future<List<Place>> searchNearbyPlaces(
    String query,
    Position location,
  ) async {
    final predictions = await _placeRepository.searchNearbyPlaces(
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
