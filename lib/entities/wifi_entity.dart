import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WifiEntity extends Equatable {
  final String id;
  final String placeId;
  final String ssid;
  final String? password;
  final GeoPoint location;
  final double? distance;

  const WifiEntity({
    required this.id,
    required this.placeId,
    required this.ssid,
    this.password,
    required this.location,
    this.distance,
  });

  @override
  List<Object> get props => [id];

  @override
  String toString() {
    return '''WifiMarkerEntity {
  id: $id,
  PlaceId: $placeId,
  Password: $password,
  SSID: $ssid,
  Location: $location,
  Distance: $distance,
}''';
  }

  static WifiEntity fromDocumentSnapshotWithDistance(
    DocumentSnapshot snapshot,
    double distance,
  ) {
    return WifiEntity(
      id: snapshot.id,
      placeId: snapshot.get('PlaceId'),
      password: snapshot.get('Password'),
      ssid: snapshot.get('SSID'),
      distance: distance,
      location: snapshot.get('Location.geopoint'),
    );
  }

  static WifiEntity fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return WifiEntity(
      id: snapshot.id,
      placeId: snapshot.get('PlaceId'),
      password: snapshot.get('Password'),
      ssid: snapshot.get('SSID'),
      // position contains geohash and geopoint children
      location: snapshot.get('Location.geopoint'),
    );
  }
}
