import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

class AccessPointRepository {
  final _accessPointCollection =
      FirebaseFirestore.instance.collection('AccessPoint');
  final geo = Geoflutterfire();

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
