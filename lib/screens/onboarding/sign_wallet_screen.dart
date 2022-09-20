import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
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
          if (walletState.exception != null) {
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
            context.read<ProfileCubit>().setEthAddress(
                  walletState.status!.accounts[0],
                );
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
                (Platform.isAndroid)
                    ? _androidConnectWallet()
                    : _iosConnectWallet(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _androidConnectWallet() {
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
              mainAxisAlignment: MainAxisAlignment.center,
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
        style: Theme.of(context).textTheme.headline4?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
        style: Theme.of(context).textTheme.headline5?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
        style: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomAgreeText() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        "If you agree to these terms, please sign below",
        style: Theme.of(context).textTheme.headline6?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomConnectButton() {
    return OnboardingOutlineButton(
      onPressed: () => context.read<WalletConnectCubit>().sign(),
      text: "Sign",
    );
  }

  Widget _iosConnectWallet() {
    final _wallets = [
      ["assets/wallet_logos/metamask.png", "MetaMask", "metamask.io"],
      ["assets/wallet_logos/ledger_live.png", "Ledger Live", "ledger.com"],
      [
        "assets/wallet_logos/crypto_com.png",
        "Crypto.com DeFi Wallet",
        "crypto.com",
      ],
    ];

    return ScrollSnapList(
      itemBuilder: (context, index) {
        return Center(
          child: InkWell(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(_wallets[index][0]),
                  Text(
                    _wallets[index][1],
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            onTap: () {
              context.read<WalletConnectCubit>().connect(_wallets[index][2]);
            },
          ),
        );
      },
      itemCount: _wallets.length,
      itemSize: MediaQuery.of(context).size.width * 0.4,
      onItemFocus: (index) {},
      dynamicItemSize: true,
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
          state.exception?.message.toString() ?? 'Failed to sign',
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontSize: 18,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
