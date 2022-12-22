import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/map/data/location/geolocator_service.dart';

class GeolocatorServiceMock extends Mock implements GeolocatorService {
  final StreamController<Position> _positionController;

  GeolocatorServiceMock() : _positionController = StreamController<Position>() {
    when(
      () => getPositionStream(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenAnswer((_) {
      return _positionController.stream;
    });
  }

  void changePosition({required double lat, required double lon}) {
    _positionController.add(
      Position(
        longitude: lon,
        latitude: lat,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 300.0,
        heading: 90,
        speed: 20,
        speedAccuracy: 1.0,
      ),
    );
  }

  // Wait for pending events to be consumed.
  Future<void> dispose() async {
    // If there are no listeners the close() will never return.
    if (_positionController.hasListener) {
      await _positionController.close();
    }
  }
}
