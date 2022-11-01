import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

// Maintains current location
class LocationCubit extends HydratedCubit<Position?> {
  late StreamSubscription<Position> _locationStream;

  LocationCubit() : super(null) {
    _locationStream = Geolocator.getPositionStream(
      // only update when user moves 50 or more meters
      locationSettings: const LocationSettings(distanceFilter: 50),
    ).listen((Position position) async {
      emit(position);
    });
  }

  @override
  Position? fromJson(Map<String, dynamic> json) {
    return Position.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(Position? state) {
    if (state != null) {
      return state.toJson();
    }
    return null;
  }

  @override
  Future<void> close() async {
    _locationStream.cancel();
    super.close();
  }
}
