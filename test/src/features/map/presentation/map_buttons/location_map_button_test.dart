import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/map/application/map_service.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/location_permission_dialog.dart';
import 'package:verifi/src/features/map/presentation/flutter_map/map_location_permissions_controller.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/location_map_button.dart';

import '../../../../../test_helper/register_fallbacks.dart';
import '../../../../../test_helper/riverpod_test_helper.dart';
import 'map_location_permissions_controller_stub.dart';

class MapControllerMock extends Mock implements MapController {}

class LocationRepositoryFake extends Fake implements LocationRepository {
  final _locationController = StreamController<LatLng>();

  @override
  Stream<LatLng> get locationStream => _locationController.stream;

  void updateLocation(LatLng newLocation) {
    _locationController.add(newLocation);
  }

  Future<void> dispose() {
    return _locationController.close();
  }
}

void main() {
  late LocationRepositoryFake locationRepositoryFake;
  late MapControllerMock mapControllerMock;
  late MapLocationPermissionsControllerStub
      mapLocationPermissionsControllerStub;

  void createProviderMocks() {
    locationRepositoryFake = LocationRepositoryFake();
    addTearDown(() => locationRepositoryFake.dispose);
    mapLocationPermissionsControllerStub =
        MapLocationPermissionsControllerStub();
    mapControllerMock = MapControllerMock();
  }

  Future<ProviderContainer> makeWidget(WidgetTester tester) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () {
        return Scaffold(body: LocationMapButton());
      },
      overrides: [
        locationRepositoryProvider
            .overrideWith((ref) => locationRepositoryFake),
        mapLocationPermissionsControllerProvider
            .overrideWith(() => mapLocationPermissionsControllerStub),
        mapControllerProvider.overrideWith((ref) => mapControllerMock),
      ],
    );
  }

  group(LocationMapButton, () {
    setUpAll(() {
      registerFallbacks();
    });

    testWidgets('location permission is loading', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      tester.widget(find.byType(ElevatedButton));

      // Check button state
      final button =
          tester.widget(find.byType(ElevatedButton)) as ElevatedButton;
      final icon = button.child as Icon;
      expect(icon.icon, Icons.my_location);

      expect(button.enabled, isFalse);
      expect(button.onPressed, isNull);
    });

    testWidgets('geolocation denied forever', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // Set permission to denied forever.
      mapLocationPermissionsControllerStub
        ..triggerUpdate(const AsyncLoading())
        ..triggerUpdate(const AsyncData(LocationPermission.deniedForever));
      await tester.pump();

      // Check that an explanatory SnackBar is displayed.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      final snackBar = tester.widget(find.byType(SnackBar)) as SnackBar;
      final snackBarText = snackBar.content as Text;
      expect(snackBarText.data,
          contains('Location permission permanently denied'));
    });

    testWidgets('geolocation denied', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // Set permission to denied.
      mapLocationPermissionsControllerStub
        ..triggerUpdate(const AsyncLoading())
        ..triggerUpdate(const AsyncData(LocationPermission.denied));
      await tester.pump();

      // Make sure the permissions dialog is shown.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(LocationPermissionDialog), findsOneWidget);
    });

    testWidgets('geolocation allowed, location not set', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // Set permission to always.
      mapLocationPermissionsControllerStub
        ..triggerUpdate(const AsyncLoading())
        ..triggerUpdate(const AsyncData(LocationPermission.always));
      await tester.pump();

      // Check button is disabled
      final button =
          tester.widget(find.byType(ElevatedButton)) as ElevatedButton;
      expect(button.enabled, isFalse);
      expect(button.onPressed, isNull);
    });

    testWidgets('geolocation allowed, location set', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      // Stub location and set permission to always.
      locationRepositoryFake.updateLocation(LatLng(41.1, 10.2));
      mapLocationPermissionsControllerStub
        ..triggerUpdate(const AsyncLoading())
        ..triggerUpdate(const AsyncData(LocationPermission.always));
      await tester.pump();

      // Check tap behaviour.
      when(() => mapControllerMock.move(any(), any())).thenReturn(true);
      await tester.tap(find.byType(ElevatedButton));
      verify(() => mapControllerMock.move(LatLng(41.1, 10.2), 18));
    });
  });
}
