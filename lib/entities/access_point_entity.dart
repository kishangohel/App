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
      "AccessPointEntity { id: $id, PlaceId: $placeId, SSID: $ssid }";

  static AccessPointEntity fromDocumentSnapshotWithDistance(
    DocumentSnapshot snapshot,
    double distance,
  ) {
    Map data = snapshot.data() as Map<String, dynamic>;
    return AccessPointEntity(
      id: snapshot.id,
      placeId: data['PlaceId'],
      password: data['Password'],
      ssid: data['SSID'],
      distance: distance,
      location: data['Location']['geopoint'],
      lastValidated: DateTime.parse(
        (data['LastValidated'] as Timestamp).toDate().toString(),
      ),
      submittedBy: data['SubmittedBy'],
    );
  }

  static AccessPointEntity fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return AccessPointEntity(
      id: snapshot.id,
      placeId: data['PlaceId'],
      password: data['Password'],
      ssid: data['SSID'],
      location: data['Location']['geopoint'],
      lastValidated: DateTime.parse(
        (data['LastValidated'] as Timestamp).toDate().toString(),
      ),
      submittedBy: data['SubmittedBy'],
    );
  }
}
