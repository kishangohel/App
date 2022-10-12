import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/widgets/app.dart';

/// The type of image.
/// Vector images are handled by SVG library.
/// Non-vector images (png, jpeg, etc.) are handled by [Image] library.
enum ImageType {
  /// A standard image format supported by [Image]
  /// (jpeg, png, bmp, gif, etc.)
  image,

  /// An SVG file.
  vector,
}

/// A set of utilities to manipulate standard images and vector images.
/// All methods should be static.
class ImageUtils {
  /// Get device pixel ratio.
  ///
  /// This should only be called if [MaterialApp] has been
  static double get devicePixelRatio {
    if (NavigationService.navigatorKey.currentContext != null) {
      return MediaQuery.of(
        NavigationService.navigatorKey.currentContext!,
      ).devicePixelRatio;
    } else {
      return 1.0;
    }
  }

  /// Creates an [ImageProvider] based on the mime type of the remote file.
  /// If the mime type is not a supported image type, this returns null.
  static ImageProvider? getImageProvider(String url) {
    final type = getRemoteImageType(url);
    switch (type) {
      case ImageType.image:
        return CachedNetworkImageProvider(url);
      case ImageType.vector:
        return SvgProvider(url, source: SvgSource.network);
      default:
        return null;
    }
  }

  /// Determine the mime type of a remote file.
  /// This uses the file extension to determine the type.
  /// If mime type is not supported or can't be determined, this returns null.
  static ImageType? getRemoteImageType(String url) {
    final type = lookupMimeType(url);
    switch (type) {
      case null:
        return null;
      case 'image/jpeg':
      case 'image/png':
      case 'image/bmp':
      case 'image/webp':
      case 'image/gif':
        return ImageType.image;
      case 'image/svg+xml':
        return ImageType.vector;
      default:
        return null;
    }
  }

  /// Transform the bytes of an image into a Base64 encoded string.
  ///
  /// Supports both standard images (png, jpeg, etc.) and SVG vector images.
  static Future<Uint8List?> encodeImage(String url) async {
    final type = getRemoteImageType(url);
    Uint8List? bytes;
    switch (type) {
      case ImageType.image:
        bytes = await _remoteImageToBytes(url, 60.0);
        break;
      case ImageType.vector:
        bytes = await _remoteVectorToBytes(url, 60.0);
        break;
      default:
        return null;
    }
    return bytes;
  }

  /// Requests a remote image [url] and converts it to a [BitmapDescriptor]
  /// that is [width] wide.
  ///
  /// Height is determined by aspect ratio.
  ///
  /// [url] must point to an image supported by the [Image] library
  /// (png, jpeg, gif, etc.). If the image is not supported by the [Image]
  /// library, an [UnsupportedError] is thrown.
  ///
  /// [width] is used to resize the image while keeping the aspect ratio.
  static Future<Uint8List> _remoteImageToBytes(String url, double width) async {
    if (ImageType.image != getRemoteImageType(url)) {
      throw UnsupportedError('Invalid file type');
    }
    final resp = await get(Uri.parse(url));
    width = devicePixelRatio * width;

    final image = img.decodeImage(resp.bodyBytes);
    if (image == null) {
      throw UnsupportedError('Invalid file type');
    }
    final resized = img.copyResize(image, width: width.toInt());
    return Uint8List.fromList(
      // Doesn't matter if original image is not a png
      img.encodePng(resized),
    );
  }

  static Future<Uint8List> _remoteVectorToBytes(
    String url,
    double width,
  ) async {
    if (ImageType.vector != getRemoteImageType(url)) {
      throw UnsupportedError('Invalid file type');
    }
    final resp = await get(Uri.parse(url));
    final drawableRoot = await svg.fromSvgBytes(resp.bodyBytes, url);
    return _drawableRootToBytes(drawableRoot, width);
  }

  static Future<Uint8List> assetVectorToBytes(String path, double width) async {
    final svgString = await rootBundle.loadString(path);
    final drawableRoot = await svg.fromSvgString(svgString, path);
    return _drawableRootToBytes(drawableRoot, width);
  }

  static Future<Uint8List> rawVectorToBytes(
    String svgString,
    double width,
  ) async {
    final drawableRoot = await svg.fromSvgString(svgString, svgString);
    return _drawableRootToBytes(drawableRoot, 60.0);
  }

  static Future<Uint8List> _drawableRootToBytes(
    DrawableRoot drawableRoot,
    double width,
  ) async {
    width = width * devicePixelRatio;
    final pic = drawableRoot.toPicture(size: Size(width, width));
    final image = await pic.toImage(width.toInt(), width.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }
}
