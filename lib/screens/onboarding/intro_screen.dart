import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:verifi/screens/onboarding/phone_number_screen.dart';
import 'package:verifi/screens/onboarding/widgets/app_title.dart';
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
      body: Stack(
        children: [
          ...onBoardingBackground(context),
          _introContent(),
        ],
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
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
      height: 90,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleLarge!,
        textAlign: TextAlign.center,
        child: AnimatedTextKit(
          animatedTexts: [
            RotateAnimatedText(
              "Automatically connect to WiFi anywhere in the world",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Web2 and Web3 incentives, powered by Proof of Connection",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Unleashing digital communities into the physical world",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Bridging the Universe with the Metaverse",
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
