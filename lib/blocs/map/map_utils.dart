import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/blocs/map/map_markers_helper.dart';
import 'package:verifi/entities/access_point_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/widgets/app.dart';

class MapUtils {
  static Future<List<AccessPoint>> getNearbyAccessPointsWithPlaceDetails(
    WifiRepository wifiRepo,
    PlacesRepository placesRepo,
    GeoFirePoint location,
    double radius,
  ) async {
    List<DocumentSnapshot> docs =
        await wifiRepo.getWifiWithinRadiusStream(location, radius).first;
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
        DetailsResult? placeDetails = await placesRepo.getPlaceDetails(
          entry.value.placeId,
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

  static Future<List<AccessPoint>> transformToClusters(
    List<AccessPoint> accessPoints,
    double zoom,
    Map<String, BitmapDescriptor> wifiMarkers,
    Color clusterTextColor,
  ) async {
    final pixelRatio = MediaQuery.of(
      NavigationService.navigatorKey.currentContext!,
    ).devicePixelRatio;
    for (AccessPoint ap in accessPoints) {
      ap.icon = wifiMarkers[getVeriFiedStatus(ap)];
    }
    Fluster<AccessPoint> clusterManager =
        await MapMarkersHelper.initClusterManager(
      accessPoints,
      11, // min zoom
      19, // max zoom
    );
    final updatedMarkers = await MapMarkersHelper.getClusterMarkers(
      clusterManager,
      zoom,
      clusterTextColor,
      (30 * pixelRatio).toInt(),
    );
    return updatedMarkers;
  }

  static String getVeriFiedStatus(AccessPoint ap) {
    final lastValidatedDuration =
        DateTime.now().difference(ap.wifiDetails!.lastValidated).inDays;
    debugPrint("Last validated: $lastValidatedDuration days ago");
    if (lastValidatedDuration < 3) {
      return "VeriFied";
    } else {
      return "UnVeriFied";
    }
  }
}
