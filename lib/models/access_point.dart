import 'package:latlong2/latlong.dart';
import 'package:verifi/blocs/map/map_utils.dart';
import 'package:verifi/entities/access_point_entity.dart';
import 'package:verifi/models/models.dart';

/// A single WiFi access point.
class AccessPoint {
  final String id;
  final LatLng location;
  final Place? place;
  final num? distance;

  final String ssid;
  final String? password;
  final String submittedBy;
  final String? verifiedStatus;

  AccessPoint({
    required this.id,
    required this.location,
    this.place,
    this.distance,
    required this.ssid,
    this.password,
    required this.submittedBy,
    this.verifiedStatus,
  });

  AccessPoint.fromEntity(AccessPointEntity entity)
      : id = entity.id,
        location = LatLng(entity.location.latitude, entity.location.longitude),
        place = entity.place,
        distance = entity.distance,
        ssid = entity.ssid,
        password = entity.password,
        submittedBy = entity.submittedBy,
        verifiedStatus = MapUtils.getVeriFiedStatus(entity.lastValidated);

  @override
  String toString() => "AccessPoint: { id: $id, location: $location }";
}
