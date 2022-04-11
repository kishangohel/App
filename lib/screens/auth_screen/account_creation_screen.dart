import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/widgets/text/app_title.dart';

class AccountCreationScreen extends StatefulWidget {
  @override
  createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  double opacity = 0;
  bool progressIndicatorVisibility = false;

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
            Hero(
              tag: 'enter-the-metaverse',
              child: Image.asset(
                'assets/enter_the_metaverse.gif',
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fitHeight,
              ),
            ),
            Hero(
              tag: 'enter-the-metaverse-filter',
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedOpacity(
                            opacity: opacity,
                            duration: const Duration(
                              seconds: 1,
                              milliseconds: 500,
                            ),
                            child: const FittedBox(
                              alignment: Alignment.bottomCenter,
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
                        Expanded(
                          child: AnimatedOpacity(
                            opacity: opacity,
                            duration:
                                const Duration(seconds: 1, milliseconds: 500),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: _AccountPhoneFormField(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BlocBuilder<AuthenticationCubit, AuthenticationState>(
                  builder: (context, state) {
                    return Text("Verifying...");
                  },
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
  @override
  State<StatefulWidget> createState() => _AccountPhoneFormFieldState();
}

class _AccountPhoneFormFieldState extends State<_AccountPhoneFormField> {
  final formKey = GlobalKey<FormState>();
  late PhoneController phoneController;

  @override
  void initState() {
    super.initState();
    phoneController = PhoneController(null);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: PhoneFormField(
        controller: phoneController,
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
        onSaved: (phoneNumber) {
          print(phoneNumber!.nsn);
          print(phoneNumber.countryCode);
          BlocProvider.of<AuthenticationCubit>(context).signUpPhoneNumber(
            /* "+${phoneNumber.countryCode} ${phoneNumber.nsn}", */
            "+1 555-333-4444",
            context,
          );
        },
        onSubmitted: (phoneNumber) {
          if (phoneController.value != null &&
              phoneController.value!.validate(
                type: PhoneNumberType.mobile,
              )) {
            formKey.currentState!.save();
          }
        },
      ),
    );
  }
}
