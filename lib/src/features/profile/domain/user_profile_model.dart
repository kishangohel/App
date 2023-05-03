import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'user_achievement_progress_model.dart';

/// A model for a user profile stored in Firestore.
class UserProfile extends Equatable {
  final String id;
  final String displayName;
  final int veriPoints;
  final Map<String, int> statistics;
  final Map<String, UserAchievementProgress> achievementsProgress;
  final LatLng? lastLocation;
  final DateTime? lastLocationUpdate;
  final bool hideOnMap;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.veriPoints,
    required this.statistics,
    required this.achievementsProgress,
    this.lastLocation,
    this.lastLocationUpdate,
    required this.hideOnMap,
  });

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

    final achievementsProgress =
        (data['AchievementsProgress'] as Map<String, dynamic>?)?.map(
              (key, value) {
                return MapEntry(
                  key,
                  UserAchievementProgress.fromFirestoreDocumentData(value),
                );
              },
            ) ??
            {};

    return UserProfile(
      id: snapshot.id,
      displayName: data['DisplayName'],
      hideOnMap: data['HideOnMap'] == true,
      statistics: Map.castFrom<String, dynamic, String, int>(
        data['Statistics'] ?? {},
      ),
      achievementsProgress: achievementsProgress,
      veriPoints: data['VeriPoints'] ?? 0,
      lastLocation: (location != null)
          ? LatLng(location.latitude, location.longitude)
          : null,
      lastLocationUpdate: lastLocationUpdate?.toDate(),
    );
  }

  UserAchievementProgress? getAchievementProgress(String achievementId) {
    return achievementsProgress[achievementId];
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    int? veriPoints,
    Map<String, int>? statistics,
    Map<String, UserAchievementProgress>? achievementsProgress,
    LatLng? lastLocation,
    DateTime? lastLocationUpdate,
    bool? hideOnMap,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      veriPoints: veriPoints ?? this.veriPoints,
      statistics: statistics ?? this.statistics,
      achievementsProgress: achievementsProgress ?? this.achievementsProgress,
      lastLocation: lastLocation ?? this.lastLocation,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      hideOnMap: hideOnMap ?? this.hideOnMap,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        hideOnMap,
        achievementsProgress,
        statistics,
        veriPoints,
        lastLocation,
        lastLocationUpdate,
      ];

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"],
      displayName: json["displayName"],
      veriPoints: json["veriPoints"],
      hideOnMap: json["hideOnMap"],
      lastLocation: json["lastLocation"] != null
          ? LatLng(
              json["lastLocation"]["latitude"],
              json["lastLocation"]["longitude"],
            )
          : null,
      lastLocationUpdate: json["lastLocationUpdate"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["lastLocationUpdate"])
          : null,
      achievementsProgress:
          (json["achievementsProgress"] as Map<String, dynamic>).map(
        (key, value) {
          return MapEntry(
            key,
            UserAchievementProgress.fromJson(value),
          );
        },
      ),
      statistics: json["statistics"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "displayName": displayName,
      "veriPoints": veriPoints,
      "hideOnMap": hideOnMap,
      "lastLocation": lastLocation != null
          ? {
              "latitude": lastLocation!.latitude,
              "longitude": lastLocation!.longitude,
            }
          : null,
      "lastLocationUpdate": lastLocationUpdate?.millisecondsSinceEpoch,
      "achievementsProgress": achievementsProgress.map(
        (key, value) {
          return MapEntry(
            key,
            value.toJson(),
          );
        },
      ),
      "statistics": statistics,
    };
  }
}
