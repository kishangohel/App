import 'package:google_maps_flutter/google_maps_flutter.dart';

class Bounty {
  final LatLng location;
  final String submittedBy;
  final String placeId;
  final num bountyPoints;

  const Bounty(
    this.location,
    this.submittedBy,
    this.placeId,
    this.bountyPoints,
  );
}
