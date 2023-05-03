import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/access_points/application/access_point_connection_controller.dart';
import 'package:verifi/src/features/access_points/data/access_point_repository.dart';
import 'package:verifi/src/features/access_points/data/auto_connect_repository.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../../../test_helper/register_fallbacks.dart';
import '../../../mocks.dart';
import '../../profile/helper.dart';
import '../helper.dart';

void main() {
  ProviderContainer makeProviderContainer(
    AccessPointRepository accessPointRepository,
    AuthenticationRepository authRepository,
    AutoConnectRepository autoConnectRepository,
    StreamController<CurrentUser?> currentUserStreamController,
  ) {
    final container = ProviderContainer(
      overrides: [
        accessPointRepositoryProvider.overrideWithValue(accessPointRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
        autoConnectRepositoryProvider.overrideWithValue(autoConnectRepository),
        currentUserProvider.overrideWith(
          (ref) => currentUserStreamController.stream,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void verifyInitialState(Listener<AsyncValue<String?>> listener) {
    verifyInOrder([
      () => listener(
            null,
            const AsyncLoading<String?>(),
          ),
      () => listener(
            const AsyncLoading<String?>(),
            const AsyncData<String?>(null),
          ),
    ]);
  }

  group(AccessPointConnectionController, () {
    late AccessPointRepository accessPointRepository;
    late AuthenticationRepository authRepository;
    late AutoConnectRepository autoConnectRepository;
    late StreamController<CurrentUser?> currentUserStreamController;
    late Listener<AsyncValue<String?>> listener;
    late ProviderContainer container;

    setUpAll(() {
      registerFallbacks();
      registerFallbackValue(const AsyncLoading<String?>());
    });

    setUp(() {
      accessPointRepository = MockAccessPointRepository();
      authRepository = MockAuthRepository();
      autoConnectRepository = MockAutoConnectRepository();
      currentUserStreamController = StreamController<CurrentUser?>();
      listener = Listener<AsyncValue<String?>>();
      container = makeProviderContainer(
        accessPointRepository,
        authRepository,
        autoConnectRepository,
        currentUserStreamController,
      );
      container.listen(
        accessPointConnectionControllerProvider,
        listener,
        fireImmediately: true,
      );
    });

    test('''
      When AccessPointConnectionController state is first built,
      Then the initial state is null.
      ''', () async {
      verifyInitialState(listener);
    });

    test(
      '''
      Given an AccessPointConnectionController that has a null state,
        and no user is currently signed in,
      When connectOrVerify is called,
      Then an Exception is thrown and the state is AsyncError.
      ''',
      () async {
        // Arrange
        verifyInitialState(listener);
        expect(container.read(currentUserProvider).value, isNull);
        // Act
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(verifiedAccessPoint);
        // Assert
        verifyInOrder([
          () => listener(
                const AsyncData<String?>(null),
                any(that: isA<AsyncLoading>()),
              ),
          () => listener(
                any(that: isA<AsyncLoading>()),
                any(that: isA<AsyncError>()),
              ),
        ]);
      },
    );

    test(
      '''
      Given an AccessPointConnectionController that has a null state,
        and a user that is signed in,
      When connectOrVerify is called,
        and `authConnectRepository.connectToAccessPoint` fails,
      Then an Exception is thrown and the state is AsyncError.
      ''',
      () async {
        // Arrange
        verifyInitialState(listener);
        expect(container.read(currentUserProvider).value, isNull);
        currentUserStreamController.add(
          CurrentUser(profile: userProfileWithUsage),
        );
        // wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(currentUserProvider).value, isNotNull);
        when(
          () => autoConnectRepository.connectToAccessPoint(verifiedAccessPoint),
        ).thenAnswer((_) => Future.value('Failure'));
        // Act
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(verifiedAccessPoint);
        // Assert
        verifyInOrder([
          () => listener(
                const AsyncData<String?>(null),
                any(that: isA<AsyncLoading>()),
              ),
          () => listener(
                any(that: isA<AsyncLoading>()),
                any(that: isA<AsyncError>()),
              ),
        ]);
      },
    );

    test(
      '''
      Given an AccessPointConnectionController that has a null state,
        and a user that is signed in,
      When connectOrVerify is called with a verified access point,
        and `authConnectRepository.connectToAccessPoint` succeeds,
      Then state is set to 'Connection successful!'.
      ''',
      () async {
        // Arrange
        verifyInitialState(listener);
        expect(container.read(currentUserProvider).value, isNull);
        currentUserStreamController.add(
          CurrentUser(profile: userProfileWithUsage),
        );
        // wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(currentUserProvider).value, isNotNull);
        when(
          () => autoConnectRepository.connectToAccessPoint(verifiedAccessPoint),
        ).thenAnswer((_) => Future.value('Success'));
        // Act
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(verifiedAccessPoint);
        // Assert
        verifyInOrder([
          () => listener(
                const AsyncData<String?>(null),
                any(that: isA<AsyncLoading>()),
              ),
          () => listener(
                any(that: isA<AsyncLoading>()),
                const AsyncData<String?>('Connection successful!'),
              ),
        ]);
      },
    );

    test(
      '''
      Given an AccessPointConnectionController that has a null state,
        and a user that is signed in,
      When connectOrVerify is called with an unverified access point,
        and `authConnectRepository.connectToAccessPoint` succeeds,
      Then state is set to 'Validation successful!'.
      ''',
      () async {
        // Arrange
        verifyInitialState(listener);
        expect(container.read(currentUserProvider).value, isNull);
        currentUserStreamController.add(
          CurrentUser(profile: userProfileWithUsage),
        );
        // wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));
        expect(container.read(currentUserProvider).value, isNotNull);
        when(
          () =>
              autoConnectRepository.connectToAccessPoint(unverifiedAccessPoint),
        ).thenAnswer((_) => Future.value('Success'));
        when(
          () => accessPointRepository.networkValidatedByUser(any(), any()),
        ).thenAnswer((_) => Future.value(null));
        // Act
        await container
            .read(accessPointConnectionControllerProvider.notifier)
            .connectOrVerify(unverifiedAccessPoint);
        // Assert
        verifyInOrder([
          () => listener(
                const AsyncData<String?>(null),
                any(that: isA<AsyncLoading>()),
              ),
          () => listener(
                any(that: isA<AsyncLoading>()),
                const AsyncData<String?>('Validation successful!'),
              ),
        ]);
      },
    );
  });
}
