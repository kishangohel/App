import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:verifi/blocs/map/map_markers_helper.dart';
import 'package:verifi/entities/access_point_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';
import 'package:verifi/utils/geoflutterfire/geoflutterfire.dart';
import 'package:verifi/widgets/app.dart';

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

  static Future<PlaceDetails> getPlaceDetails(
    BuildContext context,
    String placeId,
  ) async {
    final repo = context.read<PlaceRepository>();
    final details = await repo.getPlaceDetails(placeId, false);
    return details;
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
      ap.icon = wifiMarkers[ap.wifiDetails!.verifiedStatus];
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
