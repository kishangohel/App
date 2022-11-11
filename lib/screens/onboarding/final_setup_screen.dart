import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class FinalSetupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FinalSetupScreenState();
}

class _FinalSetupScreenState extends State<FinalSetupScreen> {
  double opacity = 0;
  Color textColor = Colors.black;
  Duration textSpeed = const Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1, milliseconds: 500),
      () => setState(() => opacity = 1),
    );
    // waits for context to be populated
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final palette = await context.read<ProfileCubit>().createPaletteFromPfp();
      context.read<ThemeCubit>().updateColors(palette);
      // A simple read will initialize location stream
      context.read<LocationCubit>();
      // futureGroup.add(GeofencingCubit.registerNearbyGeofences());
      // futureGroup.add(
      //   ActivityRecognitionCubit.requestActivityTransitionUpdates(),
      // );
      await sharedPrefs.setOnboardingComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return WillPopScope(
      child: Scaffold(
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.black
                : Colors.white,
        appBar: OnboardingAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              onBoardingBackground(context),
              _newIntroContent(),
            ],
          ),
        ),
      ),
      onWillPop: () async => false,
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
          style: Theme.of(context).textTheme.headlineMedium,
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
          isRepeatingAnimation: false,
          animatedTexts: _animatedTexts(),
          onFinished: () {
            if (sharedPrefs.onboardingComplete) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                // remove all routes on stack
                (route) => false,
              );
            } else {
              showModalBottomSheet(
                backgroundColor: Theme.of(context).colorScheme.surface,
                context: context,
                builder: (context) {
                  return AutoSizeText(
                    "Failed to finish setup. Please close and reopen the app",
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                  );
                },
              );
            }
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
        textStyle: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      TypewriterAnimatedText(
        "Caching nearby WiFi...",
        cursor: "",
        speed: textSpeed,
        textStyle: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    ];
  }
}
