import 'package:flutter/material.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class ConnectWalletScreen extends StatefulWidget {
  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  double opacity = 0;

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
      body: Container(
        color: Colors.black,
        child: SafeArea(
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
                                duration: const Duration(
                                    seconds: 1, milliseconds: 500),
                                child: ElevatedButton(
                                  onPressed: () => formKey.currentState!.save(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 4.0,
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(
                                        "Submit",
                                        style:
                                            Theme.of(context).textTheme.button,
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
      ),
    );
  }
}
