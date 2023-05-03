import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_screen_controller.dart';

import '../../../../mocks.dart';

void main() {
  ProviderContainer makeProviderContainer(MockAuthRepository authRepository) {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  late Listener<AsyncValue<void>> listener;

  setUpAll(() {
    listener = Listener<AsyncValue<void>>();
    registerFallbackValue(const AsyncLoading<void>());
  });

  group(SmsScreenController, () {
    test(
      """
      Given an SmsScreenController,
      When submitSmsCode is called,
      Then the state should update to be loading and then back to void.
      """,
      () async {
        final authRepository = MockAuthRepository();
        when(() => authRepository.submitSmsCode(any())).thenAnswer((_) {
          return Future.value();
        });

        final container = makeProviderContainer(authRepository);
        container.listen(
          smsScreenControllerProvider,
          listener,
          fireImmediately: true,
        );

        verify(
          () => listener(null, const AsyncData<void>(null)),
        );

        final controller = container.read(smsScreenControllerProvider.notifier);

        await controller.submitSmsCode('123456');

        verifyInOrder([
          () => listener(
                const AsyncData<void>(null),
                any(that: isA<AsyncLoading>()),
              ),
          () => listener(
                any(that: isA<AsyncLoading>()),
                const AsyncData<void>(null),
              ),
        ]);

        verifyNoMoreInteractions(listener);
        verify(() => authRepository.submitSmsCode(any())).called(1);
      },
    );
  });
}
