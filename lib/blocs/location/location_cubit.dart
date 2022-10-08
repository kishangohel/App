import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

// Maintains current location
class LocationCubit extends HydratedCubit<LatLng?> {
  late StreamSubscription<Position> _locationStream;
  LocationCubit() : super(null) {
    _locationStream = Geolocator.getPositionStream(
      // only update when user moves 10 or more meters
      locationSettings: const LocationSettings(distanceFilter: 10),
    ).listen((Position position) {
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
