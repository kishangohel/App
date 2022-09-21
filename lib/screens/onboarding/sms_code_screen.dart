import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/shared_prefs.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class SmsCodeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends State<SmsCodeScreen> {
  double opacity = 0;
  Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (mounted) setState(() => opacity = 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthenticationCubit, AuthenticationState>(
            listener: (context, authState) {
              if (authState.exception != null) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _modalSheetError(context, authState),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                );
              }
              if (authState.user != null) {
                // will emit a new Profile state, which is handled by the
                // ProfileCubit bloc listener
                context.read<ProfileCubit>().getProfile(authState.user!.uid);
              }
            },
          ),
          BlocListener<ProfileCubit, Profile>(
            listener: (context, profile) {
              // if user already visited permissions page before, skip
              if (sharedPrefs.permissionsComplete) {
                // if account already exists, finish setup
                // Otherwise, skip permissions and complete onboarding
                // In all cases, if user presses back, return to IntroScreen
                if (profile.displayName == null) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/onboarding/readyWeb3',
                    ModalRoute.withName('onboarding/'),
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/onboarding/finalSetup',
                    ModalRoute.withName('onboarding/'),
                  );
                }
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/onboarding/permissions',
                  ModalRoute.withName('onboarding/'),
                );
              }
            },
          ),
        ],
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                ...onBoardingBackground(context),
                _smsCodeScreenContents(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smsCodeScreenContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _smsInstructionsText(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _smsPinput(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smsInstructionsText() {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: AutoSizeText(
        'Enter SMS verification code',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: 48.0,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _smsPinput() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Pinput(
        length: 6,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        defaultPinTheme: PinTheme(
          width: MediaQuery.of(context).size.width * 0.12,
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          textStyle: TextStyle(
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: textColor,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onCompleted: (String pin) {
          context.read<AuthenticationCubit>().submitSmsCode(pin);
        },
      ),
    );
  }

  Widget _modalSheetError(BuildContext context, AuthenticationState state) {
    return Container(
      height: 80.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Center(
        child: AutoSizeText(
          state.exception?.code.toString() ?? 'Failed to authenticate',
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 18,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
