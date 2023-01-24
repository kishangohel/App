import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A model for a user profile stored in Firestore.
class UserProfile extends Equatable {
  final String id;
  final String displayName;
  final bool hideOnMap;
  final Map<String, int> statistics;
  final Map<String, int> achievementProgresses;
  final int? veriPoints;
  final LatLng? lastLocation;
  final DateTime? lastLocationUpdate;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.hideOnMap,
    required this.statistics,
    required this.achievementProgresses,
    this.veriPoints,
    this.lastLocation,
    this.lastLocationUpdate,
  });

  @override
  List<Object?> get props =>
      [id, displayName, hideOnMap, veriPoints, lastLocation];

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

    final Timestamp? lastLocationUpdate = data['LastLocationUpdate'];

    return UserProfile(
      id: snapshot.id,
      displayName: data['DisplayName'],
      hideOnMap: data['HideOnMap'] == true,
      statistics: Map.castFrom<String, dynamic, String, int>(
        data['Statistics'] ?? {},
      ),
      achievementProgresses: Map.castFrom<String, dynamic, String, int>(
        data['AchievementProgresses'] ?? {},
      ),
      veriPoints: data['VeriPoints'] ?? 0,
      lastLocation: (location != null)
          ? LatLng(location.latitude, location.longitude)
          : null,
      lastLocationUpdate: lastLocationUpdate?.toDate(),
    );
  }
}
