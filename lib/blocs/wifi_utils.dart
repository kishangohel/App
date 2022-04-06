import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:verifi/blocs/map_markers_helper.dart';
import 'package:verifi/entities/wifi_entity.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/repositories/repositories.dart';

class WifiUtils {
  static Future<List<Wifi>> getNearbyWifiWithPlaceDetails(
    WifiRepository wifiRepo,
    PlacesRepository placesRepo,
    GeoFirePoint location,
    double radius,
  ) async {
    List<DocumentSnapshot> docs =
        await wifiRepo.getWifiWithinRadiusStream(location, radius).first;
    print("DOC LENGTH: ${docs.length}");
    // Set wifis to length of documents. This allows us to async update
    // List<Wifi> and keep the order of the documents returned by
    // distance.
    List<Wifi> wifis = [];
    final List<WifiDetails> wifiDetailsList = docs.map((doc) {
      final GeoPoint docPoint = doc['Location']['geopoint'];
      final distance = double.parse(
        location
            .haversineDistance(lat: docPoint.latitude, lng: docPoint.longitude)
            .toStringAsFixed(1),
      );

      final entity = WifiEntity.fromDocumentSnapshotWithDistance(doc, distance);
      return WifiDetails.fromEntity(entity);
    }).toList();

    // Execute placeDetails lookups in parallel and wait for all to complete
    // before returning wifis.
    //
    await Future.wait(
      wifiDetailsList.asMap().entries.map((entry) async {
        DetailsResult? placeDetails =
            await placesRepo.getPlaceDetails(entry.value.placeId, false);

        // Add new Wifi object to list. Keep Firestore order of documents.
        //
        wifis.add(Wifi(
          id: entry.value.id,
          wifiDetails: entry.value,
          placeDetails: placeDetails,
        ));
      }),
    );
    return wifis;
  }

  static Future<List<Wifi>> getNearbyWifi(
    WifiRepository repo,
    GeoFirePoint location,
    double radius,
  ) async {
    List<DocumentSnapshot> docs =
        await repo.getWifiWithinRadiusStream(location, radius).first;
    print("DOC LENGTH: ${docs.length}");
    // Set wifis to length of documents. This allows us to async update
    // List<Wifi> and keep the order of the documents returned by
    // distance.
    List<Wifi> wifis = [];
    final List<WifiDetails> wifiDetailsList = docs.map((doc) {
      final GeoPoint docPoint = doc['Location']['geopoint'];
      final distance = double.parse(
        location
            .haversineDistance(lat: docPoint.latitude, lng: docPoint.longitude)
            .toStringAsFixed(1),
      );

      final entity = WifiEntity.fromDocumentSnapshotWithDistance(doc, distance);
      return WifiDetails.fromEntity(entity);
    }).toList();
    wifiDetailsList.forEach((wifiDetail) =>
        wifis.add(Wifi(id: wifiDetail.id, wifiDetails: wifiDetail)));
    return wifis;
  }

  static Future<List<Wifi>> transformToClusters(
    List<Wifi> wifiMarkers,
    double zoom,
    BitmapDescriptor wifiMarker,
  ) async {
    for (Wifi marker in wifiMarkers) {
      marker.icon = wifiMarker;
    }
    Fluster<Wifi> clusterManager = await MapMarkersHelper.initClusterManager(
      wifiMarkers,
      11, // min zoom
      19, // max zoom
    );
    final updatedMarkers = await MapMarkersHelper.getClusterMarkers(
      clusterManager,
      zoom,
      Colors.green,
      Colors.white,
      120,
    );
    return updatedMarkers;
  }
}
