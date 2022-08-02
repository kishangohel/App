import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class FinalSetupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FinalSetupScreenState();
}

class _FinalSetupScreenState extends State<FinalSetupScreen> {
  double opacity = 0;
  Color textColor = Colors.black;
  Duration textSpeed = const Duration(milliseconds: 120);
  bool _justKidding = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1, milliseconds: 500),
      () => setState(() => opacity = 1),
    );
    FutureGroup futureGroup = FutureGroup();
    // waits for context to be populated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      futureGroup.add(context.read<ProfileCubit>().createProfile());
      futureGroup.add(Future(() async {
        final photo = context.read<ProfileCubit>().profilePhoto;
        if (photo == null) return;
        PaletteGenerator palette;
        if (photo.contains("http")) {
          palette = await PaletteGenerator.fromImageProvider(
            NetworkImage(photo),
          );
        } else {
          palette = await PaletteGenerator.fromImageProvider(
            AssetImage(photo),
          );
        }
        context.read<ThemeCubit>().updateColors(palette);
      }));
      futureGroup.future.then(
        (List<dynamic> values) {
          sharedPrefs.setOnboardingComplete();
          setState(() {});
        },
        onError: (error) {},
      );
      futureGroup.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
            if (b) setState(() => _justKidding = true);
          },
          isRepeatingAnimation: false,
          animatedTexts: _animatedTexts(),
          onFinished: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false, // remove all routes on stack
            );
          },
        ),
      ),
    );
  }

  List<AnimatedText> _animatedTexts() {
    return [
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
      /* TypewriterAnimatedText( */
      /*   "Building bridge...", */
      /*   cursor: "", */
      /*   speed: textSpeed, */
      /*   textStyle: Theme.of(context).textTheme.headline4?.copyWith( */
      /*         fontWeight: FontWeight.w600, */
      /*         color: textColor, */
      /*       ), */
      /*   textAlign: TextAlign.center, */
      /* ), */
      /* TypewriterAnimatedText( */
      /*   "Caching nearby WiFi...", */
      /*   cursor: "", */
      /*   speed: textSpeed, */
      /*   textStyle: Theme.of(context).textTheme.headline4?.copyWith( */
      /*         fontWeight: FontWeight.w600, */
      /*         color: textColor, */
      /*       ), */
      /*   textAlign: TextAlign.center, */
      /* ), */
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

  Widget _justKiddingText() {
    return Visibility(
      visible: _justKidding,
      child: Text(
        "Just kidding",
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}
