import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pinput/pinput.dart';
import 'package:verifi/blocs/blocs.dart';
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
          showModalBottomSheet(
            context: context,
            builder: (context) => _modalSheetError(context, state),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          );
        },
        listenWhen: (previous, current) => current.exception != null,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                ...onBoardingBackground(context),
                AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(seconds: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: AutoSizeText(
                          'Enter SMS verification code',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                          onCompleted: (String pin) => context
                              .read<AuthenticationCubit>()
                              .submitSmsCode(pin),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
