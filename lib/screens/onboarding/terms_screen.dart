import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class TermsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  double opacity = 0;
  Color _textColor = Colors.black;
  bool _termsAccepted = false;
  bool _privacyPolicyAccepted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) _textColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Hero(
          tag: 'verifi-logo',
          child: Image.asset('assets/launcher_icon/vf_ios.png'),
        ),
        title: Hero(
          tag: 'verifi-title',
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            height: kToolbarHeight,
            width: MediaQuery.of(context).size.width * 0.5,
            child: const AppTitle(appBar: true),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _termsScreenContents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _termsScreenContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _headerTitle(),
                  ),
                  _headerSubtitle(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _termsRow(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _privacyPolicyRow(),
                  ),
                  _continueButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerTitle() {
    return AutoSizeText(
      "Terms and Conditions",
      style: Theme.of(context).textTheme.headline3?.copyWith(
            color: _textColor,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _headerSubtitle() {
    return AutoSizeText(
      "Please review and accept the following terms and conditions",
      style: Theme.of(context).textTheme.headline6,
      textAlign: TextAlign.center,
    );
  }

  Widget _termsRow() {
    return Row(
      children: [
        Checkbox(
          activeColor: _textColor,
          checkColor:
              (_textColor == Colors.black) ? Colors.white : Colors.black,
          onChanged: (value) {
            setState(() => _termsAccepted = !_termsAccepted);
          },
          value: _termsAccepted,
        ),
        AutoSizeText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "I accept the ",
                style: Theme.of(context).textTheme.headline6,
              ),
              TextSpan(
                text: "Terms of Use",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("https://verifi.world/terms"));
                  },
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _privacyPolicyRow() {
    return Row(
      children: [
        Checkbox(
          activeColor: _textColor,
          checkColor:
              (_textColor == Colors.black) ? Colors.white : Colors.black,
          onChanged: (value) {
            setState(() => _privacyPolicyAccepted = !_privacyPolicyAccepted);
          },
          value: _privacyPolicyAccepted,
        ),
        AutoSizeText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "I accept the ",
                style: Theme.of(context).textTheme.headline6,
              ),
              TextSpan(
                text: "Privacy Policy",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("https://verifi.world/privacy"));
                  },
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _continueButton() {
    return Visibility(
      visible: _termsAccepted && _privacyPolicyAccepted,
      child: OnboardingOutlineButton(
        text: "Continue",
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding/pfpAvatar',
            (route) => false,
          );
        },
      ),
    );
  }
}
