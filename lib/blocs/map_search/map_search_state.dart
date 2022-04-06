import 'package:equatable/equatable.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/models/wifi.dart';

class MapSearchState extends Equatable {
  final List<AutocompletePrediction>? predictions;
  final Wifi? selectedPlace;
  final bool? loading;
  const MapSearchState({this.predictions = const [], this.selectedPlace, this.loading});

  @override
  List<Object?> get props => [predictions, selectedPlace];

  MapSearchState copyWith({
    List<AutocompletePrediction>? predictions,
    Wifi? selectedPlace,
    bool? loading,
  }) {
    return MapSearchState(
      predictions: predictions ?? this.predictions,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      loading: loading ?? this.loading,
    );
  }
}
