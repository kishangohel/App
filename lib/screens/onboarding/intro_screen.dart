import 'package:flutter/material.dart';
import 'package:verifi/screens/onboarding/phone_number_screen.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class IntroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  double opacity = 0;
  final textColor = Colors.black;

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
              _newIntroContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newIntroContent() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _verifiTitle(),
                  _verifiSubtitle(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getStartedButton(),
              ],
            ),
          ),
        ],
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
          child: AppTitle(
            fontSize: 72,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _verifiSubtitle() {
    return Container(
      alignment: Alignment.topCenter,
      child: SizedBox(
        child: Text(
          "Bridging the Universe with the Metaverse",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _getStartedButton() {
    return OutlinedButton(
        style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(
                  width: 2.0,
                  color: (MediaQuery.of(context).platformBrightness ==
                          Brightness.light)
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
        /* style: OutlinedButton.styleFrom( */
        /*   shape: ContinuousRectangleBorder( */
        /*     borderRadius: BorderRadius.circular(24.0), */
        /*   ), */
        /*   side: const BorderSide(width: 2.0), */
        /*   padding: const EdgeInsets.symmetric( */
        /*     vertical: 12.0, */
        /*     horizontal: 16.0, */
        /*   ), */
        /* ), */
        child: Text(
          "Begin the journey",
          style: Theme.of(context).textTheme.headline5?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration:
                  const Duration(seconds: 1, milliseconds: 500),
              reverseTransitionDuration: const Duration(seconds: 1),
              transitionsBuilder: _slideTransition,
              pageBuilder: (BuildContext context, _, __) =>
                  PhoneNumberScreen(),
            ),
          );
        });
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
