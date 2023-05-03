import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/access_points/presentation/access_point_info_sheet.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../helper.dart';
import '../mocks.dart';

void main() {
  late StreamController<CurrentUser?> currentUserStreamController;
  late LocationRepository locationRepository;
  late ProviderContainer container;

  group(AccessPointInfoSheet, () {
    setUp(() {
      locationRepository = MockLocationRepository();
      currentUserStreamController = StreamController<CurrentUser?>();
      container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => currentUserStreamController.stream,
          ),
          locationRepositoryProvider.overrideWithValue(locationRepository),
        ],
      );
    });

    testWidgets(
      '''
      Given an access point,
      When it is passed to AccessPointInfoSheet,
      Then it displays the access point's information.
      ''',
      (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AccessPointInfoSheet(verifiedAccessPoint),
              ),
            ),
          ),
        );
        expect(find.text(verifiedAccessPoint.name), findsOneWidget);
        expect(find.text(verifiedAccessPoint.address), findsOneWidget);
        expect(find.text(verifiedAccessPoint.ssid), findsOneWidget);
        expect(
          find.text(verifiedAccessPoint.verifiedStatusLabel),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '''
      Given a verified access point that was contributed by the current user,
        and the user is within proximity of the access point,
      When AccessPointInfoSheet shows that fake access point,
      Then the connect button is not visible.
      ''',
      (tester) async {
        // Arrange
        currentUserStreamController.add(
          const CurrentUser(profile: verifiedAccessPointContributor),
        );
        when(() => locationRepository.currentLocation).thenReturn(
          verifiedAccessPoint.location,
        );
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AccessPointInfoSheet(verifiedAccessPoint),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(
          verifiedAccessPoint.submittedBy == verifiedAccessPointContributor.id,
          true,
        );
        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets(
      '''
      Given a verified access point that was not contributed by the current user,
         and the current user is within proximity of the AP,
      When AccessPointInfoSheet shows that fake access point,
      Then the connect button is visible.
      ''',
      (tester) async {
        // Arrange
        currentUserStreamController.add(
          const CurrentUser(profile: otherUser),
        );
        when(() => locationRepository.currentLocation).thenReturn(
          verifiedAccessPoint.location,
        );
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AccessPointInfoSheet(verifiedAccessPoint),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.widgetWithText(ElevatedButton, 'Connect'), findsOneWidget);
      },
    );

    testWidgets(
      '''
      Given a verified access point that was not contributed by the current user,
         and the current user is not within proximity of the AP,
      When AccessPointInfoSheet shows that fake access point,
      Then the connect button is not visible.
      ''',
      (tester) async {
        // Arrange
        currentUserStreamController.add(
          const CurrentUser(profile: otherUser),
        );
        when(() => locationRepository.currentLocation).thenReturn(
          LatLng(
            verifiedAccessPoint.location.latitude + 1,
            verifiedAccessPoint.location.longitude + 1,
          ),
        );
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AccessPointInfoSheet(verifiedAccessPoint),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets(
      '''
      Given a unverified access point that was not contributed by the current user,
         and the current user is within proximity of the AP,
      When AccessPointInfoSheet shows that fake access point,
      Then the validate button is not visible.
      ''',
      (tester) async {
        // Arrange
        currentUserStreamController.add(
          const CurrentUser(profile: otherUser),
        );
        when(() => locationRepository.currentLocation).thenReturn(
          unverifiedAccessPoint.location,
        );
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: AccessPointInfoSheet(unverifiedAccessPoint),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.widgetWithText(ElevatedButton, 'Validate'), findsOneWidget);
      },
    );
  });
}
