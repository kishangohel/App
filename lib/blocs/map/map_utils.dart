import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verifi/entities/access_point_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

class MapUtils {
  static Future<List<AccessPoint>> getNearbyAccessPointsWithPlaceDetails(
    WifiRepository wifiRepository,
    PlaceRepository placeRepository,
    GeoFirePoint location,
    double radius,
  ) async {
    List<DocumentSnapshot> docs =
        await wifiRepository.getWifiWithinRadiusStream(location, radius).first;
    // Set wifis to length of documents. This allows us to async update
    // List<Wifi> and keep the order of the documents returned by
    // distance.
    List<AccessPoint> accessPoints = [];
    final List<WifiDetails> wifiDetailsList = docs.map((doc) {
      final GeoPoint docPoint = doc['Location']['geopoint'];
      final distance = double.parse(
        location
            .haversineDistance(lat: docPoint.latitude, lng: docPoint.longitude)
            .toStringAsFixed(1),
      );

      final entity = AccessPointEntity.fromDocumentSnapshotWithDistance(
        doc,
        distance,
      );
      return WifiDetails.fromEntity(entity);
    }).toList();

    // Execute placeDetails lookups in parallel and wait for all to complete
    // before returning wifis.
    await Future.wait(
      wifiDetailsList.asMap().entries.map((entry) async {
        final placeDetails = await placeRepository.getPlaceDetails(
          entry.value.placeId!,
          false,
        );
        // Add new Wifi object to list. Keep Firestore order of documents.
        accessPoints.add(AccessPoint(
          id: entry.value.id,
          wifiDetails: entry.value,
          placeDetails: placeDetails,
        ));
      }),
    );
    return accessPoints;
  }

  static Future<List<AccessPoint>> getNearbyAccessPoints(
    WifiRepository repo,
    GeoFirePoint location,
    double radius,
  ) async {
    List<DocumentSnapshot> docs =
        await repo.getWifiWithinRadiusStream(location, radius).first;

    // Set wifis to length of documents. This allows us to async update
    // List<Wifi> and keep the order of the documents returned by
    // distance.
    List<AccessPoint> accessPoints = [];
    final List<WifiDetails> wifiDetailsList = docs.map((doc) {
      final GeoPoint docPoint = doc['Location']['geopoint'];
      final distance = double.parse(
        location
            .haversineDistance(lat: docPoint.latitude, lng: docPoint.longitude)
            .toStringAsFixed(1),
      );

      final entity = AccessPointEntity.fromDocumentSnapshotWithDistance(
        doc,
        distance,
      );
      return WifiDetails.fromEntity(entity);
    }).toList();
    for (var wifiDetail in wifiDetailsList) {
      accessPoints.add(AccessPoint(id: wifiDetail.id, wifiDetails: wifiDetail));
    }
    return accessPoints;
  }

  static String getVeriFiedStatus(DateTime? lastValidated) {
    if (lastValidated == null) {
      return "UnVeriFied";
    }
    final lastValidatedDuration = getLastValidatedDuration(lastValidated);
    // AP stays VeriFied for 30 days
    if (lastValidatedDuration < 30) {
      return "VeriFied";
    } else {
      return "UnVeriFied";
    }
  }

  static int getLastValidatedDuration(DateTime lastValidated) {
    return DateTime.now().difference(lastValidated).inDays;
  }
}
