import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/common/providers/wifi_connected_stream_provider.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/data/radar_search_repository.dart';
import 'package:verifi/src/features/access_points/domain/radar_address_model.dart';
import 'package:verifi/src/features/add_network/presentation/add_access_point_dialog.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/map/data/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../../../test_helper/go_router_mock.dart';
import '../../../../test_helper/register_fallbacks.dart';
import '../../../mocks.dart';
import '../../profile/helper.dart';
import '../add_network_robot.dart';

void main() {
  ProviderContainer makeProviderContainer(
    TextEditingController ssidController,
    TextEditingController passwordController,
    TextEditingController placeController,
    AccessPointRepository accessPointRepository,
    LocationRepository locationRepository,
    RadarSearchRepository radarSearchRepository,
    StreamController<CurrentUser?> currentUserStreamController,
    StreamController<bool> isConnectedToWiFiStreamController,
  ) {
    final container = ProviderContainer(
      overrides: [
        accessPointRepositoryProvider.overrideWithValue(accessPointRepository),
        locationRepositoryProvider.overrideWithValue(locationRepository),
        radarSearchRepositoryProvider.overrideWithValue(radarSearchRepository),
        currentUserProvider.overrideWith(
          (ref) => currentUserStreamController.stream,
        ),
        isConnectedToWiFiProvider.overrideWith(
          (ref) => isConnectedToWiFiStreamController.stream,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group(AddAccessPointDialog, () {
    late TextEditingController ssidController;
    late TextEditingController passwordController;
    late TextEditingController placeController;
    late AccessPointRepository accessPointRepository;
    late LocationRepository locationRepository;
    late RadarSearchRepository radarSearchRepository;
    late StreamController<CurrentUser?> currentUserStreamController;
    late StreamController<bool> isConnectedToWiFiStreamController;
    late GoRouterMock goRouterMock;
    late ProviderContainer container;
    setUpAll(() {
      registerFallbacks();
    });

    setUp(() {
      ssidController = TextEditingController();
      passwordController = TextEditingController();
      placeController = TextEditingController();
      accessPointRepository = MockAccessPointRepository();
      locationRepository = MockLocationRepository();
      radarSearchRepository = MockRadarSearchRepository();
      currentUserStreamController = StreamController<CurrentUser?>();
      currentUserStreamController.add(
        CurrentUser(
          profile: userProfileWithUsage,
        ),
      );
      isConnectedToWiFiStreamController = StreamController<bool>();
      isConnectedToWiFiStreamController.add(true);
      goRouterMock = GoRouterMock();
      container = makeProviderContainer(
        ssidController,
        passwordController,
        placeController,
        accessPointRepository,
        locationRepository,
        radarSearchRepository,
        currentUserStreamController,
        isConnectedToWiFiStreamController,
      );
    });

    testWidgets(
      '''
      Given the current platform is Android,
      When AddAccessPointDialog is created,
      Then the quotes surrounding the ssid are removed.
      ''',
      (tester) async {
        // Arrange
        final r = AddNetworkRobot(tester);
        const ssid = '"Test SSID"';
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        // Act
        await r.pumpAddAccessPointDialog(
          container,
          goRouterMock,
          ssid,
          ssidController,
          passwordController,
          placeController,
        );
        // Assert
        r.expectSsidText('Test SSID');
        // Cleanup
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets(
      '''
      When wifi is disconnected,
      Then `gorouter.pop` is called to dismiss the dialog.
      ''',
      (tester) async {
        // Arrange
        final r = AddNetworkRobot(tester);
        const ssid = 'Test SSID';
        when(() => goRouterMock.canPop()).thenReturn(true);
        // Act
        await r.pumpAddAccessPointDialog(
          container,
          goRouterMock,
          ssid,
          ssidController,
          passwordController,
          placeController,
        );
        isConnectedToWiFiStreamController.add(false);
        await tester.pumpAndSettle();
        // Assert
        verify(
          () => goRouterMock.pop<CreateAccessPointDialogResult>(any()),
        ).called(1);
      },
    );

    testWidgets(
      '''
      When AddAccessPointDialog is created,
      Then the ssid field is disabled, i.e. it can't be edited.
      ''',
      (tester) async {
        // Arrange
        final r = AddNetworkRobot(tester);
        const ssid = 'Test SSID';
        // Act
        await r.pumpAddAccessPointDialog(
          container,
          goRouterMock,
          ssid,
          ssidController,
          passwordController,
          placeController,
        );
        // Assert
        r.expectSsidText(ssid);
        final textField = r.getSsidTextFieldWidget();
        expect(textField.enabled, false);
      },
    );

    testWidgets(
      '''
      Given the password required switch is off
      When the password required switch is toggled on,
      Then the password field is enabled and focused.
      ''',
      (tester) async {
        // Arrange
        final r = AddNetworkRobot(tester);
        const ssid = 'Test SSID';
        // Act
        await r.pumpAddAccessPointDialog(
          container,
          goRouterMock,
          ssid,
          ssidController,
          passwordController,
          placeController,
        );
        r.expectPasswordRequiredSwitch();
        r.expectPasswordRequiredSwitchIsOff(tester);
        await r.togglePasswordRequiredSwitch(tester);
        // Assert
        r.expectPasswordRequiredSwitchIsOn(tester);
        r.expectPasswordTextFieldIsEnabled(tester);
        r.expectPasswordTextFieldHasFocus(tester);
      },
    );

    testWidgets(
      '''
      When password switch is toggled on,
      Then the password field is focused.
      ''',
      (tester) async {
        // Arrange
        final r = AddNetworkRobot(tester);
        const ssid = 'Test SSID';
        // Act
        await r.pumpAddAccessPointDialog(
          container,
          goRouterMock,
          ssid,
          ssidController,
          passwordController,
          placeController,
        );
        r.expectPasswordRequiredSwitch();
        r.expectPasswordRequiredSwitchIsOff(tester);
        await r.togglePasswordRequiredSwitch(tester);
        // Assert
        r.expectPasswordRequiredSwitchIsOn(tester);
        r.expectPasswordTextFieldHasFocus(tester);
      },
    );

    testWidgets(
      '''
      Given the place search has returned a result,
      When the list item is tapped,
      Then the place text field contains the list item place name.
      ''',
      (tester) async {
        // Arrange
        final r = AddNetworkRobot(tester);
        const ssid = 'Test SSID';
        when(
          () => locationRepository.currentLocation,
        ).thenAnswer(
          (_) => Future.value(LatLng(1.0, 1.0)),
        );
        when(
          () => radarSearchRepository.searchNearbyPlaces(any(), any()),
        ).thenAnswer(
          (_) => Future.value([
            RadarAddress(
              name: 'test place',
              address: 'test address',
              location: LatLng(1.0, 1.0),
            ),
          ]),
        );
        // Act
        await r.pumpAddAccessPointDialog(
          container,
          goRouterMock,
          ssid,
          ssidController,
          passwordController,
          placeController,
        );
        await r.enterTextPlaceSearch(tester, 'test place');
        r.expectPlaceSearchResultListTile(tester, 'test place');
        await r.tapPlaceSearchResultListTile(tester, 'test place');
        // Assert
        expect(find.text('test place'), findsOneWidget);
        expect(placeController.value.text, 'test place');
      },
    );

    testWidgets(
      '''
      When the submit button is pressed,
      Then `accessPointRepository.addAccessPoint` is called.
      ''',
      (tester) async {
        await tester.runAsync(() async {
          // Arrange
          final r = AddNetworkRobot(tester);
          const ssid = 'Test SSID';
          when(() => goRouterMock.canPop()).thenReturn(true);
          when(
            () => locationRepository.currentLocation,
          ).thenAnswer(
            (_) => Future.value(LatLng(1.0, 1.0)),
          );
          when(
            () => radarSearchRepository.searchNearbyPlaces(any(), any()),
          ).thenAnswer(
            (_) => Future.value([
              RadarAddress(
                name: 'test place',
                address: 'test address',
                location: LatLng(1.0, 1.0),
              ),
            ]),
          );
          when(
            () => accessPointRepository.addAccessPoint(
              userId: any(named: 'userId'),
              newAccessPoint: any(named: 'newAccessPoint'),
            ),
          ).thenAnswer(
            (_) => Future.value(),
          );
          expect(container.read(currentUserProvider).value, isNull);
          currentUserStreamController.add(
            CurrentUser(profile: userProfileWithUsage),
          );
          await Future.delayed(const Duration(milliseconds: 100));
          expect(container.read(currentUserProvider).value, isNotNull);
          // Act
          await r.pumpAddAccessPointDialog(
            container,
            goRouterMock,
            ssid,
            ssidController,
            passwordController,
            placeController,
          );
          await r.enterTextPlaceSearch(tester, 'test place');
          r.expectPlaceSearchResultListTile(tester, 'test place');
          await r.tapPlaceSearchResultListTile(tester, 'test place');
          await r.tapSubmitButton(tester);
          // Assert
          verify(
            () => accessPointRepository.addAccessPoint(
              userId: any(named: 'userId'),
              newAccessPoint: any(named: 'newAccessPoint'),
            ),
          ).called(1);
        });
      },
    );
  });
}
