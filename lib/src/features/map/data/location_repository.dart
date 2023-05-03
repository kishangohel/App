import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_generated/location_repository.g.dart';

class LocationRepository {
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<bool> isLocationPermitted() async {
    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return false;
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return true;
    }
  }

  Future<LatLng?> get currentLocation async {
    if (false == await isLocationPermitted() ||
        false == await isLocationServiceEnabled()) {
      return null;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 3),
      );
      return LatLng(position.latitude, position.longitude);
    } on Exception {
      return null;
    }
  }

  Stream<LatLng> userLocationUpdates() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(distanceFilter: 50),
      ).map(
        (Position position) => LatLng(position.latitude, position.longitude),
      );

  Stream<bool> locationServicesStatusUpdates() =>
      Geolocator.getServiceStatusStream().map(
        (event) => event == ServiceStatus.enabled,
      );
}

@Riverpod(keepAlive: true)
LocationRepository locationRepository(LocationRepositoryRef ref) {
  return LocationRepository();
}
