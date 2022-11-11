import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verifi/entities/access_point_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

class WifiRepository {
  final wifiMarkersCollection =
      FirebaseFirestore.instance.collection('AccessPoint');
  final geo = Geoflutterfire();

  Future<WifiDetails?> getWifiMarkerAtPlaceId(String placeId) {
    return wifiMarkersCollection
        .where('PlaceId', isEqualTo: placeId)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.length == 1) {
        return WifiDetails.fromEntity(
            AccessPointEntity.fromDocumentSnapshot(querySnapshot.docs.first));
      } else {
        return null;
      }
    });
  }

  Stream<List<DocumentSnapshot>> getWifiWithinRadiusStream(
    GeoFirePoint center,
    double radius,
  ) {
    return geo.collection(collectionRef: wifiMarkersCollection).within(
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
          latitude: place.location!.lat,
          longitude: place.location!.lng,
        )
        .data;
    return wifiMarkersCollection.add({
      "SSID": ssid,
      "Password": password ?? "",
      "PlaceId": place.placeId,
      "Name": place.name,
      "Location": geoFirePoint,
      "SubmittedBy": userId,
    });
  }

  Future<List<WifiDetails>> getNetworksSubmittedByUser(
    String userId,
  ) async {
    List<WifiDetails> networks = [];
    wifiMarkersCollection
        .where("SubmittedBy", isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      for (var networkDoc in querySnapshot.docs) {
        networks.add(
          WifiDetails.fromEntity(
            AccessPointEntity.fromDocumentSnapshot(networkDoc),
          ),
        );
      }
    });
    return networks;
  }

  Future<int> getNetworkContributionCount(String userId) async {
    final query = await wifiMarkersCollection
        .where("SubmittedBy", isEqualTo: userId)
        .count()
        .get();
    return query.count;
  }

  Future<int> getNetworkValidatedCount(String userId) async {
    final query = await wifiMarkersCollection
        .where("ValidatedBy", arrayContains: userId)
        .count()
        .get();
    return query.count;
  }

  Future<void> networkValidatedByUser(
    String accessPointId,
    String userId,
  ) async =>
      wifiMarkersCollection.doc(accessPointId).update({
        "ValidatedBy": FieldValue.arrayUnion([userId])
      });
}
