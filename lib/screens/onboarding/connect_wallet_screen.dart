import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_cubit.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/resources/resources.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class ConnectWalletScreen extends StatefulWidget {
  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
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
    return BlocListener<WalletConnectCubit, WalletConnectState>(
      listener: (context, state) {
        Navigator.of(context).pushNamed('/onboarding/wallet/sign');
      },
      listenWhen: (previous, current) {
        return (previous.status == null) && (current.status != null);
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
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
          body: Container(
            color: Colors.black,
            child: SafeArea(
              child: Stack(
                children: [
                  ...onBoardingBackground(context),
                  (Platform.isIOS)
                      ? _iosConnectWallet()
                      : _androidConnectWallet(),
                ],
              ),
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
                _bottomTextContent(),
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
        "Connect your Ethereum wallet",
        style: Theme.of(context).textTheme.headline4?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomTextTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: AutoSizeText(
        "Your wallet will be used to",
        style: Theme.of(context).textTheme.headline5?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _bottomTextContent() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24.0,
        left: 24.0,
        right: 12.0,
      ),
      child: AutoSizeText(
        '''\u2022 Select an NFT as your profile photo
\u2022 Receive \$VERIFI tokens for making contributions to the network''',
        style: Theme.of(context).textTheme.headline6?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _bottomConnectButton() {
    return OutlinedButton(
      onPressed: () => context.read<WalletConnectCubit>().connect(null),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Connect",
          style: Theme.of(context).textTheme.headline4?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          width: 2.0,
          color: textColor,
        ),
        primary: textColor,
      ),
    );
  }

  Widget _iosConnectWallet() {
    final _wallets = [
      [WalletLogos.metamask, "MetaMask", "metamask.io"],
      [WalletLogos.ledgerLive, "Ledger Live", "ledger.com"],
      [WalletLogos.cryptoCom, "Crypto.com DeFi Wallet", "crypto.com"],
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
            onTap: () =>
                context.read<WalletConnectCubit>().connect(_wallets[index][2]),
          ),
        );
      },
      itemCount: _wallets.length,
      itemSize: MediaQuery.of(context).size.width * 0.4,
      onItemFocus: (index) {},
      dynamicItemSize: true,
    );
  }
}
