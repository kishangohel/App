import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:verifi/repositories/repositories.dart';

// Maintains current location
class LocationCubit extends HydratedCubit<LatLng?> {
  final UserLocationRepository _userLocationRepository;
  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<Position> _locationStream;

  LocationCubit(
    this._userLocationRepository,
    this._authenticationRepository,
  ) : super(null) {
    _locationStream = Geolocator.getPositionStream(
      // only update when user moves 50 or more meters
      locationSettings: const LocationSettings(distanceFilter: 50),
    ).listen((Position position) async {
      // If user is logged in, upload location to Firestore
      final userId = _authenticationRepository.currentUser?.uid;
      if (userId != null) {
        await _userLocationRepository.updateUserLocation(
          userId,
          GeoPoint(position.latitude, position.longitude),
        );
      }
      emit(LatLng(position.latitude, position.longitude));
    });
  }

  @override
  LatLng? fromJson(Map<String, dynamic> json) {
    if (json.containsKey('lat') && json.containsKey('lng')) {
      return LatLng(json['lat'], json['lng']);
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(LatLng? state) {
    if (state != null) {
      return {
        'lat': state.latitude,
        'lng': state.longitude,
      };
    }
    return null;
  }

  @override
  Future<void> close() async {
    _locationStream.cancel();
    super.close();
  }
}
