import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class AskToConnectWalletScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AskToConnectWalletScreenState();
}

class _AskToConnectWalletScreenState extends State<AskToConnectWalletScreen> {
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
        title: const Hero(
          tag: 'verifi-title',
          child: AppTitle(),
        ),
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
                  _connectWalletButton(),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: _skipConnectingWalletButton(),
                  ),
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
      "VeriFi is a Web3 mobile app. The advent of digital money and "
      "blockchain technologies enables us to directly incentivize users "
      "around the world who contribute to the VeriFi network.",
      maxLines: 4,
      style: Theme.of(context).textTheme.headline6,
      textAlign: TextAlign.center,
    );
  }

  Widget _connectWalletButton() {
    return BlocBuilder<WalletConnectCubit, WalletConnectState>(
      builder: (context, state) {
        return (state.canConnect)
            ? OnboardingOutlineButton(
                text: "Connect Ethereum wallet",
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/onboarding/wallet',
                    (route) => false,
                  );
                },
              )
            : AutoSizeText(
                "No wallets installed",
                style: Theme.of(context).textTheme.headline6,
              );
      },
    );
  }

  Widget _skipConnectingWalletButton() {
    return OnboardingOutlineButton(
      text: "Skip connecting wallet",
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding/terms',
          (route) => false,
        );
      },
    );
  }
}
