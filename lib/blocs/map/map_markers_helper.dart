import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/image_utils.dart';
import 'package:verifi/blocs/map/map_utils.dart';
import 'package:verifi/models/models.dart';

class MapMarkersHelper {
  static Future<Map<String, BitmapDescriptor>> getMarkers() async => {
        "Expired": BitmapDescriptor.fromBytes(
          await ImageUtils.assetVectorToBytes(
            "assets/wifi_markers/wifi_icon_red.svg",
            40,
          ),
        ),
        "UnVeriFied": BitmapDescriptor.fromBytes(
          await ImageUtils.assetVectorToBytes(
            "assets/wifi_markers/wifi_icon_orange.svg",
            40,
          ),
        ),
        "VeriFied": BitmapDescriptor.fromBytes(
          await ImageUtils.assetVectorToBytes(
            "assets/wifi_markers/wifi_icon_green.svg",
            40,
          ),
        ),
      };

  static Future<Fluster<AccessPoint>> initClusterManager(
    List<AccessPoint> accessPoints,
    int minZoom,
    int maxZoom,
  ) async {
    return Fluster<AccessPoint>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 100,
      extent: 512,
      nodeSize: 64,
      points: accessPoints,
      createCluster: (
        BaseCluster? cluster,
        double? lng,
        double? lat,
      ) {
        if (cluster == null) {
          return AccessPoint(id: '');
        }
        return AccessPoint(
          id: cluster.id.toString(),
          isCluster: true,
          clusterLocation: LatLng(lat!, lng!),
          clusterId: cluster.id,
          pointsSize: cluster.pointsSize,
          childMarkerId: cluster.childMarkerId,
        );
      },
    );
  }

  static Future<List<AccessPoint>> getClusterMarkers(
    Fluster<AccessPoint> clusterManager,
    double currentZoom,
    Color clusterTextColor,
    int clusterWidth,
  ) async {
    final wifis = await Future.wait<AccessPoint>(
      clusterManager.clusters(
        [-180, -85, 180, 85],
        currentZoom.toInt(),
      ).map(
        (mapMarker) async {
          final isCluster = mapMarker.isCluster;
          if (isCluster != null && isCluster) {
            mapMarker.points = clusterManager.points(mapMarker.clusterId!);
            final clusterColor = await _getClusterColor(mapMarker.points!);
            mapMarker.icon = await _getClusterMarkerImage(
              mapMarker.pointsSize,
              clusterColor,
              clusterTextColor,
              clusterWidth,
            );
          }
          return mapMarker;
        },
      ),
    );
    return wifis;
  }

  static Future<BitmapDescriptor?> _getClusterMarkerImage(
    int? clusterSize,
    Color iconColor,
    Color textColor,
    int width,
  ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = iconColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width / 2;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    final image = await pictureRecorder
        .endRecording()
        .toImage(radius.toInt() * 2, radius.toInt() * 2);

    final ByteData? data = await image.toByteData(format: ImageByteFormat.png);
    return (data != null)
        ? BitmapDescriptor.fromBytes(data.buffer.asUint8List())
        : BitmapDescriptor.defaultMarker;
  }

  /// Determines the cluster color from the underlying points.
  ///
  /// If one or more VeriFied Wifi is present, returns [Colors.green].
  ///
  /// If no VeriFied Wifis are present, but one or more  UnVeriFied WiFis are
  /// present, returns [Colors.orange];
  ///
  /// If neither VeriFied nor UnVeriFied WiFis are present, return [Colors.red].
  static Future<Color> _getClusterColor(List<AccessPoint> accessPoints) async {
    Color color = Colors.red;
    for (AccessPoint ap in accessPoints) {
      final status = ap.wifiDetails!.verifiedStatus!;
      switch (status) {
        case "VeriFied":
          return Colors.green;
        case "UnVeriFied":
          color = Colors.orange;
      }
    }
    return color;
  }
}
