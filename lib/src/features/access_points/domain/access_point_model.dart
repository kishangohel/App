import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:verifi/src/features/access_points/domain/place_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';

/// A single WiFi access point.
class AccessPoint {
  final String id;
  final LatLng location;
  final Place? place;

  final String ssid;
  final String? password;
  final String submittedBy;
  final VerifiedStatus verifiedStatus;

  AccessPoint({
    required this.id,
    required this.location,
    this.place,
    required this.ssid,
    this.password,
    required this.submittedBy,
    required this.verifiedStatus,
  });

  factory AccessPoint.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      throw Exception('Document does not exist');
    }
    final data = snapshot.data()! as Map<String, dynamic>;
    final location = data['Location']['geopoint'] as GeoPoint;
    final lastValidated = (data['LastValidated'] as Timestamp?)?.toDate();
    return AccessPoint(
      id: snapshot.id,
      location: LatLng(location.latitude, location.longitude),
      place: data['Feature'] == null ? null : Place.fromJson(data['Feature']),
      ssid: data['SSID'],
      password: data['Password'],
      submittedBy: data['SubmittedBy'],
      verifiedStatus: _getVeriFiedStatus(lastValidated),
    );
  }

  bool get isVerified => verifiedStatus.isVerified;

  String get verifiedStatusLabel => verifiedStatus.label;

  AccessPoint copyWith({
    String? id,
    LatLng? location,
    Place? place,
    String? ssid,
    String? password,
    String? submittedBy,
    VerifiedStatus? verifiedStatus,
  }) {
    return AccessPoint(
      id: id ?? this.id,
      location: location ?? this.location,
      place: place ?? this.place,
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      submittedBy: submittedBy ?? this.submittedBy,
      verifiedStatus: verifiedStatus ?? this.verifiedStatus,
    );
  }

  @override
  String toString() => "AccessPoint: { id: $id, location: $location }";

  static VerifiedStatus _getVeriFiedStatus(DateTime? lastValidated) {
    if (lastValidated == null) {
      return VerifiedStatus.unverified;
    }
    final lastValidatedDuration = _getLastValidatedDuration(lastValidated);
    // AP stays VeriFied for 30 days
    if (lastValidatedDuration < 30) {
      return VerifiedStatus.verified;
    } else {
      return VerifiedStatus.expired;
    }
  }

  static int _getLastValidatedDuration(DateTime lastValidated) {
    return DateTime.now().difference(lastValidated).inDays;
  }
}
