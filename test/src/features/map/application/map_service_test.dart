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
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/map/application/center_zoom_controller.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/data/nearby_users_repository.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_layer_controller.dart';
import 'package:verifi/src/features/map/presentation/map_layers/user_layer/user_layer_controller.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../test_helper/register_fallbacks.dart';
import '../../../mocks.dart';

void main() {
  setUpAll(() {
    registerFallbacks();
  });

  group(MapService, () {
    late StreamController<CurrentUser> currentUserController;
    late MapControllerMock mapControllerMock;
    late MapService mapService;
    late UserLayerControllerMock userLayerControllerMock;
    late AccessPointLayerControllerMock accessPointLayerControllerMock;
    late AccessPointRepositoryMock accessPointRepositoryMock;
    late NearbyUsersRepositoryMock nearbyUsersRepositoryMock;

    void makeProviderMocks() {
      currentUserController = StreamController<CurrentUser>();
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
          currentUserProvider
              .overrideWith((ref) => currentUserController.stream),
          nearbyUsersRepositoryProvider
              .overrideWith((ref) => nearbyUsersRepositoryMock),
          accessPointRepositoryProvider
              .overrideWith((ref) => accessPointRepositoryMock),
          mapServiceProvider.overrideWith((ref) {
            mapService = MapService(
              ref,
              mapController: mapControllerMock,
              accessPointLayerControllerOverride:
                  accessPointLayerControllerMock,
              userLayerControllerOverride: userLayerControllerMock,
            );
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
              .having((e) => e.center, 'center', equals(LatLng(1.0, 2.0)))
              .having((e) => e.zoom, 'zoom', 3.0)))).called(1);
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

    group('getNearbyUsers', () {
      UserProfile userProfile({
        required String id,
        required bool hideOnMap,
        required DateTime lastLocationUpdate,
      }) =>
          UserProfile(
            id: id,
            displayName: 'testDisplayName',
            veriPoints: 0,
            hideOnMap: hideOnMap,
            statistics: const {},
            achievementsProgress: const {},
            lastLocationUpdate: lastLocationUpdate,
          );

      test('when zoom is < 12', () async {
        makeProviderMocks();
        makeContainerWithMapService();

        when(() => mapControllerMock.zoom).thenReturn(11.99);

        final result = await mapService.getNearbyUsers();
        expect(result, isEmpty);
      });

      test('when zoom is >= 12', () async {
        makeProviderMocks();
        final container = makeContainerWithMapService();

        final currentUser = CurrentUser(
          profile: userProfile(
            id: '0',
            hideOnMap: true,
            lastLocationUpdate:
                DateTime.now().subtract(MapService.hideUsersInactiveSince),
          ),
        );
        currentUserController.add(currentUser);
        await container.read(currentUserProvider.stream).first; // Skip loading
        when(() => mapControllerMock.zoom).thenReturn(12.0);
        when(() => mapControllerMock.center).thenReturn(LatLng(1.0, 2.0));
        when(() => mapControllerMock.bounds)
            .thenReturn(LatLngBounds(LatLng(0.9, 1.9), LatLng(1.1, 2.1)));

        when(() => nearbyUsersRepositoryMock.usersWithinRadius(any(), any()))
            .thenAnswer((_) async* {
          yield [
            // Current user, should be visible even if hidden or not recentlyupdate
            // updated
            currentUser.profile,
            // Not hidden and recently updated, should be visible
            userProfile(
              id: '1',
              hideOnMap: false,
              lastLocationUpdate: DateTime.now(),
            ),
            // Hidden, should not be visible
            userProfile(
              id: '2',
              hideOnMap: true,
              lastLocationUpdate: DateTime.now(),
            ),
            // Not recently updated, should not be visible
            userProfile(
              id: '3',
              hideOnMap: false,
              lastLocationUpdate:
                  DateTime.now().subtract(MapService.hideUsersInactiveSince),
            ),
          ];
        });

        final result = await mapService.getNearbyUsers();
        expect(result.map((profile) => profile.id).toList(), ['0', '1']);

        verify(() => nearbyUsersRepositoryMock.usersWithinRadius(
              LatLng(1.0, 2.0),
              15.741630674803882,
            ));
      });
    });
  });
}
