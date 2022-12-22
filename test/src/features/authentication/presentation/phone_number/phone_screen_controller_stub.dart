import 'dart:async';

import 'package:phone_form_field/phone_form_field.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/presentation/phone_number/phone_screen_controller.dart';

/// A stub which facilitates testing of widgets which rely on this
/// AsyncNotifier. Ideally we would be able to stub the initial value and
/// trigger subsequent notifications without a dedicated stub but right now this
/// is not possible.
class PhoneScreenControllerStub extends PhoneScreenController {
  FutureOr<bool>? _initialValue;
  FutureOr<bool>? _stubbedSmsCodeResult;

  @override
  FutureOr<bool> build() async {
    // A future that never finishes to simulate loading.
    return _initialValue ?? Completer<bool>().future;
  }

  void setInitialValue(FutureOr<bool> initialValue) {
    _initialValue = initialValue;
  }

  void triggerUpdate(AsyncValue<bool> newState) {
    state = newState;
  }

  @override
  Future<void> requestSmsCode(PhoneNumber phoneNumber) async {
    state = const AsyncLoading<bool>();
    state =
        await AsyncValue.guard<bool>(() async => await _stubbedSmsCodeResult!);
  }

  void stubSmsCodeResult(FutureOr<bool> result) {
    _stubbedSmsCodeResult = result;
  }
}
