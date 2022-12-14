import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/src/features/authentication/presentation/sms_code/sms_screen_controller.dart';
import 'package:verifi/src/utils/async_value_ui.dart';

import '../widgets/onboarding_app_bar.dart';

class SmsScreen extends ConsumerStatefulWidget {
  const SmsScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SmsScreenState();
}

class _SmsScreenState extends ConsumerState<SmsScreen> {
  double opacity = 0;
  final formKey = GlobalKey<FormState>();
  final phoneController = PhoneController(null);
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1, milliseconds: 500),
      () {
        if (mounted) setState(() => opacity = 1);
        focusNode.requestFocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // show error if any
    ref.listen<AsyncValue<void>>(
      smsScreenControllerProvider,
      (_, state) {
        state.showSnackbarOnError(context);
      },
    );
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: _onboardingContent(),
    );
  }

  Widget _onboardingContent() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _smsInstructionsText(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _smsPinput(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smsInstructionsText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AutoSizeText(
        'Enter SMS verification code',
        maxLines: 1,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _smsPinput() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Pinput(
        focusNode: focusNode,
        length: 6,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        defaultPinTheme: PinTheme(
          width: MediaQuery.of(context).size.width * 0.12,
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onCompleted: (value) async {
          await ref
              .read(smsScreenControllerProvider.notifier)
              .submitSmsCode(value);
        },
      ),
    );
  }
}
