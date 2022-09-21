import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

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
      appBar: OnboardingAppBar(),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            ...onBoardingBackground(context),
            _termsScreenContents(),
          ],
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
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _headerSubtitle() {
    return AutoSizeText(
      "Please review and accept the following terms and conditions",
      style: Theme.of(context).textTheme.titleLarge,
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextSpan(
                text: "Terms of Use",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("https://verifi.world/terms"));
                  },
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextSpan(
                text: "Privacy Policy",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.parse("https://verifi.world/privacy"));
                  },
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.onSurface,
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
        onPressed: () async {
          await Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding/pfpAvatar',
            (route) => false,
          );
        },
      ),
    );
  }
}
