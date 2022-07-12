import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/connect_wallet_screen.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';
import 'package:verifi/widgets/transitions/onboarding_slide_transition.dart';

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
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Hero(
          tag: 'verifi-logo',
          child: Image.asset('assets/launcher_icon/vf_ios.png'),
        ),
        title: const Hero(
          tag: 'verifi-title',
          child: AppTitle(
            fontSize: 48.0,
            textAlign: TextAlign.center,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state.exception != null) {
            showModalBottomSheet(
              context: context,
              builder: (context) => _modalSheetError(context, state),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            );
          }
          if (state.user != null) {
            Navigator.of(context).pushNamed('/onboarding/wallet');
          }
        },
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
          /* context.read<AuthenticationCubit>().submitSmsCode(pin); */
          context.read<AuthenticationCubit>().submitSmsCode("941555");
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
          state.exception?.message.toString() ?? 'Failed to authenticate',
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 18,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
