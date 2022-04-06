import 'package:google_maps_flutter/google_maps_flutter.dart';

class FeedFilter {
  LatLng location;
  double distance;
  String? type;

  FeedFilter({
    this.location = const LatLng(-1.0, -1.0),
    this.distance = 20, // default 20 km
    this.type,
  });
}
