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
        .where('placeId', isEqualTo: placeId)
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
          field: 'location',
        );
  }

  Future<void> addWifiMarker(WifiDetails model) {
    Map<String, dynamic> wifiDetailsJson = model.toJson();
    // Transform location to GeoFirePoint data
    wifiDetailsJson['location'] = geo
        .point(
          latitude: model.location.latitude,
          longitude: model.location.longitude,
        )
        .data;
    return geo
        .collection(collectionRef: wifiMarkersCollection)
        .add(wifiDetailsJson);
  }

  Future<List<WifiDetails>> getNetworksSubmittedByUser(
    String userId,
  ) async {
    List<WifiDetails> networks = [];
    wifiMarkersCollection
        .where("submittedBy", isEqualTo: userId)
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
}
