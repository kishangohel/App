import 'package:equatable/equatable.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:verifi/models/access_point.dart';

class MapSearchState extends Equatable {
  final List<Prediction> predictions;
  final AccessPoint? selectedPlace;
  final bool? loading;
  const MapSearchState({
    this.predictions = const [],
    this.selectedPlace,
    this.loading,
  });

  @override
  List<Object?> get props => [predictions, selectedPlace];

  MapSearchState copyWith({
    List<Prediction>? predictions,
    AccessPoint? selectedPlace,
    bool? loading,
  }) {
    return MapSearchState(
      predictions: predictions ?? this.predictions,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      loading: loading ?? this.loading,
    );
  }
}
