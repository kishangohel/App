import 'package:flutter/material.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:verifi/models/access_point.dart';
import 'package:verifi/screens/map_screen/widgets/access_point_marker.dart';

class AccessPointCluster extends ClusterDataBase {
  final Color color;

  AccessPointCluster({required this.color});

  AccessPointCluster.fromAccessPoint(AccessPoint accessPoint)
      : color = AccessPointMarker.colorFor(accessPoint);

  @override
  AccessPointCluster combine(covariant AccessPointCluster data) {
    var color = Colors.red;
    if (color == Colors.green || data.color == Colors.green) {
      color = Colors.green;
    } else if (color == Colors.orange || data.color == Colors.orange) {
      color = Colors.orange;
    }

    return AccessPointCluster(color: color);
  }
}
