import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/domain/access_point_cluster.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_cluster_sheet.dart';

class AccessPointClusterMarker extends ConsumerWidget {
  static const radius = 55.0;
  final LatLng location;
  final int count;
  final AccessPointCluster accessPointCluster;

  const AccessPointClusterMarker({
    required this.location,
    required this.count,
    required this.accessPointCluster,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(mapServiceProvider).moveMapToCenter(location);
        _showClusterSheet(context);
      },
      child: CustomPaint(
        painter: _AccessPointCirclePainter(
            context: context, cluster: accessPointCluster),
        size: const Size(radius, radius),
        child: Center(
          child: Text(
            count.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showClusterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AccessPointClusterSheet(
        accessPointCluster.accessPoints,
      ),
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _AccessPointCirclePainter extends CustomPainter {
  static const strokeWidth = 8.0;
  final BuildContext context;
  final AccessPointCluster cluster;

  _AccessPointCirclePainter({
    required this.context,
    required this.cluster,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;

    // Shadow
    final circlePath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(radius, radius), radius: size.width / 2));
    canvas.drawShadow(circlePath, const Color(0xff000000), 3, true);

    // Fill
    canvas.drawCircle(
      Offset(radius, radius),
      size.width / 2,
      Paint()
        ..color = Theme.of(context).colorScheme.surfaceVariant
        ..style = PaintingStyle.fill,
    );

    // Calculations for drawing the arcs
    final rect = const Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    var angle = pi;
    double radians;
    final multiplier = (pi * 2) / cluster.total;

    // VeriFied arc
    radians = cluster.verified * multiplier;
    paint.color = Colors.green;
    canvas.drawArc(rect, angle, radians, false, paint);
    angle = angle + radians;

    // UnVeriFied arc
    radians = cluster.unverified * multiplier;
    paint.color = Colors.orange;
    canvas.drawArc(rect, angle, radians, false, paint);
    angle = angle + radians;

    // Expired arc
    radians = cluster.expired * multiplier;
    paint.color = Colors.red;
    canvas.drawArc(rect, angle, radians, false, paint);
    angle = angle + radians;
  }

  @override
  bool shouldRepaint(_AccessPointCirclePainter oldDelegate) =>
      cluster != oldDelegate.cluster;
}
