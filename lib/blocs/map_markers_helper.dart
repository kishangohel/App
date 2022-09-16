import 'dart:typed_data';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verifi/models/wifi.dart';

class MapMarkersHelper {
  static Future<void> resetMarker(BuildContext context) async {
    await DefaultCacheManager().removeFile("map-marker.png");
    await initMarker(context);
  }

  static Future<void> initMarker(BuildContext context) async {
    // If marker already in cache, do nothing
    final FileInfo? markerImage =
        await DefaultCacheManager().getFileFromCache("map-marker.png");
    if (markerImage != null) return;

    // Transform icon into Uint8List
    const iconData = Icons.wifi;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 60.0,
        fontFamily: iconData.fontFamily,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));
    final Picture pic = pictureRecorder.endRecording();
    final img = await pic.toImage(60, 60);
    final ByteData? byteData =
        await img.toByteData(format: ImageByteFormat.png);
    if (null != byteData) {
      await DefaultCacheManager().putFile(
        "map-marker.png",
        byteData.buffer.asUint8List(),
        fileExtension: "png",
      );
    }
  }

  static Future<BitmapDescriptor> getMarker() async {
    final FileInfo? markerImage =
        await DefaultCacheManager().getFileFromCache("map-marker.png");
    assert(markerImage != null);
    final Uint8List markerImageBytes = await markerImage!.file.readAsBytes();
    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

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
    Color clusterColor,
    Color clusterTextColor,
    int clusterWidth,
  ) async {
    final wifis = await Future.wait<Wifi>(clusterManager.clusters(
        [-180, -85, 180, 85], currentZoom.toInt()).map((mapMarker) async {
      final isCluster = mapMarker.isCluster;
      if (isCluster != null && isCluster) {
        mapMarker.icon = await _getClusterMarkerImage(
          mapMarker.pointsSize,
          clusterColor,
          clusterTextColor,
          clusterWidth,
        );
        mapMarker.points = clusterManager.points(mapMarker.clusterId!);
      }

      return mapMarker;
    }));
    return wifis;
  }

  static Future<BitmapDescriptor?> _getClusterMarkerImage(
    int? clusterSize,
    Color clusterColor,
    Color textColor,
    int width,
  ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor;
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
}
