import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:verifi/entities/feature_entity.dart';

class PlaceRepository {
  static const _mapboxUser = "bifrostyyy";

  // TODO: Replace with more restricted access token via dart-define
  static const _mapboxToken =
      'pk.eyJ1IjoiYmlmcm9zdHl5eSIsImEiOiJjbGIweHR0dGgwenVlM3dyejdheDc1aHBlIn0.rcH_qr3n01hJXmMsqaK-Rw';

  static const _distanceCalculator = Distance(calculator: Haversine());

  // We search for places within a square whose edges are this many meters from
  // the search point.
  static const _searchCenterOffsetMeters = 100;

  // The distance from the search center to the corners of the search box, used
  // for calculating the search box.
  static final _searchCenterOffsetMeters45Degrees =
      sqrt(2 * (pow(_searchCenterOffsetMeters, 2)));

  Future<List<FeatureEntity>> searchNearbyPlaces(
    LatLng location,
    String input,
    int radius,
  ) async {
    final uri = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$input.json',
      {
        'bbox': _searchBox(location),
        'proximity': '${location.latitude},${location.longitude}',
        'types': 'poi',
        'access_token': _mapboxToken,
        'user': _mapboxUser,
      },
    );
    final response = await http.get(uri);
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

    return (List.castFrom<dynamic, Map<String, dynamic>>(
            responseBody['features']))
        .map(_parseFeatureEntity)
        .toList();
  }

  String _searchBox(LatLng location) {
    final northWest = _distanceCalculator.offset(
      location,
      _searchCenterOffsetMeters45Degrees,
      -45,
    );
    final southEast = _distanceCalculator.offset(
      location,
      _searchCenterOffsetMeters45Degrees,
      135,
    );

    return '${northWest.longitude},${southEast.latitude},${southEast.longitude},${northWest.latitude}';
  }

  FeatureEntity _parseFeatureEntity(Map<String, dynamic> json) {
    return FeatureEntity(
      id: json['id'],
      text: json['text'],
      placeName: json['place_name'],
      center: LatLng(json['center'][1], json['center'][0]),
    );
  }
}
