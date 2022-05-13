import 'package:flutter/material.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
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
              _WalletsScrollSnapList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletsScrollSnapList extends StatelessWidget {
  final _wallets = [];
  @override
  Widget build(BuildContext context) {
    return ScrollSnapList(
      itemBuilder: (context, index) {
        return Image.asset(_wallets[index]);
      },
      itemCount: _wallets.length,
      itemSize: 35,
      onItemFocus: (index) {},
    );
  }
}
