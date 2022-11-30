import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/access_point.dart';

class AccessPointMarker extends Marker {
  final AccessPoint accessPoint;

  AccessPointMarker.fromAccessPoint(this.accessPoint)
      : super(
          width: 40,
          height: 40,
          point: accessPoint.location ?? LatLng(-1.0, -1.0),
          builder: (context) {
            return Icon(
              Icons.wifi,
              size: 40,
              color: colorFor(accessPoint),
            );
          },
        );

  static Color colorFor(AccessPoint accessPoint) {
    final verifiedStatus = accessPoint.wifiDetails.verifiedStatus;
    switch (verifiedStatus) {
      case "Expired":
        return Colors.red;
      case "UnVeriFied":
        return Colors.orange;
      case "VeriFied":
        return Colors.green;
      default:
        throw "Unexpected verified status: $verifiedStatus";
    }
  }
}
