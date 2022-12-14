import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A model for a user profile stored in Firestore.
class UserProfile extends Equatable {
  final String id;
  final String displayName;
  final int? veriPoints;
  final LatLng? lastLocation;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.veriPoints,
    this.lastLocation,
  });

  @override
  List<Object?> get props => [id, displayName];

  /// Convert the Firestore snapshot into a [UserProfile].
  factory UserProfile.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      throw Exception('UserProfile does not exist');
    }
    final data = snapshot.data()! as Map<String, dynamic>;
    GeoPoint? location;
    if (data['LastLocation'] != null) {
      location = data['LastLocation']['geopoint'] as GeoPoint;
    }
    return UserProfile(
      id: snapshot.id,
      displayName: data['DisplayName'],
      veriPoints: data['VeriPoints'] ?? 0,
      lastLocation: (location != null)
          ? LatLng(location.latitude, location.longitude)
          : null,
    );
  }
}
