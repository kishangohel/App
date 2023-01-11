import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Place extends Equatable {
  final String id;
  final String name;
  final String address;
  final LatLng location;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });

  factory Place.fromMapboxResponse(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['text'],
      address: json['place_name'],
      location: LatLng(json['center'][1], json['center'][0]),
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      location: LatLng.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location.toJson(),
    };
  }

  Place copyWith({
    String? id,
    String? name,
    String? address,
    LatLng? location,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [id, name, address, location];
}
