import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:verifi/blocs/wifi_utils.dart';
import 'package:verifi/models/wifi.dart';
import 'package:verifi/widgets/app.dart';

class MapMarkersHelper {
  static Future<Map<String, BitmapDescriptor>> getMarkers() async => {
        "Expired": await getBitmapFromAssetSvg(
          "assets/wifi_markers/wifi_icon_red.svg",
          40,
        ),
        "UnVeriFied": await getBitmapFromAssetSvg(
          "assets/wifi_markers/wifi_icon_orange.svg",
          40,
        ),
        "VeriFied": await getBitmapFromAssetSvg(
          "assets/wifi_markers/wifi_icon_green.svg",
          40,
        ),
      };

  static double? get devicePixelRatio {
    if (NavigationService.navigatorKey.currentContext != null) {
      return MediaQuery.of(
        NavigationService.navigatorKey.currentContext!,
      ).devicePixelRatio;
    } else {
      return 1.0;
    }
  }

  static Future<BitmapDescriptor> getBitmapFromAssetSvg(
    String path,
    double width,
  ) async {
    final bytes = await getBytesFromAssetSvg(path, width);
    return BitmapDescriptor.fromBytes(bytes);
  }

  static Future<Uint8List> getBytesFromAssetSvg(
    String path,
    double width,
  ) async {
    String svgString = await rootBundle.loadString(path);
    return _getBytesFromSvgString(svgString, width);
  }

  static Future<BitmapDescriptor> getBitmapFromRawSvg(
    String svgString,
    double width,
  ) async {
    final bytes = await getBytesFromRawSvg(svgString, width);
    return BitmapDescriptor.fromBytes(bytes);
  }

  static Future<Uint8List> getBytesFromRawSvg(
    String svgString,
    double width,
  ) async {
    return _getBytesFromSvgString(svgString, width);
  }

  static Future<Uint8List> _getBytesFromSvgString(
    String string,
    double width,
  ) async {
    final svgDrawableRoot = await svg.fromSvgString(string, string);
    width = width * (devicePixelRatio ?? 1.0);
    final height = width;
    final picture = svgDrawableRoot.toPicture(size: Size(width, height));
    // Don't want to cut off image, so rounding up
    final image = await picture.toImage(width.ceil(), height.ceil());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  static Future<BitmapDescriptor> getBitmapFromAssetPng(
    String path,
    double width,
  ) async {
    final bytes = await getBytesFromAssetPng(path, width);
    return BitmapDescriptor.fromBytes(bytes);
  }

  static Future<Uint8List> getBytesFromAssetPng(
    String path,
    double width,
  ) async {
    ByteData imageFile = await rootBundle.load(path);
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final imageUint8List = imageFile.buffer.asUint8List();
    final codec = await instantiateImageCodec(imageUint8List);
    final FrameInfo imageFI = await codec.getNextFrame();
    width = width * (devicePixelRatio ?? 1.0);
    final height = width;

    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, width, height),
      image: imageFI.image,
      filterQuality: FilterQuality.high,
    );

    final _image = await pictureRecorder.endRecording().toImage(
          // Making sure not to cut off image, so rounding up
          width.ceil(),
          height.ceil(),
        );
    final data = await _image.toByteData(format: ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  static Future<BitmapDescriptor> getBitmapFromRemotePng(
    String url,
    double width,
  ) async {}

  static Future<Uint8List> getBytesFromRemotePng(
    String url,
    double width,
  ) async {
    final resp = await get(Uri.parse(url));
    final image = img.decodeImage(resp.bodyBytes);
    final resized = img.copyResize(image!, width: width.ceil());
    return Uint8List.fromList(img.encodePng(resized));
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
      },
    );
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
