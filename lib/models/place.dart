import 'package:equatable/equatable.dart';
import 'package:google_maps_webservice/places.dart';

class Place extends Equatable {
  final String placeId;
  final String name;
  final Location? location;

  const Place({
    required this.placeId,
    required this.name,
    this.location,
  });

  Place copyWith({
    String? placeId,
    String? name,
    Location? location,
  }) {
    return Place(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [placeId, name, location];
}
