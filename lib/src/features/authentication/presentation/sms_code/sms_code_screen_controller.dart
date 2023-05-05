import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/firebase_auth_repository.dart';

part '_generated/sms_code_screen_controller.g.dart';

@riverpod
class SmsCodeScreenController extends _$SmsCodeScreenController {
  String? _smsCode;

  @override
  FutureOr<void> build() {
    // do nothing
  }

  void updateSmsCode(String? smsCode) => _smsCode = smsCode;

  Future<void> submitSmsCode() async {
    state = const AsyncLoading<void>();
    await Future<void>.delayed(const Duration(seconds: 1));
    final smsCode = _smsCode;
    if (smsCode == null) {
      state = AsyncError<void>(
        Exception('SMS code is null'),
        StackTrace.current,
      );
      return;
    } else {
      state = await AsyncValue.guard<void>(
        () async => await ref
            .read(firebaseAuthRepositoryProvider)
            .submitSmsCode(smsCode),
      );
    }
  }
}
