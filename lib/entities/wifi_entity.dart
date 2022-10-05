import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WifiEntity extends Equatable {
  final String id;
  final String? placeId;
  final String ssid;
  final String? password;
  final GeoPoint location;
  final double? distance;

  const WifiEntity({
    required this.id,
    this.placeId,
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
    Map data = snapshot.data() as Map<String, dynamic>;
    return WifiEntity(
      id: snapshot.id,
      placeId: data['placeId'],
      password: data['password'],
      ssid: data['SSID'],
      distance: distance,
      location: data['Location']['geopoint'],
    );
  }

  static WifiEntity fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return WifiEntity(
      id: snapshot.id,
      placeId: data['PlaceId'],
      password: data['Password'],
      ssid: data['SSID'],
      // position contains geohash and geopoint children
      location: data['Location']['geopoint'],
    );
  }
}
