import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/access_points/application/access_point_connection_controller.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/data/auto_connect_repository.dart';
import 'package:verifi/src/features/access_points/domain/access_point_model.dart';
import 'package:verifi/src/features/access_points/domain/verified_status.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

import '../../../../test_helper/register_fallbacks.dart';
import '../../../../test_helper/riverpod_test_helper.dart';

class AutoConnectRepositoryMock extends Mock implements AutoConnectRepository {}

class AccessPointRepositoryMock extends Mock implements AccessPointRepository {}

void main() {
  const currentUser = CurrentUser(
    profile: UserProfile(
      id: 'testUserId',
      displayName: 'testUserName',
      hideOnMap: false,
    ),
  );

  final accessPointVerified = AccessPoint(
    id: 'testId',
    location: LatLng(1, 2),
    ssid: 'testSsid',
    submittedBy: 'testSubmittedBy',
    verifiedStatus: VerifiedStatus.verified,
  );

  final accessPointUnverified = AccessPoint(
    id: 'testId',
    location: LatLng(1, 2),
    ssid: 'testSsid',
    submittedBy: 'testSubmittedBy',
    verifiedStatus: VerifiedStatus.unverified,
  );

  late AutoConnectRepositoryMock autoConnectRepositoryMock;
  late AccessPointRepositoryMock accessPointRepositoryMock;

  setUpAll(() {
    registerFallbacks();
  });

  group(AccessPointConnectionController, () {
    riverpodTest<AsyncValue<String?>>(
      'initial state',
      providerListenable: accessPointConnectionControllerProvider,
      act: (container) async {
        await container.read(accessPointConnectionControllerProvider.future);
      },
      expect: [
        const AsyncLoading<String?>(),
        const AsyncData<String?>(null),
      ],
    );

    riverpodTest<AsyncValue<String?>>(
      'connectOrVerify no user logged in',
      providerListenable: accessPointConnectionControllerProvider,
      act: (container) async {
        await container.read(accessPointConnectionControllerProvider.future);
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(accessPointVerified);
      },
      expect: [
        const AsyncLoading<String?>(),
        const AsyncData<String?>(null),
        isA<AsyncLoading<String?>>().having((e) => e.value, 'value', isNull),
        isA<AsyncError<String?>>()
            .having((e) => e.error, 'error', 'Must be logged in'),
      ],
    );

    riverpodTest<AsyncValue<String?>>(
      'connectOrVerify user logged in, error when connecting',
      providerListenable: accessPointConnectionControllerProvider,
      setUp: () {
        autoConnectRepositoryMock = AutoConnectRepositoryMock();
        when(() => autoConnectRepositoryMock.verifyAccessPoint(any()))
            .thenAnswer((_) async => 'An AutoConnect error');
      },
      overrides: () => [
        autoConnectRepositoryProvider
            .overrideWith((ref) => autoConnectRepositoryMock),
        currentUserProvider.overrideWith((ref) => Stream.value(currentUser)),
      ],
      act: (container) async {
        await container.read(accessPointConnectionControllerProvider.future);
        await container.read(currentUserProvider.stream).first; // Skip loading
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(accessPointVerified);
      },
      expect: [
        const AsyncLoading<String?>(),
        const AsyncData<String?>(null),
        isA<AsyncLoading<String?>>().having((e) => e.value, 'value', isNull),
        isA<AsyncError<String?>>()
            .having((e) => e.error, 'error', 'An AutoConnect error'),
      ],
      verify: () {
        verify(() => autoConnectRepositoryMock
            .verifyAccessPoint(accessPointVerified)).called(1);
      },
    );

    riverpodTest<AsyncValue<String?>>(
      'connectOrVerify user logged in, success when connecting',
      providerListenable: accessPointConnectionControllerProvider,
      setUp: () {
        autoConnectRepositoryMock = AutoConnectRepositoryMock();
        when(() => autoConnectRepositoryMock.verifyAccessPoint(any()))
            .thenAnswer((_) async => 'Success');
      },
      overrides: () => [
        autoConnectRepositoryProvider
            .overrideWith((ref) => autoConnectRepositoryMock),
        currentUserProvider.overrideWith((ref) => Stream.value(currentUser)),
      ],
      act: (container) async {
        await container.read(accessPointConnectionControllerProvider.future);
        await container.read(currentUserProvider.stream).first; // Skip loading
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(accessPointVerified);
      },
      expect: [
        const AsyncLoading<String?>(),
        const AsyncData<String?>(null),
        isA<AsyncLoading<String?>>().having((e) => e.value, 'value', isNull),
        const AsyncData<String?>('Connection successful!'),
      ],
      verify: () {
        verify(() => autoConnectRepositoryMock
            .verifyAccessPoint(accessPointVerified)).called(1);
      },
    );

    riverpodTest<AsyncValue<String?>>(
      'connectOrVerify user logged in, success when verifying',
      providerListenable: accessPointConnectionControllerProvider,
      setUp: () {
        autoConnectRepositoryMock = AutoConnectRepositoryMock();
        when(() => autoConnectRepositoryMock.verifyAccessPoint(any()))
            .thenAnswer((_) async => 'Success');
        accessPointRepositoryMock = AccessPointRepositoryMock();
        when(() =>
                accessPointRepositoryMock.networkValidatedByUser(any(), any()))
            .thenAnswer((_) async {});
      },
      overrides: () => [
        autoConnectRepositoryProvider
            .overrideWith((ref) => autoConnectRepositoryMock),
        currentUserProvider.overrideWith((ref) => Stream.value(currentUser)),
        accessPointRepositoryProvider
            .overrideWith((ref) => accessPointRepositoryMock),
      ],
      act: (container) async {
        await container.read(accessPointConnectionControllerProvider.future);
        await container.read(currentUserProvider.stream).first; // Skip loading
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(accessPointUnverified);
      },
      expect: [
        const AsyncLoading<String?>(),
        const AsyncData<String?>(null),
        isA<AsyncLoading<String?>>().having((e) => e.value, 'value', isNull),
        const AsyncData<String?>('Validation successful!'),
      ],
      verify: () {
        verify(() => autoConnectRepositoryMock
            .verifyAccessPoint(accessPointUnverified)).called(1);
        verify(() => accessPointRepositoryMock.networkValidatedByUser(
            accessPointUnverified, currentUser)).called(1);
      },
    );
  });
}
