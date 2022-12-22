import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/map/application/center_zoom_controller.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/data/nearby_users/nearby_users_repository.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_layer_controller.dart';
import 'package:verifi/src/features/map/presentation/map_layers/user_layer/user_layer_controller.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../test_helper/register_fallbacks.dart';

class MapControllerMock extends Mock implements MapController {
  final StreamController<MapEvent> _mapEventController;

  MapControllerMock() : _mapEventController = StreamController<MapEvent>();

  void emitMapEvent(MapEvent mapEvent) {
    _mapEventController.add(mapEvent);
  }

  @override
  Stream<MapEvent> get mapEventStream => _mapEventController.stream;

  Future<void> waitForEvents() {
    return _mapEventController.sink.close();
  }

  @override
  void dispose() {
    _mapEventController.close();
  }
}

class AccessPointLayerControllerMock extends Mock
    implements AccessPointLayerController {}

class UserLayerControllerMock extends Mock implements UserLayerController {}

class TickerProviderMock extends Mock implements TickerProvider {}

class CenterZoomControllerMock extends Mock implements CenterZoomController {}

class AccessPointRepositoryMock extends Mock implements AccessPointRepository {}

class NearbyUsersRepositoryMock extends Mock implements NearbyUsersRepository {}

class AccessPointMock extends Mock implements AccessPoint {}

class UserProfileMock extends Mock implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbacks();
  });

  group(MapService, () {
    late MapControllerMock mapControllerMock;
    late MapService mapService;
    late UserLayerControllerMock userLayerControllerMock;
    late AccessPointLayerControllerMock accessPointLayerControllerMock;
    late AccessPointRepositoryMock accessPointRepositoryMock;
    late NearbyUsersRepositoryMock nearbyUsersRepositoryMock;

    void makeProviderMocks() {
      mapControllerMock = MapControllerMock();
      userLayerControllerMock = UserLayerControllerMock();
      accessPointLayerControllerMock = AccessPointLayerControllerMock();
      accessPointRepositoryMock = AccessPointRepositoryMock();
      nearbyUsersRepositoryMock = NearbyUsersRepositoryMock();
    }

    ProviderContainer makeContainerWithMapService() {
      // Create container
      final container = ProviderContainer(
        overrides: [
          userLayerControllerProvider
              .overrideWith(() => userLayerControllerMock),
          accessPointLayerControllerProvider
              .overrideWith(() => accessPointLayerControllerMock),
          accessPointLayerControllerProvider
              .overrideWith(() => accessPointLayerControllerMock),
          nearbyUsersRepositoryProvider
              .overrideWith((ref) => nearbyUsersRepositoryMock),
          accessPointRepositoryProvider
              .overrideWith((ref) => accessPointRepositoryMock),
          mapServiceProvider.overrideWith((ref) {
            mapService = MapService(ref, mapController: mapControllerMock);
            return mapService;
          })
        ],
      );
      // Trigger the lazy load.
      container.read(mapServiceProvider);

      addTearDown(container.dispose);
      return container;
    }

    test('updates users and access points when updateMap is called', () async {
      makeProviderMocks();
      when(() => userLayerControllerMock.updateUsers())
          .thenAnswer((_) => Future.value());
      when(() => accessPointLayerControllerMock.updateAccessPoints())
          .thenAnswer((_) => Future.value());
      makeContainerWithMapService();

      mapService.updateMap();

      verify(() => userLayerControllerMock.updateUsers()).called(1);
      verify(() => accessPointLayerControllerMock.updateAccessPoints())
          .called(1);
    });

    test('updates users and access points on map movement', () async {
      makeProviderMocks();
      when(() => userLayerControllerMock.updateUsers())
          .thenAnswer((_) => Future.value());
      when(() => accessPointLayerControllerMock.updateAccessPoints())
          .thenAnswer((_) => Future.value());
      makeContainerWithMapService();

      // Send map events which should trigger User/AP updates.
      mapControllerMock.emitMapEvent(
        MapEventMoveEnd(
          source: MapEventSource.custom,
          center: LatLng(1.0, 2.0),
          zoom: 1.0,
        ),
      );
      mapControllerMock.emitMapEvent(
        MapEventFlingAnimationEnd(
          source: MapEventSource.custom,
          center: LatLng(1.0, 2.0),
          zoom: 1.0,
        ),
      );
      mapControllerMock.emitMapEvent(
        MapEventDoubleTapZoomEnd(
          source: MapEventSource.custom,
          center: LatLng(1.0, 2.0),
          zoom: 1.0,
        ),
      );
      mapControllerMock.emitMapEvent(
        MapEventRotateEnd(
          source: MapEventSource.custom,
          center: LatLng(1.0, 2.0),
          zoom: 1.0,
        ),
      );
      mapControllerMock.emitMapEvent(
        MapEventMove(
          id: CenterZoomAnimation.finished,
          source: MapEventSource.custom,
          center: LatLng(1.0, 2.0),
          zoom: 1.0,
          targetCenter: LatLng(1.0, 2.0),
          targetZoom: 1.0,
        ),
      );
      // This event should be ignored as the id is unknown.
      mapControllerMock.emitMapEvent(
        MapEventMove(
          id: 'unknown id',
          source: MapEventSource.custom,
          center: LatLng(1.0, 2.0),
          zoom: 1.0,
          targetCenter: LatLng(1.0, 2.0),
          targetZoom: 1.0,
        ),
      );
      await mapControllerMock.waitForEvents();
      verify(() => userLayerControllerMock.updateUsers()).called(5);
      verify(() => accessPointLayerControllerMock.updateAccessPoints())
          .called(5);
    });

    test('moves map without animation if map is not associated yet', () async {
      makeProviderMocks();
      when(() => mapControllerMock.move(any(), any())).thenReturn(true);
      makeContainerWithMapService();

      mapService.moveMapToCenter(LatLng(1.0, 2.0), zoom: 3.0);

      verify(() => mapControllerMock.move(LatLng(1.0, 2.0), 3.0)).called(1);
    });

    test('moves map with animation if map is associated', () async {
      makeProviderMocks();
      makeContainerWithMapService();

      final centerZoomControllerMock = CenterZoomControllerMock();
      when(() => centerZoomControllerMock.moveTo(any())).thenReturn(null);
      mapService.associateMap(
        TickerProviderMock(),
        centerZoomController: centerZoomControllerMock,
      );
      mapService.moveMapToCenter(LatLng(1.0, 2.0), zoom: 3.0);

      verify(() => centerZoomControllerMock.moveTo(any(
          that: isA<CenterZoom>()
            ..having((e) => e.center, 'center', equals(LatLng(1.0, 2.0)))
            ..having((e) => e.zoom, 'zoom', 3.0)))).called(1);
    });

    test('getNearbyAccessPoints when zoom is < 12', () async {
      makeProviderMocks();
      makeContainerWithMapService();

      when(() => mapControllerMock.zoom).thenReturn(11.99);

      final result = await mapService.getNearbyAccessPoints();
      expect(result, isEmpty);
    });

    test('getNearbyAccessPoints when zoom is >= 12', () async {
      makeProviderMocks();
      makeContainerWithMapService();

      when(() => mapControllerMock.zoom).thenReturn(12.0);
      when(() => mapControllerMock.center).thenReturn(LatLng(1.0, 2.0));
      when(() => mapControllerMock.bounds)
          .thenReturn(LatLngBounds(LatLng(0.9, 1.9), LatLng(1.1, 2.1)));

      final accessPointMock = AccessPointMock();
      when(() => accessPointRepositoryMock.getAccessPointsWithinRadiusStream(
          any(), any())).thenAnswer((_) async* {
        yield [accessPointMock];
      });

      final result = await mapService.getNearbyAccessPoints();
      expect(result, isNotEmpty);

      verify(() => accessPointRepositoryMock.getAccessPointsWithinRadiusStream(
          LatLng(1.0, 2.0), 15.741630674803882));
    });

    test('getNearbyUsers when zoom is < 12', () async {
      makeProviderMocks();
      makeContainerWithMapService();

      when(() => mapControllerMock.zoom).thenReturn(11.99);

      final result = await mapService.getNearbyUsers();
      expect(result, isEmpty);
    });

    test('getNearbyUsers when zoom is >= 12', () async {
      makeProviderMocks();
      makeContainerWithMapService();

      when(() => mapControllerMock.zoom).thenReturn(12.0);
      when(() => mapControllerMock.center).thenReturn(LatLng(1.0, 2.0));
      when(() => mapControllerMock.bounds)
          .thenReturn(LatLngBounds(LatLng(0.9, 1.9), LatLng(1.1, 2.1)));

      final userProfileMock = UserProfileMock();
      when(() => nearbyUsersRepositoryMock.getUsersWithinRadiusStream(
          any(), any())).thenAnswer((_) async* {
        yield [userProfileMock];
      });

      final result = await mapService.getNearbyUsers();
      expect(result, isNotEmpty);

      verify(() => nearbyUsersRepositoryMock.getUsersWithinRadiusStream(
          LatLng(1.0, 2.0), 15.741630674803882));
    });
  });
}
