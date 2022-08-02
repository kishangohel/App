import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:verifi/screens/onboarding/phone_number_screen.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class IntroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  double opacity = 0;
  Color _fontColor = Colors.black;

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
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) _fontColor = Colors.white;
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _introContent(),
            ],
          ),
        ),
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
                    onPressed: () {
                      Navigator.of(context).push(
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
                              PhoneNumberScreen(),
                        ),
                      );
                    },
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
          "Bridging the Universe with the Metaverse",
          maxLines: 2,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4?.copyWith(
                color: _fontColor,
              ),
        ),
      ),
    );
  }

  Widget _verifiDescription() {
    return SizedBox(
      height: 70,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.headline5!,
        textAlign: TextAlign.center,
        child: AnimatedTextKit(
          animatedTexts: [
            RotateAnimatedText(
              "Crowdsourced WiFi",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Powered by Web3",
              textAlign: TextAlign.center,
            ),
            RotateAnimatedText(
              "Internet communities reimagined",
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
