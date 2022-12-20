import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/utils/geoflutterfire/geoflutterfire.dart';

import '../domain/place_model.dart';

part 'access_point_repository.g.dart';

class AccessPointRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _accessPointCollection;
  final geo = Geoflutterfire();

  AccessPointRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _accessPointCollection = _firestore.collection('AccessPoint');
  }

  Stream<List<DocumentSnapshot>> getAccessPointsWithinRadiusStream(
    GeoFirePoint center,
    double radius,
  ) {
    return geo.collection(collectionRef: _accessPointCollection).within(
          center: center,
          radius: radius,
          field: 'Location',
        );
  }

  Future<void> addNewAccessPoint(
    String ssid,
    String? password,
    Place place,
    String userId,
  ) {
    // Transform location to GeoFirePoint data
    final geoFirePoint = geo
        .point(
          latitude: place.location.latitude,
          longitude: place.location.longitude,
        )
        .data;
    return _accessPointCollection.add({
      "SSID": ssid,
      "Password": password ?? "",
      "PlaceId": place.id,
      "Name": place.title,
      "Location": geoFirePoint,
      "SubmittedBy": userId,
    });
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
    String accessPointId,
    String userId,
  ) async =>
      _accessPointCollection.doc(accessPointId).update({
        "ValidatedBy": FieldValue.arrayUnion([userId])
      });
}

@Riverpod(keepAlive: true)
AccessPointRepository accessPointRepository(AccessPointRepositoryRef ref) {
  return AccessPointRepository();
}