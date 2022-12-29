import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/place_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';

// ignore: subtype_of_sealed_class
class DocumentSnapshotMock extends Mock implements DocumentSnapshot {
  final String idOverride;
  final Map<String, dynamic> dataOverride;
  final bool existsOverride;

  DocumentSnapshotMock({
    required this.idOverride,
    required this.dataOverride,
    required this.existsOverride,
  });

  @override
  String get id => idOverride;

  @override
  Object? data() => dataOverride;

  @override
  bool get exists => existsOverride;
}

void main() {
  AccessPoint createAccessPoint({
    required String id,
    required bool exists,
    required Map<String, dynamic> data,
  }) =>
      AccessPoint.fromDocumentSnapshot(
        DocumentSnapshotMock(
          idOverride: id,
          dataOverride: data,
          existsOverride: exists,
        ),
      );

  group(AccessPoint, () {
    test('DocumentSnapshot does not exist', () {
      expect(
        () => createAccessPoint(
          id: 'abc123',
          exists: false,
          data: {},
        ),
        throwsException,
      );
    });

    test('DocumentSnapshot exists', () {
      final accessPoint = createAccessPoint(
        id: 'abc123',
        exists: true,
        data: {
          'Location': {
            'geopoint': const GeoPoint(1.0, 2.0),
          },
          'SSID': 'ssid123',
          'SubmittedBy': 'userId123',
        },
      );
      expect(accessPoint.id, 'abc123');
      expect(accessPoint.location, LatLng(1.0, 2.0));
      expect(accessPoint.place, isNull);
      expect(accessPoint.ssid, 'ssid123');
      expect(accessPoint.submittedBy, 'userId123');
      expect(accessPoint.toString(),
          'AccessPoint: { id: abc123, location: LatLng(latitude:1.0, longitude:2.0) }');
    });

    test('DocumentSnapshot exists and validated recently', () {
      final accessPoint = createAccessPoint(
        id: 'abc123',
        exists: true,
        data: {
          'Location': {
            'geopoint': const GeoPoint(1.0, 2.0),
          },
          'LastValidated': Timestamp.now(),
          'SSID': 'ssid123',
          'SubmittedBy': 'userId123',
        },
      );
      expect(accessPoint.verifiedStatus, VerifiedStatus.verified);
      expect(accessPoint.isVerified, isTrue);
      expect(accessPoint.verifiedStatusLabel, 'VeriFied');
    });

    test('DocumentSnapshot exists and validated > 30 days ago', () {
      final accessPoint = createAccessPoint(
        id: 'abc123',
        exists: true,
        data: {
          'Location': {
            'geopoint': const GeoPoint(1.0, 2.0),
          },
          'LastValidated': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 31)),
          ),
          'SSID': 'ssid123',
          'SubmittedBy': 'userId123',
        },
      );
      expect(accessPoint.verifiedStatus, VerifiedStatus.expired);
      expect(accessPoint.isVerified, isFalse);
      expect(accessPoint.verifiedStatusLabel, 'Expired');
    });

    test('DocumentSnapshot exists, never validated', () {
      final accessPoint = createAccessPoint(
        id: 'abc123',
        exists: true,
        data: {
          'Location': {
            'geopoint': const GeoPoint(1.0, 2.0),
          },
          'LastValidated': null,
          'SSID': 'ssid123',
          'SubmittedBy': 'userId123',
        },
      );
      expect(accessPoint.verifiedStatus, VerifiedStatus.unverified);
      expect(accessPoint.isVerified, isFalse);
      expect(accessPoint.verifiedStatusLabel, 'UnVeriFied');
    });

    test('DocumentSnapshot exists, has a Place', () {
      final accessPoint = createAccessPoint(
        id: 'abc123',
        exists: true,
        data: {
          'Location': {
            'geopoint': const GeoPoint(1.0, 2.0),
          },
          'Feature': {
            'id': 'placeId123',
            'title': 'placeTitle123',
            'address': 'placeAddress123',
            'location': LatLng(2, 3).toJson(),
          },
          'SSID': 'ssid123',
          'SubmittedBy': 'userId123',
        },
      );
      expect(
        accessPoint.place,
        Place(
          id: 'placeId123',
          title: 'placeTitle123',
          address: 'placeAddress123',
          location: LatLng(2, 3),
        ),
      );
    });
  });
}
