import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';

part 'sms_screen_controller.g.dart';

@riverpod
class SmsScreenController extends _$SmsScreenController {
  @override
  FutureOr<void> build() {}

  AuthenticationRepository get authRepository =>
      ref.read(authRepositoryProvider);

  Future<void> submitSmsCode(String smsCode) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await authRepository.submitSmsCode(smsCode);
    });
  }
}
