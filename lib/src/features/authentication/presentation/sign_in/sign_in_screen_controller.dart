import 'dart:async';

import 'package:phone_form_field/phone_form_field.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';

part '_generated/sign_in_screen_controller.g.dart';

@riverpod
class SignInScreenController extends _$SignInScreenController {
  Completer<bool> onCodeSentCompleter = Completer<bool>();
  PhoneNumber? _phoneNumber;

  @override
  FutureOr<bool> build() => false;

  void updatePhoneNumber(PhoneNumber? phoneNumber) =>
      _phoneNumber = phoneNumber;

  void requestSmsCode() async {
    state = const AsyncLoading<bool>();
    if (_phoneNumber == null) {
      state = AsyncError<bool>(
        Exception('Phone number is null'),
        StackTrace.current,
      );
      return;
    }
    ref.read(firebaseAuthRepositoryProvider).requestSmsCode(
          phoneNumber: '+${_phoneNumber!.countryCode} ${_phoneNumber!.nsn}',
          onCodeSentCompleter: onCodeSentCompleter,
        );
    state = await AsyncValue.guard<bool>(
      () async => onCodeSentCompleter.future,
    );
    // reset completer
    onCodeSentCompleter = Completer<bool>();
  }
}
