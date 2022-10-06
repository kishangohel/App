import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/blocs/wifi_utils.dart';
import 'package:verifi/models/wifi.dart';

class MapMarkersHelper {
  static Future<Map<String, BitmapDescriptor>> getMarkers(
          BuildContext context) async =>
      {
        "Expired": await _getMarker("red", context),
        "UnVeriFied": await _getMarker("orange", context),
        "VeriFied": await _getMarker("green", context),
      };

  static Future<BitmapDescriptor> _getMarker(
    String color,
    BuildContext context,
  ) async {
    final path = 'assets/wifi_markers/wifi_icon_$color.svg';
    String svgString = await rootBundle.loadString(path);
    final svgDrawableRoot = await svg.fromSvgString(svgString, path);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final width = 50 * devicePixelRatio;
    final height = 50 * devicePixelRatio;
    final picture = svgDrawableRoot.toPicture(size: Size(width, height));
    final image = await picture.toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // static Future<void> resetMarker(BuildContext context) async {
  //   await DefaultCacheManager().removeFile("map-marker.png");
  //   await initMarker(context);
  // }
  //
  // static Future<void> initMarker(BuildContext context) async {
  //   // If marker already in cache, do nothing
  //   final FileInfo? markerImage =
  //       await DefaultCacheManager().getFileFromCache("map-marker.png");
  //   if (markerImage != null) return;
  //
  //   // Transform icon into Uint8List
  //   const iconData = Icons.wifi;
  //   final pictureRecorder = PictureRecorder();
  //   final canvas = Canvas(pictureRecorder);
  //   final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   textPainter.text = TextSpan(
  //     text: String.fromCharCode(iconData.codePoint),
  //     style: TextStyle(
  //       letterSpacing: 0.0,
  //       fontSize: 60.0,
  //       fontFamily: iconData.fontFamily,
  //       color: Theme.of(context).colorScheme.primary,
  //     ),
  //   );
  //   textPainter.layout();
  //   textPainter.paint(canvas, const Offset(0.0, 0.0));
  //   final Picture pic = pictureRecorder.endRecording();
  //   final img = await pic.toImage(60, 60);
  //   final ByteData? byteData =
  //       await img.toByteData(format: ImageByteFormat.png);
  //   if (null != byteData) {
  //     await DefaultCacheManager().putFile(
  //       "map-marker.png",
  //       byteData.buffer.asUint8List(),
  //       fileExtension: "png",
  //     );
  //   }
  // }
  //

  static Future<Fluster<Wifi>> initClusterManager(
    List<Wifi> markers,
    int minZoom,
    int maxZoom,
  ) async {
    return Fluster<Wifi>(
        minZoom: minZoom,
        maxZoom: maxZoom,
        radius: 100,
        extent: 512,
        nodeSize: 64,
        points: markers,
        createCluster: (
          BaseCluster? cluster,
          double? lng,
          double? lat,
        ) {
          if (cluster == null) {
            return Wifi(id: '');
          }
          return Wifi(
            id: cluster.id.toString(),
            isCluster: true,
            clusterLocation: LatLng(lat!, lng!),
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
          );
        });
  }

  static Future<List<Wifi>> getClusterMarkers(
    Fluster<Wifi> clusterManager,
    double currentZoom,
    Color clusterTextColor,
    int clusterWidth,
  ) async {
    final wifis = await Future.wait<Wifi>(
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
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
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
  static Future<Color> _getClusterColor(List<Wifi> wifis) async {
    Color color = Colors.red;
    for (Wifi wifi in wifis) {
      final status = WifiUtils.getVeriFiedStatus(wifi);
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
