import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/bottom_button.dart';
import 'package:verifi/src/features/authentication/presentation/sign_in/sign_in_screen_controller.dart';

class SignInSubmitButton extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  const SignInSubmitButton({required this.formKey});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SignInSubmitButtonState();
}

class _SignInSubmitButtonState extends ConsumerState<SignInSubmitButton> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInScreenControllerProvider);
    return BottomButton(
      onPressed: state.isLoading
          ? null
          : () => ref
              .read(signInScreenControllerProvider.notifier)
              .requestSmsCode(),
      text: 'Submit',
      isLoading: state.isLoading,
    );
  }
}
