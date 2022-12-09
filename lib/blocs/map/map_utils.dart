import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verifi/entities/access_point_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';

class MapUtils {
  static Future<List<AccessPoint>> getNearbyAccessPoints({
    required AccessPointRepository accessPointRepo,
    required GeoFirePoint location,
    required double radiusInKm,
  }) async {
    List<DocumentSnapshot> docs = await accessPointRepo
        .getAccessPointsWithinRadiusStream(location, radiusInKm)
        .first;

    return docs.map((doc) {
      final GeoPoint docPoint = doc['Location']['geopoint'];
      final distance = double.parse(
        location
            .haversineDistance(lat: docPoint.latitude, lng: docPoint.longitude)
            .toStringAsFixed(1),
      );

      final accessPointEntity =
          AccessPointEntity.fromDocumentSnapshotWithDistance(
        doc,
        distance,
      );
      return AccessPoint.fromEntity(accessPointEntity);
    }).toList();
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
