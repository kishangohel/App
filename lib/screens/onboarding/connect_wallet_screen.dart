import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_cubit.dart';
import 'package:verifi/resources/resources.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class ConnectWalletScreen extends StatefulWidget {
  @override
  State<ConnectWalletScreen> createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  double opacity = 0;

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
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              ...onBoardingBackground(context),
              (Platform.isIOS)
                  ? _WalletsScrollSnapList()
                  : _WalletConnectButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletConnectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => context.read<WalletConnectCubit>().connect(null),
            child: const Text("Connect Ethereum wallet"),
          ),
          ElevatedButton(
            onPressed: () => context.read<WalletConnectCubit>().sign(),
            child: const Text("Sign transaction"),
          ),
        ],
      ),
    );
  }
}

class _WalletsScrollSnapList extends StatelessWidget {
  final _wallets = [
    [WalletLogos.metamask, "MetaMask", "metamask.io"],
    [WalletLogos.ledgerLive, "Ledger Live", "ledger.com"],
    [WalletLogos.cryptoCom, "Crypto.com DeFi Wallet", "crypto.com"],
  ];

  @override
  Widget build(BuildContext context) {
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
