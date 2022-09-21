import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class ReadyWeb3Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReadyWeb3ScreenState();
}

class _ReadyWeb3ScreenState extends State<ReadyWeb3Screen> {
  double opacity = 0;

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
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: WillPopScope(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              _askToConnectWalletContents(),
            ],
          ),
        ),
        onWillPop: () async {
          await context.read<AuthenticationCubit>().logout();
          context.read<ProfileCubit>().logout();
          await context.read<ProfileCubit>().clear();
          return true;
        },
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
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
      style: Theme.of(context).textTheme.headlineLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _headerSubtitle() {
    return AutoSizeText(
      "Our vision is to create the most accessible, impactful web3 project in "
      "the world.\n\n"
      "VeriFi directly incentivize users around the world to contribute to and "
      "maintain VeriNet: the world's first WiFi crowdsourcing project powered "
      "by web3. This lays the foundation for a plethora of future initiatives "
      "on our roadmap.",
      maxLines: 9,
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
  }

  Widget _connectWalletText() {
    return AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(
              text: "Join our Discord\n",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  launchUrl(Uri(
                    scheme: 'https',
                    host: 'discord.gg',
                    path: 'XbNreXVcCv',
                  ));
                }),
          TextSpan(
            text: "to see the exciting new features and incentives we plan "
                "to release!",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
    );
  }

  Widget _proceedButton() {
    return BlocBuilder<WalletConnectCubit, WalletConnectState>(
      builder: (context, state) {
        return OnboardingOutlineButton(
          text: "Continue",
          onPressed: () async {
            (state.canConnect)
                ? await Navigator.of(context).pushNamed('/onboarding/wallet')
                : await Navigator.of(context).pushNamed('/onboarding/terms');
          },
        );
      },
    );
  }
}
