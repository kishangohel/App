import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';

class AccessPointMarker extends Marker {
  final AccessPoint accessPoint;

  AccessPointMarker.fromAccessPoint(this.accessPoint)
      : super(
          width: 40,
          height: 40,
          point: accessPoint.location,
          builder: (context) {
            return Icon(
              Icons.wifi,
              size: 40,
              color: colorFor(accessPoint),
            );
          },
        );

  static Color colorFor(AccessPoint accessPoint) {
    switch (accessPoint.verifiedStatus) {
      case VerifiedStatus.expired:
        return Colors.red;
      case VerifiedStatus.unverified:
        return Colors.orange;
      case VerifiedStatus.verified:
        return Colors.green;
    }
  }
}
