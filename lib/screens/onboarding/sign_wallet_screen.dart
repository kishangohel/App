import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class SignWalletScreen extends StatefulWidget {
  @override
  State<SignWalletScreen> createState() => _SignWalletScreenState();
}

class _SignWalletScreenState extends State<SignWalletScreen> {
  double opacity = 0;
  bool isChecked = false;

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
    return Scaffold(
      appBar: OnboardingAppBar(),
      body: BlocListener<WalletConnectCubit, WalletConnectState>(
        listener: (context, walletState) {
          if (walletState.errorMessage != null) {
            showModalBottomSheet(
              context: context,
              builder: (context) => _modalSheetError(context, walletState),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            );
            context.read<WalletConnectCubit>().clearError();
          }
          if (walletState.agreementSigned == true) {
            String ethAddress;
            if (walletState.status != null) {
              ethAddress = walletState.status!.accounts[0];
            } else {
              ethAddress = walletState.cbAccount!.address;
            }
            ethAddress = "0x09457fA22b7D56C93E7407D8a1587C2447316D55";
            context.read<ProfileCubit>().setEthAddress(ethAddress);
            // context.read<ProfileCubit>().setEthAddress(ethAddress);
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/onboarding/pfpNft',
              ModalRoute.withName('/onboarding/wallet/sign'),
            );
          }
        },
        child: Container(
          color: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                ...onBoardingBackground(context),
                _signWalletContents(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signWalletContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _topTextTitle(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _bottomTextTitle(),
                _bottomTermsText(),
                _bottomAgreeText(),
                _bottomConnectButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topTextTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 16.0,
      ),
      child: AutoSizeText(
        "Agree to Terms & Conditions",
        style: Theme.of(context).textTheme.headlineLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomTextTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      child: AutoSizeText(
        "Please read the following:",
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: AutoSizeText(
        "Terms of Use\n"
        "Privacy Policy",
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomAgreeText() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        "If you agree to these terms, use your wallet to sign",
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomConnectButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: OnboardingOutlineButton(
        onPressed: () => context.read<WalletConnectCubit>().sign(),
        text: "Sign",
      ),
    );
  }

  Widget _modalSheetError(BuildContext context, WalletConnectState state) {
    return Container(
      height: 80.0,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Center(
        child: AutoSizeText(
          state.errorMessage!,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
