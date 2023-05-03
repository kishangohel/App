import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_code_screen_controller.dart';

class SmsCodeInputTextField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      enableActiveFill: false,
      autoFocus: true,
      showCursor: true,
      animationType: AnimationType.scale,
      cursorColor: Theme.of(context).colorScheme.primary,
      obscureText: false,
      hintCharacter: '-',
      pinTheme: PinTheme(
        fieldHeight: 50,
        fieldWidth: 50,
        borderWidth: 2,
        borderRadius: BorderRadius.circular(12),
        shape: PinCodeFieldShape.box,
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: Theme.of(context).colorScheme.outline.withOpacity(0.6),
        selectedColor: Theme.of(context).colorScheme.outline,
        activeFillColor: Theme.of(context).colorScheme.primary,
        inactiveFillColor: Theme.of(context).colorScheme.onSecondary,
        selectedFillColor: Theme.of(context).colorScheme.onSecondary,
      ),
      onChanged: (String code) => ref
          .read(smsCodeScreenControllerProvider.notifier)
          .updateSmsCode(code),
      keyboardType: TextInputType.number,
    );
  }
}
