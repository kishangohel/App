import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/connect_wallet_screen.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class SmsCodeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SmsCodeScreenState();
}

class _SmsCodeScreenState extends State<SmsCodeScreen> {
  double opacity = 0;

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
    return Scaffold(
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
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                transitionDuration:
                    const Duration(seconds: 1, milliseconds: 500),
                reverseTransitionDuration: const Duration(seconds: 1),
                transitionsBuilder: _slideTransition,
                pageBuilder: (BuildContext context, _, __) =>
                    ConnectWalletScreen(),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                ...onBoardingBackground(context),
                _smsCodeScreenContents(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smsCodeScreenContents(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.fitWidth,
            child: AutoSizeText(
              'Enter SMS verification code',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 48.0,
                    color: Colors.white,
                  ),
            ),
          ),
          Padding(
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
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onCompleted: (String pin) {
                /* context.read<AuthenticationCubit>().submitSmsCode(pin); */
                context.read<AuthenticationCubit>().submitSmsCode("941555");
              },
            ),
          ),
        ],
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
