import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/access_point_report_model.dart';
import 'package:verifi/src/features/add_network/domain/new_access_point_model.dart';
import 'package:verifi/src/features/profile/domain/current_user_model.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

part 'access_point_repository.g.dart';

class AccessPointRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _accessPointCollection;
  late CollectionReference<Map<String, dynamic>> _accessPointReportCollection;
  final _geo = Geoflutterfire();

  AccessPointRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _accessPointCollection = _firestore.collection('AccessPoint');
    _accessPointReportCollection = _firestore.collection('AccessPointReport');
  }

  Stream<List<AccessPoint>> getAccessPointsWithinRadiusStream(
    LatLng center,
    double radius,
  ) {
    return _geo
        .collection(collectionRef: _accessPointCollection)
        .within(
          center: _geo.point(
            latitude: center.latitude,
            longitude: center.longitude,
          ),
          radius: radius,
          field: 'Location',
        )
        .map((docs) => docs.map(AccessPoint.fromDocumentSnapshot).toList());
  }

  Future<void> addAccessPoint({
    required String userId,
    required NewAccessPoint newAccessPoint,
  }) {
    return _accessPointCollection.add(
      newAccessPoint.toFirestoreData()
        ..addAll(
          {
            "SubmittedBy": userId,
            "SubmittedOn": Timestamp.now(),
          },
        ),
    );
  }

  Future<void> reportAccessPoint({
    required String userId,
    required AccessPointReport accessPointReport,
  }) {
    return _accessPointReportCollection.add(
      accessPointReport.toFirestoreData()
        ..addAll(
          {
            "SubmittedBy": userId,
            "SubmittedOn": Timestamp.now(),
          },
        ),
    );
  }

  Future<int> getNetworkContributionCount(String userId) async {
    final query = await _accessPointCollection
        .where("SubmittedBy", isEqualTo: userId)
        .count()
        .get();
    return query.count;
  }

  Future<int> getNetworkValidatedCount(String userId) async {
    final query = await _accessPointCollection
        .where("ValidatedBy", arrayContains: userId)
        .count()
        .get();
    return query.count;
  }

  Future<void> networkValidatedByUser(
    AccessPoint accessPoint,
    CurrentUser user,
  ) async =>
      _accessPointCollection.doc(accessPoint.id).update({
        "ValidatedBy": FieldValue.arrayUnion([user.id]),
        "LastValidated": Timestamp.now(),
      });
}

@Riverpod(keepAlive: true)
AccessPointRepository accessPointRepository(AccessPointRepositoryRef ref) {
  return AccessPointRepository();
}
