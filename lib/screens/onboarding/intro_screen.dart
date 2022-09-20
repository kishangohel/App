import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:verifi/screens/onboarding/phone_number_screen.dart';
import 'package:verifi/screens/onboarding/widgets/app_title.dart';
import 'package:verifi/screens/onboarding/widgets/double_back_warning_snackbar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<StatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  double opacity = 0;

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
      body: DoubleBackToCloseApp(
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _introContent(),
            ],
          ),
        ),
        snackBar: doubleBackWarningSnackBar(context),
      ),
    );
  }

  Widget _introContent() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Container(
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
                  _verifiTitle(),
                  _verifiSubtitle(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _verifiDescription(),
                  ),
                  OnboardingOutlineButton(
                    text: "Get Started",
                    onPressed: () async => await Navigator.of(context).push(
                      PageRouteBuilder(
                        settings: const RouteSettings(
                          name: '/onboarding/phone',
                        ),
                        transitionDuration: const Duration(
                          seconds: 1,
                          milliseconds: 500,
                        ),
                        reverseTransitionDuration: const Duration(
                          seconds: 1,
                        ),
                        transitionsBuilder: _slideTransition,
                        pageBuilder: (BuildContext context, _, __) =>
                            const PhoneNumberScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifiTitle() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: const Hero(
          tag: 'verifi-title',
          child: AppTitle(),
        ),
      ),
    );
  }

  Widget _verifiSubtitle() {
    return Container(
      alignment: Alignment.topCenter,
      child: SizedBox(
        child: AutoSizeText(
          "Connect Without Limits",
          maxLines: 2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }

  Widget _verifiDescription() {
    return SizedBox(
      height: 70,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleLarge!,
        textAlign: TextAlign.center,
        child: AnimatedTextKit(
          animatedTexts: [
            RotateAnimatedText(
              "Fully automated WiFi access",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Powered by Web3 incentives",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Digital communities reimagined",
              textAlign: TextAlign.center,
            ),
          ],
          repeatForever: true,
        ),
      ),
    );
  }

  SlideTransition _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    final tween = Tween(begin: begin, end: end);
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  }
}
