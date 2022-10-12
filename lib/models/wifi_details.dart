import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/entities/access_point_entity.dart';

class WifiDetails {
  final String id;
  final String? placeId;
  final LatLng location;
  final String ssid;
  final String? password;
  final String submittedBy;
  final DateTime lastValidated;
  final num? distance;

  WifiDetails({
    required this.id,
    this.placeId,
    required this.location,
    required this.ssid,
    this.password,
    required this.submittedBy,
    required this.lastValidated,
    this.distance,
  });

  factory WifiDetails.fromEntity(AccessPointEntity entity) {
    return WifiDetails(
      id: entity.id,
      ssid: entity.ssid,
      password: entity.password,
      placeId: entity.placeId,
      location: LatLng(entity.location.latitude, entity.location.longitude),
      distance: entity.distance,
      submittedBy: entity.submittedBy,
      lastValidated: entity.lastValidated,
    );
  }

  factory WifiDetails.fromJson(Map<String, dynamic> json) {
    return WifiDetails(
      id: json['id'],
      placeId: json['placeId'],
      location: LatLng(json['location']['lat'], json['location']['lng']),
      ssid: json['ssid'],
      password: json['password'],
      submittedBy: json['submittedBy'],
      lastValidated: DateTime.fromMillisecondsSinceEpoch(json['lastValidated']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ssid': ssid,
        'password': password,
        // Deliberately not storing distance
        //'distance': distance,
        'placeId': placeId,
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
        'submittedBy': submittedBy,
        'lastValidated': lastValidated.millisecondsSinceEpoch,
      };
}
