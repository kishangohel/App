import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:latlong2/latlong.dart';

import 'center_zoom_tween.dart';

class CenterZoomController {
  // Controls animation duration for velocity based animations. This is
  // multiplied with the velocity and the number of screen widths that will
  // pass by when translating.
  static const _translateDurationMultiplierInMs = 400;

  // The minimum animation duration with respect to the zoom change when using
  // velocity based animation.
  static const _zoomDurationBaseInMs = 100;

  // Controls animation duration for velocity based animations. This is
  // multiplied with the velocity and the zoom change.
  static const _zoomDurationMultiplierInMs = 175;

  // The maximum animation duration.
  static const _maximumAnimationDurationInMs = 2000;

  final TickerProvider _vsync;
  final MapController _mapController;
  AnimationController? _zoomController;
  CurvedAnimation? _animation;
  double? _durationMultiplier;
  CenterZoomTween? _centerZoomTween;
  static const distanceCalculator = Distance();

  CenterZoomController({
    required TickerProvider vsync,
    required MapController mapController,
    required AnimationOptions animationOptions,
  })  : _mapController = mapController,
        _vsync = vsync {
    this.animationOptions = animationOptions;
  }

  set animationOptions(AnimationOptions animationOptions) {
    _zoomController?.stop(canceled: false);
    _zoomController?.dispose();

    if (animationOptions is AnimationOptionsAnimate) {
      _zoomController = AnimationController(
        vsync: _vsync,
        duration: animationOptions.duration,
      )..addListener(_move);
      _animation = CurvedAnimation(
        parent: _zoomController!,
        curve: animationOptions.curve,
      );
      _durationMultiplier = animationOptions.velocity == null
          ? null
          : 1 / animationOptions.velocity!;
    } else if (animationOptions is AnimationOptionsNoAnimation) {
      _durationMultiplier = null;
      _zoomController = null;
      _animation = null;
    }
  }

  void dispose() {
    _zoomController?.stop(canceled: false);
    _zoomController?.dispose();
    _zoomController = null;
  }

  void moveTo(CenterZoom centerZoom) {
    if (_zoomController == null) {
      _mapController.move(
        centerZoom.center,
        centerZoom.zoom,
        id: CenterZoomAnimation.finished,
      );
    } else {
      _animateTo(centerZoom);
    }
  }

  void _animateTo(CenterZoom centerZoom) async {
    final startCenter = _mapController.center;
    final startZoom = _mapController.zoom;
    final begin = CenterZoom(center: startCenter, zoom: startZoom);
    final end = CenterZoom(center: centerZoom.center, zoom: centerZoom.zoom);
    _centerZoomTween = CenterZoomTween(begin: begin, end: end);
    _zoomController!.reset();

    if (_durationMultiplier != null) {
      _setDynamicDuration(_durationMultiplier!, begin, end);
    }

    _mapController.mapEventSink.add(
      MapEventMove(
        id: CenterZoomAnimation.started,
        source: MapEventSource.custom,
        center: startCenter,
        zoom: startZoom,
        targetCenter: centerZoom.center,
        targetZoom: centerZoom.zoom,
      ),
    );
    _zoomController!.forward().then((_) {
      _mapController.mapEventSink.add(
        MapEventMove(
          id: CenterZoomAnimation.finished,
          source: MapEventSource.custom,
          center: startCenter,
          zoom: startZoom,
          targetCenter: centerZoom.center,
          targetZoom: centerZoom.zoom,
        ),
      );
    });
  }

  // Calculates a duration considering the zoom change and the translation
  // distance. Calculating duration this way avoids slow animation for small
  // distances and likewise very fast animations over large distances. The
  // duration will be longer when the perceived movement distance is longer.
  void _setDynamicDuration(double velocity, CenterZoom begin, CenterZoom end) {
    final pixelsTranslated = _mapController
        .latLngToScreenPoint(begin.center)!
        .distanceTo(_mapController.latLngToScreenPoint(end.center)!);

    final screenSize =
        _mapController.latLngToScreenPoint(_mapController.bounds!.southEast)!;
    final screenSizeAverage = (screenSize.x + screenSize.y) / 2;
    final numberOfScreenWidthsTranslated = pixelsTranslated / screenSizeAverage;
    final translateDuration = (numberOfScreenWidthsTranslated *
            _translateDurationMultiplierInMs *
            velocity)
        .round();

    final zoomChange = (begin.zoom - end.zoom).abs();
    final zoomDuration = _zoomDurationBaseInMs +
        (velocity * _zoomDurationMultiplierInMs * zoomChange).round();

    _zoomController!.duration = Duration(
      milliseconds: min(
        max(translateDuration, zoomDuration),
        _maximumAnimationDurationInMs,
      ),
    );
  }

  void _move() {
    final centerZoom = _centerZoomTween!.evaluate(_animation!);
    _mapController.move(
      centerZoom.center,
      centerZoom.zoom,
      id: CenterZoomAnimation.inProgress,
    );
  }
}
