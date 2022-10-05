import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/entities/wifi_entity.dart';

class WifiDetails {
  final String id;
  final String? placeId;
  final LatLng location;
  final String ssid;
  final String? password;
  //final String submittedBy;
  final num? distance;

  WifiDetails({
    required this.id,
    this.placeId,
    required this.location,
    required this.ssid,
    this.password,
    //this.submittedBy,
    this.distance,
  });

  factory WifiDetails.fromEntity(WifiEntity entity) {
    return WifiDetails(
      id: entity.id,
      ssid: entity.ssid,
      password: entity.password,
      placeId: entity.placeId,
      location: LatLng(entity.location.latitude, entity.location.longitude),
      distance: entity.distance,
    );
  }

  factory WifiDetails.fromJson(Map<String, dynamic> json) {
    return WifiDetails(
      id: json['id'],
      placeId: json['placeId'],
      location: LatLng(json['location']['lat'], json['location']['lng']),
      ssid: json['ssid'],
      password: json['password'],
      // Deliberately not storing distance
      // distance: json['distance'],
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
      };
}
