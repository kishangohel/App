import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:verifi/src/features/map/data/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/geolocation_service.g.dart';

class GeolocationService {
  final Ref ref;
  GeolocationService(this.ref) {
    _init();
  }

  /// Immediately start position stream if location services are enabled.
  void _init() {
    ref.read(locationRepositoryProvider).locationServicesStatusUpdates().listen(
      (locationServicesEnabled) {
        if (locationServicesEnabled) {
          userLocationUpdates();
        } else {
          _geolocationStreamSubscription?.cancel();
          _geolocationStreamSubscription = null;
        }
      },
    );
  }

  StreamSubscription<LatLng>? _geolocationStreamSubscription;
  final StreamController<LatLng> _geolocationStreamController =
      StreamController<LatLng>();

  Stream<LatLng> get locationStream => _geolocationStreamController.stream;

  /// Create a stream of location updates.
  Future<void> userLocationUpdates() async {
    if (false ==
        await ref.read(locationRepositoryProvider).isLocationPermitted()) {
      debugPrint("Geolocation stream not started. Permission not granted.");
      return;
    }
    _geolocationStreamSubscription = ref
        .read(locationRepositoryProvider)
        .userLocationUpdates()
        .listen((location) {
      _geolocationStreamController.add(location);
      // if signed in, update user location
      if (ref.read(firebaseAuthProvider).currentUser != null) {
        ref.read(profileRepositoryProvider).updateUserLocation(location);
      }
    });
  }

  void dispose() {
    _geolocationStreamSubscription?.cancel();
    _geolocationStreamSubscription = null;
    _geolocationStreamController.close();
  }
}

@riverpod
GeolocationService geolocationService(GeolocationServiceRef ref) {
  final geolocationService = GeolocationService(ref);
  ref.onDispose(() => geolocationService.dispose());
  return geolocationService;
}

@riverpod
Stream<LatLng> currentLocation(CurrentLocationRef ref) {
  return ref.watch(geolocationServiceProvider).locationStream;
}
