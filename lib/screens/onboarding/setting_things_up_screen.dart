import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class SettingThingsUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingThingsUpScreenState();
}

class _SettingThingsUpScreenState extends State<SettingThingsUpScreen> {
  double opacity = 0;
  Color textColor = Colors.black;
  Duration textSpeed = const Duration(milliseconds: 120);
  bool justKidding = false;

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
    if (brightness == Brightness.dark) textColor = Colors.white;
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _settingThingsUpTop(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _settingThingsUpBottom(),
                _justKiddingText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingThingsUpTop() {
    return Container(
      alignment: Alignment.topCenter,
      child: SizedBox(
        child: Text(
          "Finishing Setup",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
        ),
      ),
    );
  }

  Widget _settingThingsUpBottom() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: AnimatedTextKit(
          onNextBeforePause: (i, b) {
            if (b) {
              setState(
                () => justKidding = true,
              );
            }
          },
          isRepeatingAnimation: false,
          animatedTexts: _animatedTexts(),
        ),
      ),
    );
  }

  Widget _justKiddingText() {
    return Visibility(
      visible: justKidding,
      child: Text(
        "Just kidding",
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }

  List<AnimatedText> _animatedTexts() {
    return [
      TypewriterAnimatedText(
        "Creating new user...",
        cursor: "",
        speed: textSpeed,
        textStyle: Theme.of(context).textTheme.headline4?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
        textAlign: TextAlign.center,
      ),
      TypewriterAnimatedText(
        "Injecting color pallette...",
        cursor: "",
        speed: textSpeed,
        textStyle: Theme.of(context).textTheme.headline4?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
        textAlign: TextAlign.center,
      ),
      TypewriterAnimatedText(
        "Building bridge...",
        cursor: "",
        speed: textSpeed,
        textStyle: Theme.of(context).textTheme.headline4?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
        textAlign: TextAlign.center,
      ),
      TypewriterAnimatedText(
        "Caching nearby WiFi...",
        cursor: "",
        speed: textSpeed,
        textStyle: Theme.of(context).textTheme.headline4?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
        textAlign: TextAlign.center,
      ),
      TypewriterAnimatedText(
        "Installing bitcoin miner...",
        cursor: "",
        speed: textSpeed,
        textStyle: Theme.of(context).textTheme.headline4?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
        textAlign: TextAlign.center,
      ),
    ];
  }
}
