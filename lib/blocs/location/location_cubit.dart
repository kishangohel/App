import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

// Maintains current location
class LocationCubit extends HydratedCubit<LatLng?> {
  LocationCubit() : super(null);

  Future<void> getLocation() async {
    final locationAllowed = await Permission.locationWhenInUse.isGranted;
    if (locationAllowed) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      emit(LatLng(position.latitude, position.longitude));
    } else {
      emit(const LatLng(-1.0, -1.0));
    }
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
}
