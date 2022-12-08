import 'dart:math';

import 'package:flutter/material.dart';
import 'package:verifi/models/access_point_cluster.dart';

class AccessPointClusterMarker extends StatelessWidget {
  static const radius = 55.0;
  final int count;
  final AccessPointCluster accessPointCluster;

  const AccessPointClusterMarker({
    required this.count,
    required this.accessPointCluster,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AccessPointCirclePainter(cluster: accessPointCluster),
      size: const Size(radius, radius),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _AccessPointCirclePainter extends CustomPainter {
  static const strokeWidth = 8.0;
  final AccessPointCluster cluster;

  _AccessPointCirclePainter({
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
        ..color = Colors.grey.shade300
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
