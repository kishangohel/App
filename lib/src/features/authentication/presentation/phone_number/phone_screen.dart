import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/src/routing/app_router.dart';
import 'package:verifi/src/utils/async_value_ui.dart';

import 'account_phone_form_field.dart';
import 'phone_screen_controller.dart';
import '../widgets/onboarding_app_bar.dart';
import '../widgets/onboarding_outline_button.dart';

class PhoneScreen extends StatelessWidget {
  static const submitButtonKey = Key('submit-button');
  const PhoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: PhoneScreenContent(),
    );
  }
}

class PhoneScreenContent extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PhoneScreenContentState();
}

class _PhoneScreenContentState extends ConsumerState<PhoneScreenContent> {
  double opacity = 0;
  final formKey = GlobalKey<FormState>();
  bool _canSubmit = false;
  final phoneController = PhoneController(null);

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1, milliseconds: 500),
      () {
        if (mounted) setState(() => opacity = 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(
      phoneScreenControllerProvider,
      (_, state) {
        state.showSnackbarOnError(context);
        if (state.asData?.value == true) {
          context.pushNamed(AppRoute.sms.name);
        }
      },
    );
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
                  _enterPhoneNumberText(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _accountPhoneFormField(),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enterPhoneNumberText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Enter your phone number",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _accountPhoneFormField() {
    return Align(
      alignment: Alignment.topCenter,
      child: PhoneScreenPhoneFormField(
        phoneController: phoneController,
        // enable submit button only when phone number is valid
        onChanged: (PhoneNumber? number) {
          setState(() {
            _canSubmit = phoneController.value != null &&
                phoneController.value!.isValid(
                  type: PhoneNumberType.mobile,
                );
          });
        },
      ),
    );
  }

  Widget _submitButton() {
    final state = ref.watch(phoneScreenControllerProvider);
    return Visibility(
      visible: _canSubmit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: OnboardingOutlineButton(
          key: PhoneScreen.submitButtonKey,
          onPressed: () async {
            // do nothing if loading
            if (state.isLoading) return;
            await ref
                .read(phoneScreenControllerProvider.notifier)
                .requestSmsCode(phoneController.value!);
          },
          child: state.when<Widget>(
            data: (_) => const AutoSizeText('Submit'),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => const AutoSizeText('Submit'),
          ),
        ),
      ),
    );
  }
}
