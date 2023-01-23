import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RadarAddress extends Equatable {
  /// The name of the place (e.g. Starbucks)
  final String name;

  /// The formatted address (e.g. 123 Fox Street, New York, NY 10001 USA)
  final String address;

  /// The location of the place
  final LatLng location;

  /// The distance between this address and the query origin
  /// (e.g. the user's current location)
  final int? distance;

  const RadarAddress({
    required this.name,
    required this.address,
    required this.location,
    this.distance,
  });

  factory RadarAddress.fromRadarAutocompleteResponse(
      Map<String, dynamic> json) {
    return RadarAddress(
      name: json['placeLabel'],
      address: json['formattedAddress'],
      location: LatLng(json['latitude'], json['longitude']),
      distance: json['distance'],
    );
  }

  factory RadarAddress.fromJson(Map<String, dynamic> json) {
    return RadarAddress(
      name: json['name'],
      address: json['address'],
      location: LatLng.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'location': location.toJson(),
    };
  }

  RadarAddress copyWith({
    String? name,
    String? address,
    LatLng? location,
    int? distance,
  }) {
    return RadarAddress(
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [name, address, location];
}
