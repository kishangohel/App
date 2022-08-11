import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/widgets/account_phone_form_field.dart';
import 'package:verifi/screens/onboarding/widgets/hero_verifi_title.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class PhoneNumberScreen extends StatefulWidget {
  PhoneNumberScreen() : super(key: UniqueKey());

  @override
  createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  double opacity = 0;
  Color textColor = Colors.black;
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
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Hero(
          tag: 'verifi-logo',
          child: Image.asset('assets/launcher_icon/vf_ios.png'),
        ),
        title: HeroVerifiTitle(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ...onBoardingBackground(context),
            _onboardingContent(),
          ],
        ),
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
                padding: const EdgeInsets.only(bottom: 24.0),
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
            style: Theme.of(context).textTheme.headline4?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
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
        textColor: textColor,
        onChanged: (PhoneNumber? number) {
          setState(() {
            submitVisibility = phoneController.value != null &&
                phoneController.value!.validate(
                  type: PhoneNumberType.mobile,
                );
          });
        },
        onSaved: (phoneNumber) {
          BlocProvider.of<AuthenticationCubit>(context).requestSmsCode(
            "+${phoneNumber.countryCode} ${phoneNumber.nsn}",
            // "+1 555-333-4444",
          );
          Navigator.of(context).pushNamed('/onboarding/sms');
        },
      ),
    );
  }

  Widget _submitButton() {
    return Visibility(
      visible: submitVisibility,
      maintainSize: false,
      maintainAnimation: true,
      maintainState: true,
      child: OnboardingOutlineButton(
        onPressed: () => formKey.currentState!.save(),
        text: "Submit",
      ),
    );
  }
}
