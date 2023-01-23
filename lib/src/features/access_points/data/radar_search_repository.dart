import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_radar/flutter_radar.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:verifi/src/features/access_points/domain/radar_address_model.dart';

part 'radar_search_repository.g.dart';

class RadarSearchRepository {
  static const testRadarKey =
      "prj_test_pk_e62a33780de0713920c980d1d2b72e0093e5c0c9";

  /// Retrieve a list of nearby points of interest using Radar Search API.
  ///
  Future<List<RadarAddress>> searchNearbyPlaces(
    LatLng location,
    String input,
  ) async {
    try {
      final resp = await http.get(
        Uri(
          scheme: "https",
          host: "api.radar.io",
          path: "v1/search/autocomplete",
          queryParameters: {
            "query": input,
            "near": "${location.latitude},${location.longitude}",
            "limit": "5",
          },
        ),
        headers: {
          "Authorization": RadarSearchRepository.testRadarKey,
        },
      );
      final respBody = json.decode(resp.body) as Map<String, dynamic>;
      final addresses = respBody['addresses'] as List<dynamic>;
      final actualAddresses = addresses
          .map((address) => Map<String, dynamic>.from(address))
          .where((address) =>
              (address['distance'] != null) &&
              (address['distance'] < 100) &&
              (address['placeLabel'] != null) &&
              (address['formattedAddress'] != null))
          .map((address) => RadarAddress.fromRadarAutocompleteResponse(address))
          .toList();
      return actualAddresses;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
RadarSearchRepository radarSearchRepository(RadarSearchRepositoryRef ref) {
  Radar.initialize(RadarSearchRepository.testRadarKey);
  return RadarSearchRepository();
}
