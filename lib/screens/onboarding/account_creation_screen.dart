import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/sms_code_screen.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';
import 'package:verifi/widgets/transitions/onboarding_slide_transition.dart';

class AccountCreationScreen extends StatefulWidget {
  AccountCreationScreen() : super(key: UniqueKey());

  @override
  createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
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
            Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
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
                        ),
                        AnimatedOpacity(
                          opacity: opacity,
                          duration:
                              const Duration(seconds: 1, milliseconds: 500),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _AccountPhoneFormField(
                              formKey: formKey,
                              phoneController: phoneController,
                              onChanged: (PhoneNumber? number) {
                                setState(() {
                                  submitVisibility =
                                      phoneController.value != null &&
                                          phoneController.value!.validate(
                                            type: PhoneNumberType.mobile,
                                          );
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Visibility(
                            visible: submitVisibility,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: AnimatedOpacity(
                              opacity: opacity,
                              duration:
                                  const Duration(seconds: 1, milliseconds: 500),
                              child: ElevatedButton(
                                onPressed: () => formKey.currentState!.save(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 4.0,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      "Submit",
                                      style: Theme.of(context).textTheme.button,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountPhoneFormField extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final PhoneController phoneController;
  final void Function(PhoneNumber? number) onChanged;
  const _AccountPhoneFormField({
    required this.formKey,
    required this.phoneController,
    required this.onChanged,
  });
  @override
  State<StatefulWidget> createState() => _AccountPhoneFormFieldState();
}

class _AccountPhoneFormFieldState extends State<_AccountPhoneFormField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: PhoneFormField(
        controller: widget.phoneController,
        flagSize: 18.0,
        countrySelectorNavigator: CountrySelectorNavigator.modalBottomSheet(
          height: MediaQuery.of(context).size.height * 0.7,
        ),
        countryCodeStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          errorStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        validator: PhoneValidator.validMobile(),
        autovalidateMode: AutovalidateMode.always,
        onChanged: widget.onChanged,
        onSaved: (phoneNumber) {
          assert(phoneNumber != null);
          BlocProvider.of<AuthenticationCubit>(context).signUpPhoneNumber(
            "+${phoneNumber!.countryCode} ${phoneNumber.nsn}",
            /* "+1 555-333-4444", */
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
        onSubmitted: (phoneNumber) {
          if (widget.phoneController.value != null &&
              widget.phoneController.value!.validate(
                type: PhoneNumberType.mobile,
              )) {
            widget.formKey.currentState!.save();
          }
        },
      ),
    );
  }
}
