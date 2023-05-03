import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen_controller.dart';

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

  late Completer<bool> smsCodeSentCompleter;
  late PhoneNumber phoneNumber;
  late Listener<AsyncValue<bool>> listener;

  setUpAll(() {
    smsCodeSentCompleter = Completer<bool>();
    phoneNumber = PhoneNumber.parse('+16505553434');
    listener = Listener<AsyncValue<bool>>();
    registerFallbackValue(const AsyncLoading<bool>());
    registerFallbackValue(phoneNumber);
    registerFallbackValue(smsCodeSentCompleter);
  });

  group(PhoneScreenController, () {
    test(
      """
      Given a PhoneScreenController
      When the user enters a valid phone number
      Then the state should be AsyncData(true)
      """,
      () async {
        final authRepository = MockAuthRepository();
        when(() => authRepository.requestSmsCode(
              phoneNumber: any(named: 'phoneNumber'),
              onCodeSent: any(named: 'onCodeSent'),
            )).thenAnswer((_) {
          smsCodeSentCompleter.complete(true);
          return Future.value();
        });

        final container = makeProviderContainer(authRepository);
        container.listen(
          phoneScreenControllerProvider,
          listener,
          fireImmediately: true,
        );

        verify(
          () => listener(null, const AsyncData<bool>(false)),
        );

        final controller =
            container.read(phoneScreenControllerProvider.notifier);

        controller.onCodeSent = smsCodeSentCompleter;
        await controller.requestSmsCode(phoneNumber);

        verifyInOrder([
          () => listener(
                const AsyncData<bool>(false),
                any(that: isA<AsyncLoading>()),
              ),
          () => listener(
                any(that: isA<AsyncLoading>()),
                const AsyncData<bool>(true),
              ),
        ]);
        verifyNoMoreInteractions(listener);
        verify(() => authRepository.requestSmsCode(
              phoneNumber: any(named: 'phoneNumber'),
              onCodeSent: any(named: 'onCodeSent'),
            )).called(1);
      },
    );
  });
}
