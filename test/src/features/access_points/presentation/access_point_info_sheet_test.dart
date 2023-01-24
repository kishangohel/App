import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/access_points/application/access_point_connection_controller.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';
import 'package:verifi/src/features/access_points/presentation/access_point_info_sheet.dart';
import 'package:verifi/src/features/access_points/presentation/report_access_point_dialog.dart';
import 'package:verifi/src/features/map/data/location/location_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../test_helper/go_router_mock.dart';
import '../../../../test_helper/riverpod_test_helper.dart';
import 'access_point_connection_controller_stub.dart';

class LocationRepositoryMock extends Mock implements LocationRepository {}

void main() {
  late GoRouterMock goRouterMock;
  late AccessPoint accessPoint;
  late AccessPointConnectionControllerStub accessPointConnectionControllerStub;
  late StreamController<CurrentUser?> currentUserController;
  late StreamController<UserProfile?> userSearchResultController;
  late LocationRepositoryMock locationRepositoryMock;

  AccessPoint createAccessPoint() {
    return AccessPoint(
      id: 'accessPointId123',
      address: '123 test address',
      name: 'Test Place',
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
    currentUserController = StreamController<CurrentUser?>();
    userSearchResultController = StreamController<UserProfile?>();
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
        currentUserProvider.overrideWith((ref) => currentUserController.stream),
        userProfileFamily.overrideWith((ref, arg) {
          return userSearchResultController.stream;
        }),
        locationRepositoryProvider
            .overrideWith((ref) => locationRepositoryMock),
      ],
    );
  }

  group(AccessPointInfoSheet, () {
    testWidgets('initial state', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      expect(find.text('Test Place'), findsOneWidget);
      expect(find.text('123 test address'), findsOneWidget);
      expect(find.text(accessPoint.ssid), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.question_mark), findsNothing);
      expect(find.text(accessPoint.verifiedStatusLabel), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(VShimmerWidget), findsNWidgets(2)); // User info
      expect(find.byIcon(Icons.report), findsOneWidget); // User info
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

    testWidgets('with contributor', (tester) async {
      createProviderMocks();
      final container = await makeWidget(tester);
      userSearchResultController.add(
        const UserProfile(
          id: 'userId123',
          displayName: 'userDisplayName',
          hideOnMap: false,
          statistics: {},
          achievementProgresses: {},
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
      userSearchResultController.add(null);
      await container.pump();
      await tester.pump();

      // These should not be visible via Visibility widget
      expect(find.byType(SvgPicture), findsNothing);
      expect(find.text('Unknown'), findsNothing);
    });

    testWidgets('close to AP but AP from same user', (tester) async {
      createProviderMocks();
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      accessPointConnectionControllerStub.setInitialValue(Future.value(null));
      await makeWidget(tester);

      currentUserController.add(
        CurrentUser(
          profile: UserProfile(
            id: accessPoint.submittedBy,
            displayName: '',
            hideOnMap: false,
            statistics: const {},
            achievementProgresses: const {},
          ),
        ),
      );
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Validate'), findsNothing);
    });

    testWidgets('close to AP and AP from different user', (tester) async {
      createProviderMocks();
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      accessPointConnectionControllerStub.setInitialValue(Future.value(null));
      await makeWidget(tester);
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Connect'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'close to AP and AP from different user, unverified access point',
        (tester) async {
      createProviderMocks(
        initialAccessPoint: createAccessPoint().copyWith(
          verifiedStatus: VerifiedStatus.unverified,
        ),
      );
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      accessPointConnectionControllerStub.setInitialValue(Future.value(null));
      await makeWidget(tester);
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Validate'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('close to AP and AP from different user, connecting',
        (tester) async {
      createProviderMocks();
      when(() => locationRepositoryMock.currentLocation)
          .thenReturn(accessPoint.location);
      final container = await makeWidget(tester);
      accessPointConnectionControllerStub
          .triggerUpdate(const AsyncLoading<String?>());
      await container.pump();
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
      accessPointConnectionControllerStub.setInitialValue(Future.value(null));
      await makeWidget(tester);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Connect'));
      await tester.pump();

      expect(accessPointConnectionControllerStub.accessPointsConnectedTo,
          [accessPoint]);
    });

    testWidgets('connection made', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      accessPointConnectionControllerStub.triggerUpdate(
        const AsyncData('A CONNECTION MESSAGE'),
      );
      await tester.pump();

      expect(find.widgetWithText(SnackBar, 'A CONNECTION MESSAGE'),
          findsOneWidget);
      verify(() => goRouterMock.pop()).called(1);
    });

    testWidgets('connection error', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      accessPointConnectionControllerStub.triggerUpdate(
        AsyncError('A simulated error', StackTrace.current),
      );
      await tester.pump();

      expect(
          find.widgetWithText(SnackBar, 'A simulated error'), findsOneWidget);
      verify(() => goRouterMock.pop()).called(1);
    });

    testWidgets('report button', (tester) async {
      createProviderMocks();
      await makeWidget(tester);
      await tester.tap(find.byIcon(Icons.report));
      await tester.pump();
      expect(find.byType(ReportAccessPointDialog), findsOneWidget);
    });
  });
}
