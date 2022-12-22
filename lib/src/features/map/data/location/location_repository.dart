import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/map/data/location/geolocator_service.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part 'location_repository.g.dart';

class LocationRepository {
  StreamSubscription<LatLng>? _locationStreamSubscription;
  final _locationStreamController = StreamController<LatLng>();
  late ProfileRepository _profileRepository;
  LatLng? _currentLocation;

  final LocationRepositoryRef ref;

  LocationRepository(this.ref) {
    _profileRepository = ref.read(profileRepositoryProvider);
    ref.onDispose(_dispose);
  }

  /// Begin listening for location updates.
  /// This should only be called after verifying that geolocation permissions
  /// have been granted.
  void initLocationStream() {
    _locationStreamSubscription?.cancel();
    _locationStreamSubscription = ref
        .read(geolocatorServiceProvider)
        .getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            // Only update location if the user has moved at least 50 meters
            distanceFilter: 50,
          ),
        )
        .map((position) => LatLng(position.latitude, position.longitude))
        .listen((location) {
      _currentLocation = location;
      _locationStreamController.add(location);
      _profileRepository.updateUserLocation(_currentLocation!);
    });
  }

  LatLng? get currentLocation => _currentLocation;

  Stream<LatLng> get locationStream => _locationStreamController.stream;

  Future<void> _dispose() async {
    await _locationStreamSubscription?.cancel();
    _locationStreamSubscription = null;
    await _locationStreamController.close();
  }
}

@Riverpod(keepAlive: true)
LocationRepository locationRepository(LocationRepositoryRef ref) =>
    LocationRepository(ref);

final locationStreamProvider = StreamProvider<LatLng>(
  (ref) => ref.watch(locationRepositoryProvider).locationStream,
);
