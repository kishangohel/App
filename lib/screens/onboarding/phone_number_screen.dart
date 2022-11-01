import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/widgets/account_phone_form_field.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  double opacity = 0;
  bool submitVisibility = false;
  bool progressIndicatorVisibility = false;
  final formKey = GlobalKey<FormState>();
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
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: Stack(
        children: [
          ...onBoardingBackground(context),
          _onboardingContent(),
        ],
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _phoneNumberText(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisAlignment: (submitVisibility)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
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

  Widget _phoneNumberText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Enter your phone number\nto authenticate",
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
      child: AccountPhoneFormField(
        formKey: formKey,
        phoneController: phoneController,
        onChanged: (PhoneNumber? number) {
          setState(() {
            submitVisibility = phoneController.value != null &&
                phoneController.value!.isValid(
                  type: PhoneNumberType.mobile,
                );
          });
        },
        onSaved: (phoneNumber) async {
          BlocProvider.of<AuthenticationCubit>(context).requestSmsCode(
            "+${phoneNumber.countryCode} ${phoneNumber.nsn}",
          );
          await Navigator.of(context).pushNamed('/onboarding/sms');
        },
      ),
    );
  }

  Widget _submitButton() {
    return Visibility(
      visible: submitVisibility,
      maintainAnimation: true,
      maintainState: true,
      maintainSize: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: OnboardingOutlineButton(
          onPressed: () async => formKey.currentState!.save(),
          text: "Submit",
        ),
      ),
    );
  }
}
