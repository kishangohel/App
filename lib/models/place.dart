import 'package:google_maps_webservice/places.dart';

class Place {
  final String placeId;
  final String name;
  Location? location;

  Place({
    required this.placeId,
    required this.name,
    this.location,
  });
}
