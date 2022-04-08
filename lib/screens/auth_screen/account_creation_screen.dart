import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
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
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedOpacity(
                            opacity: opacity,
                            duration:
                                const Duration(seconds: 1, milliseconds: 500),
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
                              child: PhoneFormField(
                                countryCodeStyle:
                                    TextStyle(color: Colors.white),
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(color: Colors.white),
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
                                onSaved: (phoneNumber) {
                                  setState(
                                    () => progressIndicatorVisibility = true,
                                  );
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    setState(
                                      () => progressIndicatorVisibility = false,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Login successful"),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: progressIndicatorVisibility,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 8.0,
                  ),
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
