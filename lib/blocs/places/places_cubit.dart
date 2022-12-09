import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/repositories/place_repository.dart';

import '../../models/models.dart';

class PlacesCubit extends Cubit<List<Place>> {
  final PlaceRepository _placeRepository;

  PlacesCubit(this._placeRepository) : super(<Place>[]);

  Future<void> searchNearbyPlaces(
    String query,
    Position location,
    int radius,
  ) async {
    final featureEntities = await _placeRepository.searchNearbyPlaces(
      LatLng(location.latitude, location.longitude),
      query,
      radius,
    );
    final features = featureEntities.map(Place.fromEntity).toList();
    emit(features);
  }
}
