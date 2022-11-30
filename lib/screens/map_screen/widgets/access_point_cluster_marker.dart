import 'package:flutter/material.dart';
import 'package:verifi/models/access_point_cluster.dart';

class AccessPointClusterMarker extends StatelessWidget {
  static const radius = 50.0;
  final int count;
  final AccessPointCluster accessPointCluster;

  const AccessPointClusterMarker({
    required this.count,
    required this.accessPointCluster,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: accessPointCluster.color,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
