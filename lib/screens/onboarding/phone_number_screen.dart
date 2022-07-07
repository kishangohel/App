import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/sms_code_screen.dart';
import 'package:verifi/screens/onboarding/widgets/account_phone_form_field.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';
import 'package:verifi/widgets/transitions/onboarding_slide_transition.dart';

class PhoneNumberScreen extends StatefulWidget {
  PhoneNumberScreen() : super(key: UniqueKey());

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
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Image.asset('assets/launcher_icon/vf_ios.png'),
        title: const Hero(
          tag: 'verifi-title',
          child: AppTitle(
            fontSize: 48.0,
            textAlign: TextAlign.center,
          ),
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _phoneNumberText(),
            _accountPhoneFormField(),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _phoneNumberText() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(
        seconds: 1,
        milliseconds: 500,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Enter your phone number",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountPhoneFormField() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1, milliseconds: 500),
      child: Align(
        alignment: Alignment.topCenter,
        child: AccountPhoneFormField(
          formKey: formKey,
          phoneController: phoneController,
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
              /* "+${phoneNumber.countryCode} ${phoneNumber.nsn}", */
              "+1 555-333-4444",
            );

            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(seconds: 1),
                transitionsBuilder: onboardingSlideTransition,
                pageBuilder: (BuildContext context, _, __) => SmsCodeScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Visibility(
        visible: submitVisibility,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(seconds: 1, milliseconds: 500),
          child: OutlinedButton(
            onPressed: () => formKey.currentState!.save(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              width: MediaQuery.of(context).size.width * 0.25,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "Submit",
                  style: Theme.of(context).textTheme.button?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                width: 1.0,
                color: Colors.white,
              ),
              primary: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
