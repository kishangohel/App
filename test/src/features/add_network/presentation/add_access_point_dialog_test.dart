import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/common/providers/wifi_connected_stream_provider.dart';
import 'package:verifi/src/features/access_points/data/place_repository.dart';
import 'package:verifi/src/features/access_points/domain/place_model.dart';
import 'package:verifi/src/features/add_network/application/add_access_point_controller.dart';
import 'package:verifi/src/features/add_network/domain/new_access_point_model.dart';
import 'package:verifi/src/features/add_network/presentation/add_access_point_dialog.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';

import '../../../../test_helper/go_router_mock.dart';
import '../../../../test_helper/register_fallbacks.dart';
import '../../../../test_helper/riverpod_test_helper.dart';
import 'add_access_point_controller_stub.dart';

class LocationRepositoryMock extends Mock implements LocationRepository {}

class PlaceRepositoryMock extends Mock implements PlaceRepository {}

void main() {
  late AddAccessPointControllerStub addAccessPointControllerStub;
  late LocationRepositoryMock locationRepositoryMock;
  late PlaceRepositoryMock placeRepositoryMock;
  late StreamController<bool> isConnectedToWifiProviderStub;
  late GoRouterMock goRouterMock;

  void createProviderMocks() {
    addAccessPointControllerStub = AddAccessPointControllerStub();
    locationRepositoryMock = LocationRepositoryMock();
    placeRepositoryMock = PlaceRepositoryMock();
    isConnectedToWifiProviderStub = StreamController();
    goRouterMock = GoRouterMock();
  }

  Future<ProviderContainer> makeWidget(
    WidgetTester tester, {
    String ssid = "testSsid",
  }) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () => Scaffold(
        body: InheritedGoRouter(
          goRouter: goRouterMock,
          child: AddAccessPointDialog(ssid: ssid),
        ),
      ),
      overrides: [
        addAccessPointControllerProvider
            .overrideWith(() => addAccessPointControllerStub),
        locationRepositoryProvider
            .overrideWith((ref) => locationRepositoryMock),
        placeRepositoryProvider.overrideWith((ref) => placeRepositoryMock),
        isConnectedToWiFiProvider
            .overrideWith((ref) => isConnectedToWifiProviderStub.stream),
      ],
    );
  }

  Finder ssidFieldFinder() => find.widgetWithText(TextField, 'SSID');
  Finder passwordFieldFinder() => find.byType(TextFormField);
  Finder passwordSwitchFinder() => find.byType(Switch);
  Finder placeFieldFinder() => find.byType(TypeAheadFormField<Place>);
  Finder progressIndicatorFinder() => find.byType(CircularProgressIndicator);
  Finder submitButtonFinder() => find.widgetWithText(ElevatedButton, 'Submit');

  TextField ssidField(WidgetTester tester) => tester.widget(ssidFieldFinder());
  TextFormField passwordField(WidgetTester tester) =>
      tester.widget(passwordFieldFinder());
  Switch passwordSwitch(WidgetTester tester) =>
      tester.widget(passwordSwitchFinder());
  TypeAheadFormField<Place> placeField(WidgetTester tester) =>
      tester.widget(placeFieldFinder());
  ElevatedButton submitButton(WidgetTester tester) =>
      tester.widget(submitButtonFinder());

  group(FilterMapButton, () {
    setUpAll(() {
      registerFallbacks();
    });

    testWidgets('removes quotes from ssid on android', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      createProviderMocks();
      await makeWidget(tester, ssid: '"ssid"');

      expect(ssidField(tester).controller!.text, equals('ssid'));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('does not remove quotes from ssid on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      createProviderMocks();
      await makeWidget(tester, ssid: '"ssid"');

      expect(ssidField(tester).controller!.text, equals('"ssid"'));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('wifi disconnected', (tester) async {
      createProviderMocks();
      when(() => goRouterMock.canPop()).thenReturn(true);
      await makeWidget(tester);
      isConnectedToWifiProviderStub.add(false);
      await isConnectedToWifiProviderStub.close();
      await isConnectedToWifiProviderStub.done;

      await tester.pump();
      verify(() => goRouterMock.pop(
          const CreateAccessPointDialogResult.wifiDisconnected())).called(1);
    });

    testWidgets('access point created', (tester) async {
      createProviderMocks();
      when(() => goRouterMock.canPop()).thenReturn(true);
      await makeWidget(tester);

      final newAccessPoint = NewAccessPoint(
        ssid: 'testSsid',
        place: Place(
          id: 'placeId',
          name: 'placeName',
          location: LatLng(1.0, 2.0),
          address: 'placeAddress',
        ),
      );
      addAccessPointControllerStub
          .triggerUpdate(AsyncValue.data(newAccessPoint));
      await tester.pump();
      verify(
        () => goRouterMock
            .pop(CreateAccessPointDialogResult.success(newAccessPoint)),
      ).called(1);
    });

    testWidgets('loading state, fields not editable', (tester) async {
      createProviderMocks();
      await makeWidget(tester);

      expect(ssidField(tester).enabled, isFalse);
      expect(passwordField(tester).enabled, isFalse);
      expect(passwordSwitch(tester).onChanged, isNull);
      expect(placeField(tester).enabled, isFalse);
      expect(progressIndicatorFinder(), findsOneWidget);
      expect(submitButton(tester).enabled, isFalse);
    });

    testWidgets('loaded, ssid not required', (tester) async {
      createProviderMocks();
      addAccessPointControllerStub.setInitialValue(null);
      final container = await makeWidget(tester);
      await container.pump();
      await tester.pump();

      expect(
        FocusScope.of(tester.element(find.byType(AddAccessPointDialog)))
            .focusedChild
            ?.debugLabel,
        'placeFocusNode',
      );
      expect(ssidField(tester).enabled, isFalse);
      expect(passwordField(tester).enabled, isFalse);
      expect(passwordSwitch(tester).value, isFalse);
      expect(passwordSwitch(tester).onChanged, isNotNull);
      expect(placeField(tester).enabled, isTrue);
      expect(progressIndicatorFinder(), findsNothing);
      expect(submitButton(tester).enabled, isFalse);
    });

    testWidgets('loaded, tap password required switch', (tester) async {
      createProviderMocks();
      addAccessPointControllerStub.setInitialValue(null);
      final container = await makeWidget(tester);
      await container.pump();
      await tester.pump();
      await tester.tap(passwordSwitchFinder());
      await tester.pump();
      await tester.pump();

      // Check that password field is focused
      expect(
        FocusScope.of(tester.element(find.byType(AddAccessPointDialog)))
            .focusedChild
            ?.debugLabel,
        'passwordFocusNode',
      );
      expect(ssidField(tester).enabled, isFalse);
      expect(passwordField(tester).enabled, isTrue);
      expect(passwordSwitch(tester).value, isTrue);
      expect(passwordSwitch(tester).onChanged, isNotNull);
      expect(placeField(tester).enabled, isTrue);
      expect(progressIndicatorFinder(), findsNothing);
      expect(submitButton(tester).enabled, isFalse);
    });

    testWidgets('loaded, clears password when not required', (tester) async {
      createProviderMocks();
      addAccessPointControllerStub.setInitialValue(null);
      final container = await makeWidget(tester);
      await container.pump();
      await tester.pump();
      await tester.tap(passwordSwitchFinder());
      await tester.pump();
      await tester.pump();

      // Check that password field is focused
      await tester.enterText(passwordFieldFinder(), "ATestPassword");
      expect(passwordField(tester).controller!.text, "ATestPassword");
      await tester.tap(passwordSwitchFinder());
      expect(passwordField(tester).controller!.text, isEmpty);
    });

    testWidgets('submit place with no password', (tester) async {
      // Setup
      createProviderMocks();
      final place = Place(
        id: 'testPlaceId',
        name: 'testPlaceName',
        location: LatLng(1.0, 2.0),
        address: 'testAddress',
      );
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(LatLng(1.0, 2.0));
      when(() => placeRepositoryMock.searchNearbyPlaces(any(), any()))
          .thenAnswer((invocation) {
        return Future.value([place]);
      });
      addAccessPointControllerStub.setInitialValue(null);
      final container = await makeWidget(tester);
      await container.pump();
      await tester.pump();

      // Enter the place search text
      tester.testTextInput.enterText('testPlace');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text(place.name), findsOneWidget);

      // Tap the result
      await tester.tap(find.text(place.name));
      await tester.pump();

      // Submit
      expect(submitButton(tester).enabled, isTrue);
      await tester.tap(submitButtonFinder());

      expect(
        addAccessPointControllerStub.addedAccessPoints,
        [
          NewAccessPoint(
            ssid: 'testSsid',
            password: null,
            place: place,
          )
        ],
      );
    });

    testWidgets('submit place with password', (tester) async {
      // Setup
      createProviderMocks();
      final place = Place(
        id: 'testPlaceId',
        name: 'testPlaceName',
        location: LatLng(1.0, 2.0),
        address: 'testAddress',
      );
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(LatLng(1.0, 2.0));
      when(() => placeRepositoryMock.searchNearbyPlaces(any(), any()))
          .thenAnswer((invocation) {
        return Future.value([place]);
      });
      addAccessPointControllerStub.setInitialValue(null);
      final container = await makeWidget(tester);
      await container.pump();
      await tester.pump();

      // Enable password entry and enter a password.
      await tester.tap(passwordSwitchFinder());
      await tester.pump();
      expect(
        FocusScope.of(tester.element(find.byType(AddAccessPointDialog)))
            .focusedChild
            ?.debugLabel,
        'passwordFocusNode',
      );
      tester.testTextInput.enterText('aTestPassword');

      // Enter the place search text
      await tester.tap(placeFieldFinder());
      await tester.pump();
      tester.testTextInput.enterText('testPlace');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text(place.name), findsOneWidget);

      // Tap the result
      await tester.tap(find.text(place.name));
      await tester.pump();

      // Submit
      expect(submitButton(tester).enabled, isTrue);
      await tester.tap(submitButtonFinder());

      expect(
        addAccessPointControllerStub.addedAccessPoints,
        [
          NewAccessPoint(
            ssid: 'testSsid',
            password: 'aTestPassword',
            place: place,
          )
        ],
      );
    });
  });
}