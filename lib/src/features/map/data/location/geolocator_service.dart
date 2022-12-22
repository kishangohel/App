import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geolocator_service.g.dart';

/// Geolocator is wrapped in a service to make it simple to stub it in testing.
class GeolocatorService {
  final Ref ref;

  GeolocatorService(this.ref);

  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) =>
      Geolocator.getPositionStream(locationSettings: locationSettings);

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
}

@riverpod
GeolocatorService geolocatorService(GeolocatorServiceRef ref) {
  return GeolocatorService(ref);
}
