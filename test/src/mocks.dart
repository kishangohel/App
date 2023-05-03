import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/data/auto_connect_repository.dart';
import 'package:verifi/src/features/access_points/data/radar_search_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_screen_controller.dart';
import 'package:verifi/src/features/map/application/center_zoom_controller.dart';
import 'package:verifi/src/features/map/data/location_repository.dart';
import 'package:verifi/src/features/map/data/nearby_users_repository.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_layer_controller.dart';
import 'package:verifi/src/features/map/presentation/map_layers/user_layer/user_layer_controller.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

class AccessPointLayerControllerMock extends Mock
    implements AccessPointLayerController {}

class AccessPointMock extends Mock implements AccessPoint {}

class AccessPointRepositoryMock extends Mock implements AccessPointRepository {}

class CenterZoomControllerMock extends Mock implements CenterZoomController {}

class Listener<T> extends Mock {
  void call(T? previous, T next);
}

class MapControllerMock extends Mock implements MapController {
  final StreamController<MapEvent> _mapEventController;

  MapControllerMock() : _mapEventController = StreamController<MapEvent>();

  @override
  Stream<MapEvent> get mapEventStream => _mapEventController.stream;

  @override
  void dispose() {
    _mapEventController.close();
  }

  void emitMapEvent(MapEvent mapEvent) {
    _mapEventController.add(mapEvent);
  }

  Future<void> waitForEvents() {
    return _mapEventController.sink.close();
  }
}

// Repositories

class MockAccessPointRepository extends Mock implements AccessPointRepository {}

class MockAuthRepository extends Mock implements AuthenticationRepository {}

class MockAutoConnectRepository extends Mock implements AutoConnectRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockRadarSearchRepository extends Mock implements RadarSearchRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockSmsScreenController extends Mock implements SmsScreenController {}

class MockTwitterAuthProvider extends Mock implements TwitterAuthProvider {}

class MockUserCredential extends Mock implements UserCredential {}

class NearbyUsersRepositoryMock extends Mock implements NearbyUsersRepository {}

class ProfileRepositoryMock extends Mock implements ProfileRepository {}

class TickerProviderMock extends Mock implements TickerProvider {}

class UserLayerControllerMock extends Mock implements UserLayerController {}
