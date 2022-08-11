import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/screens/onboarding/widgets/hero_verifi_title.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class ReadyWeb3Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReadyWeb3ScreenState();
}

class _ReadyWeb3ScreenState extends State<ReadyWeb3Screen> {
  double opacity = 0;
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
    context.read<WalletConnectCubit>().canConnect();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) _textColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Hero(
          tag: 'verifi-logo',
          child: Image.asset('assets/launcher_icon/vf_ios.png'),
        ),
        title: HeroVerifiTitle(),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _askToConnectWalletContents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _askToConnectWalletContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Container(
        width: MediaQuery.of(context).size.width,
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _headerTitle(),
                  ),
                  _headerSubtitle(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _connectWalletText(),
                  ),
                  _proceedButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerTitle() {
    return AutoSizeText(
      "Ready for Web3?",
      style: Theme.of(context).textTheme.headline3?.copyWith(
            color: _textColor,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _headerSubtitle() {
    return AutoSizeText(
      "VeriFi is bridging the universe with the metaverse, one WiFi hotspot "
      "at a time.\n\nWith the advent of digital money and blockchain "
      "technologies, VeriFi can directly incentivize users around the world to "
      "contribute to the VeriFi network.",
      maxLines: 7,
      style: Theme.of(context).textTheme.headline6,
      textAlign: TextAlign.center,
    );
  }

  Widget _connectWalletText() {
    return AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "Check out our roadmap\n",
            style: Theme.of(context).textTheme.headline5?.copyWith(
                  decoration: TextDecoration.underline,
                ),
          ),
          TextSpan(
            text: "to see the exciting new features and incentives we plan "
                "to release!",
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _proceedButton() {
    return BlocBuilder<WalletConnectCubit, WalletConnectState>(
      builder: (context, state) {
        return OnboardingOutlineButton(
          text: "Continue",
          onPressed: () {
            (state.canConnect)
                ? Navigator.of(context).pushNamed('/onboarding/wallet')
                : Navigator.of(context).pushNamed('/onboarding/terms');
          },
        );
      },
    );
  }
}
