import 'dart:async';

import 'package:phone_form_field/phone_form_field.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';

part 'phone_screen_controller.g.dart';

@riverpod
class PhoneScreenController extends _$PhoneScreenController {
  /// Completer that should get completed once sms code is sent.
  late Completer<bool> _smsCodeSentCompleter;

  @override
  FutureOr<bool> build() => false;

  AuthenticationRepository get authRepository =>
      ref.read(authRepositoryProvider);

  Future<void> requestSmsCode(PhoneNumber phoneNumber) async {
    _smsCodeSentCompleter = Completer<bool>();
    state = const AsyncLoading<bool>();
    ref.read(authRepositoryProvider).requestSmsCode(
          phoneNumber: "+${phoneNumber.countryCode} ${phoneNumber.nsn}",
          onCodeSent: _smsCodeSentCompleter,
        );
    state = await AsyncValue.guard<bool>(() => _smsCodeSentCompleter.future);
  }
}
