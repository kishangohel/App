import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Place extends Equatable {
  final String id;
  final String title;
  final String address;
  final LatLng location;

  const Place({
    required this.id,
    required this.title,
    required this.address,
    required this.location,
  });

  factory Place.fromMapboxResponse(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      title: json['text'],
      address: json['placeName'],
      location: LatLng.fromJson(json['center']),
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      title: json['title'],
      address: json['address'],
      location: LatLng.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'location': location.toJson(),
    };
  }

  Place copyWith({
    String? id,
    String? title,
    String? address,
    LatLng? location,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [id, title, address, location];
}
