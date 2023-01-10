import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/place_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/map/domain/access_point_connection_state.dart';
import 'package:verifi/src/features/map/presentation/map_buttons/filter_map_button.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_connection_controller.dart';
import 'package:verifi/src/features/map/presentation/map_layers/access_point_layer/access_point_info_sheet.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../../../test_helper/go_router_mock.dart';
import '../../../../../../test_helper/riverpod_test_helper.dart';
import 'access_point_connection_controller_stub.dart';

class LocationRepositoryMock extends Mock implements LocationRepository {}

void main() {
  late GoRouterMock goRouterMock;
  late AccessPoint accessPoint;
  late AccessPointConnectionControllerStub accessPointConnectionControllerStub;
  late StreamController<UserProfile?> userProfileController;
  late LocationRepositoryMock locationRepositoryMock;

  AccessPoint createAccessPoint() {
    return AccessPoint(
      id: 'accessPointId123',
      location: LatLng(1.0, 2.0),
      ssid: 'AFakeWifi',
      submittedBy: 'userId123',
      verifiedStatus: VerifiedStatus.verified,
    );
  }

  void createProviderMocks({AccessPoint? initialAccessPoint}) {
    goRouterMock = GoRouterMock();
    accessPoint = initialAccessPoint ?? createAccessPoint();
    accessPointConnectionControllerStub = AccessPointConnectionControllerStub();
    userProfileController = StreamController<UserProfile?>();
    locationRepositoryMock = LocationRepositoryMock();
  }

  Future<ProviderContainer> makeWidget(WidgetTester tester) {
    return makeWidgetWithRiverpod(
      tester,
      widget: () => MaterialApp(
        home: mockGoRouter(
          goRouterMock,
          child: Scaffold(body: AccessPointInfoSheet(accessPoint)),
        ),
      ),
      overrides: [
        accessPointConnectionControllerProvider
            .overrideWith(() => accessPointConnectionControllerStub),
        userProfileFamily.overrideWith((ref, arg) {
          return userProfileController.stream;
        }),
        locationRepositoryProvider
            .overrideWith((ref) => locationRepositoryMock),
      ],
    );
  }

  group(FilterMapButton, () {
    testWidgets('initial state', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      expect(find.text('Unknown place'), findsOneWidget);
      expect(find.text('Unknown address'), findsOneWidget);
      expect(find.text(accessPoint.ssid), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.question_mark), findsNothing);
      expect(find.text(accessPoint.verifiedStatusLabel), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(VShimmerWidget), findsNWidgets(2)); // User info
    });

    testWidgets('unverified', (tester) async {
      createProviderMocks(
        initialAccessPoint: createAccessPoint().copyWith(
          verifiedStatus: VerifiedStatus.unverified,
        ),
      );
      await makeWidget(tester);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(find.byIcon(Icons.question_mark), findsOneWidget);
      expect(find.text("UnVeriFied"), findsOneWidget);
    });

    testWidgets('with password', (tester) async {
      createProviderMocks(
        initialAccessPoint: createAccessPoint().copyWith(
          password: 'AFakePassword',
        ),
      );
      await makeWidget(tester);
      expect(find.text('AFakePassword'), findsNothing);
      expect(find.text('\u2022' * 'AFakePassword'.length), findsOneWidget);
    });

    testWidgets('with place', (tester) async {
      createProviderMocks(
        initialAccessPoint: createAccessPoint().copyWith(
          place: Place(
            id: 'placeId123',
            title: 'placeTitle',
            address: 'placeAddress',
            location: LatLng(1.1, 2.2),
          ),
        ),
      );
      await makeWidget(tester);
      expect(find.text('placeTitle'), findsOneWidget);
      expect(find.text('placeAddress'), findsOneWidget);
    });

    testWidgets('with contributor', (tester) async {
      createProviderMocks();
      final container = await makeWidget(tester);
      userProfileController.add(
        const UserProfile(
          id: 'userId123',
          displayName: 'userDisplayName',
        ),
      );
      await container.pump();
      await tester.pump();

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('userDisplayName'), findsOneWidget);
    });

    testWidgets('with missing contributor', (tester) async {
      createProviderMocks();
      final container = await makeWidget(tester);
      userProfileController.add(null);
      await container.pump();
      await tester.pump();

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('close to access point, not connecting', (tester) async {
      createProviderMocks();
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      accessPointConnectionControllerStub
          .setInitialValue(const AccessPointConnectionState(connecting: false));
      await makeWidget(tester);

      expect(find.widgetWithText(ElevatedButton, 'Connect'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('close to access point, connecting', (tester) async {
      createProviderMocks();
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      accessPointConnectionControllerStub
          .setInitialValue(const AccessPointConnectionState(connecting: true));
      await makeWidget(tester);
      await tester.pump();

      final connectButton =
          tester.widget(find.widgetWithText(ElevatedButton, 'Connect'))
              as ElevatedButton;
      expect(connectButton.enabled, isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('close to access point, tap connect', (tester) async {
      createProviderMocks();
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      accessPointConnectionControllerStub
          .setInitialValue(const AccessPointConnectionState(connecting: false));
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Connect'));
      await tester.pump();

      expect(accessPointConnectionControllerStub.connectCalled, isTrue);
    });

    testWidgets('connection made', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      accessPointConnectionControllerStub.triggerUpdate(
        const AsyncData(
          AccessPointConnectionState(
            connecting: false,
            connectionResult: 'A CONNECTION MESSAGE',
          ),
        ),
      );
      await tester.pump();

      expect(find.widgetWithText(SnackBar, 'A CONNECTION MESSAGE'),
          findsOneWidget);
      verify(() => goRouterMock.pop()).called(1);
    });
  });
}
