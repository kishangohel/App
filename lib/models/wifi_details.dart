import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/map/map.dart';
import 'package:verifi/entities/access_point_entity.dart';

class WifiDetails {
  final String id;
  final String? placeId;
  final LatLng location;
  final String ssid;
  final String? password;
  final String submittedBy;
  final String? verifiedStatus;
  final num? distance;

  WifiDetails({
    required this.id,
    this.placeId,
    required this.location,
    required this.ssid,
    this.password,
    required this.submittedBy,
    this.verifiedStatus,
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
      verifiedStatus: MapUtils.getVeriFiedStatus(entity.lastValidated),
    );
  }

  factory WifiDetails.fromJson(Map<String, dynamic> json) {
    return WifiDetails(
      id: json['ID'],
      placeId: json['PlaceId'],
      location: LatLng(json['Location']['lat'], json['Location']['lng']),
      ssid: json['SSID'],
      password: json['Password'],
      submittedBy: json['SubmittedBy'],
      verifiedStatus: json['VerifiedStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'ID': id,
        'SSID': ssid,
        'Password': password,
        // Deliberately not storing distance
        //'distance': distance,
        'PlaceId': placeId,
        'Location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
        'SubmittedBy': submittedBy,
        'VerifiedStatus': verifiedStatus,
      };
}
