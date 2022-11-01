import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AccessPointEntity extends Equatable {
  final String id;
  final String? placeId;
  final String ssid;
  final String? password;
  final GeoPoint location;
  final double? distance;
  final String submittedBy;
  final DateTime lastValidated;

  const AccessPointEntity({
    required this.id,
    this.placeId,
    required this.ssid,
    this.password,
    required this.location,
    this.distance,
    required this.submittedBy,
    required this.lastValidated,
  });

  @override
  List<Object> get props => [id];

  @override
  String toString() =>
      "AccessPointEntity { id: $id, placeId: $placeId, ssid: $ssid }";

  static AccessPointEntity fromDocumentSnapshotWithDistance(
    DocumentSnapshot snapshot,
    double distance,
  ) {
    Map data = snapshot.data() as Map<String, dynamic>;
    return AccessPointEntity(
      id: snapshot.id,
      placeId: data['placeId'],
      password: data['password'],
      ssid: data['ssid'],
      distance: distance,
      location: data['location']['geopoint'],
      lastValidated: DateTime.parse(
        (data['lastValidated'] as Timestamp).toDate().toString(),
      ),
      submittedBy: data['submittedBy'],
    );
  }

  static AccessPointEntity fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return AccessPointEntity(
      id: snapshot.id,
      placeId: data['placeId'],
      password: data['password'],
      ssid: data['ssid'],
      location: data['location']['geopoint'],
      lastValidated: DateTime.parse(
        (data['lastValidated'] as Timestamp).toDate().toString(),
      ),
      submittedBy: data['submittedBy'],
    );
  }
}
