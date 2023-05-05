import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/bottom_button.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_code_screen_controller.dart';

class SmsCodeSubmitButton extends ConsumerStatefulWidget {
  const SmsCodeSubmitButton({super.key});

  @override
  ConsumerState<SmsCodeSubmitButton> createState() =>
      _SmsCodeSubmitButtonState();
}

class _SmsCodeSubmitButtonState extends ConsumerState<SmsCodeSubmitButton> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smsCodeScreenControllerProvider);
    return BottomButton(
      onPressed: state.isLoading
          ? null
          : () async => await ref
              .read(smsCodeScreenControllerProvider.notifier)
              .submitSmsCode(),
      text: 'Confirm & Continue',
      isLoading: state.isLoading,
    );
  }
}
