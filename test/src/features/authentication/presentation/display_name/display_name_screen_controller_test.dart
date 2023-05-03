import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/display_name/display_name_screen_controller.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

import '../../mocks.dart';

void main() {
  ProviderContainer makeProviderContainer(
    ProfileRepository profileRepository,
    AuthenticationRepository authRepository,
  ) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  late Listener<AsyncValue<void>> listener;

  setUpAll(() {
    listener = Listener<AsyncValue<String?>>();
    registerFallbackValue(const AsyncLoading<String?>());
  });

  group(DisplayNameScreenController, () {
    test(
      """
      Given a DisplayNameScreenController,
      When submitDisplayName is called
      and ProfileRepository.validateDisplayNamed returns an error string,
      Then state should update to be that error string.
      """,
      () async {
        final profileRepository = MockProfileRepository();
        final authRepository = MockAuthRepository();
        when(
          () => profileRepository.validateDisplayName(any()),
        ).thenAnswer((_) async => 'Invalid display name');

        final container = makeProviderContainer(
          profileRepository,
          authRepository,
        );
        container.listen(
          displayNameScreenControllerProvider,
          listener,
          fireImmediately: true,
        );

        verify(
          () => listener(null, const AsyncData<String?>(null)),
        );

        final controller = container.read(
          displayNameScreenControllerProvider.notifier,
        );

        await controller.submitDisplayName('not-valid');

        verifyInOrder(
          [
            () => listener(
                  const AsyncData<String?>(null),
                  any(that: isA<AsyncLoading<String?>>()),
                ),
            () => listener(
                  any(that: isA<AsyncLoading<String?>>()),
                  const AsyncData<String?>('Invalid display name'),
                ),
          ],
        );

        verifyNoMoreInteractions(listener);
        verify(
          () => profileRepository.validateDisplayName(any()),
        ).called(1);
      },
    );

    test(
      """
      Given a DisplayNameScreenController,

      When submitDisplayName is called
      and ProfileRepository.validateDisplayName returns an empty string,

      Then ProfileRepository.createUserProfile should be called
      with the userId of the current user from AuthenticationRepository
      and AuthenticationRepository.updateDisplayName should be called
      and the state of the controller should be set to null.
      """,
      () async {
        final profileRepository = MockProfileRepository();
        final authRepository = MockAuthRepository();

        when(
          () => profileRepository.validateDisplayName(any()),
        ).thenAnswer((_) async => null);

        when(
          () => profileRepository.createUserProfile(
            userId: any(named: 'userId'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) => Future.value());

        when(
          () => authRepository.currentUser,
        ).thenReturn(
          MockUser(uid: 'fake-user'),
        );

        when(
          () => authRepository.updateDisplayName(any()),
        ).thenAnswer((_) => Future.value());

        final container = makeProviderContainer(
          profileRepository,
          authRepository,
        );
        container.listen(
          displayNameScreenControllerProvider,
          listener,
          fireImmediately: true,
        );

        verify(
          () => listener(null, const AsyncData<String?>(null)),
        );

        final controller = container.read(
          displayNameScreenControllerProvider.notifier,
        );

        await controller.submitDisplayName('not-valid');

        verifyInOrder(
          [
            () => listener(
                  const AsyncData<String?>(null),
                  any(that: isA<AsyncLoading<String?>>()),
                ),
            () => listener(
                  any(that: isA<AsyncLoading<String?>>()),
                  const AsyncData<String?>(null),
                ),
          ],
        );

        verifyNoMoreInteractions(listener);

        verify(
          () => profileRepository.validateDisplayName(any()),
        ).called(1);

        verify(
          () => profileRepository.createUserProfile(
            userId: any(named: 'userId'),
            displayName: any(named: 'displayName'),
          ),
        ).called(1);

        verify(
          () => authRepository.updateDisplayName(any()),
        ).called(1);
      },
    );
  });
}
