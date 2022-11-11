import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_cubit.dart';
import 'package:verifi/blocs/wallet_connect/wallet_connect_state.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
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
      const Duration(seconds: 1),
      () => setState(() => opacity = 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletConnectCubit, WalletConnectState>(
      listenWhen: (previous, current) {
        return (current.status != null || current.cbAccount != null);
      },
      listener: (context, state) {
        if (state.status != null) {
          context.read<NftsCubit>().loadNftsOwnedbyAddress(
                state.status!.accounts[0],
              );
        } else if (state.cbAccount != null) {
          context.read<NftsCubit>().loadNftsOwnedbyAddress(
                state.cbAccount!.address,
              );
        }
        Navigator.of(context).pushNamed('/onboarding/wallet/sign');
      },
      child: Scaffold(
        appBar: OnboardingAppBar(),
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.black
                : Colors.white,
        body: Stack(
          children: [
            onBoardingBackground(context),
            _connectWalletContents(),
          ],
        ),
      ),
    );
  }

  Widget _connectWalletContents() {
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
                _walletConnectTitle(),
                _walletConnectSubtitle(),
                _walletConnectDescription(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _walletSelectList(),
                ),
                Expanded(
                  child: _walletSelectHint(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _walletConnectTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 16.0,
      ),
      child: AutoSizeText(
        "Connect your Ethereum wallet",
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _walletConnectSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: AutoSizeText(
        "Your wallet will be used to",
        style: Theme.of(context).textTheme.headline5?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _walletConnectDescription() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 24.0,
        left: 24.0,
        right: 12.0,
      ),
      child: AutoSizeText(
        '''\u2022 Agree to our terms and conditions
\u2022 Select an NFT as your PFP 
\u2022 Receive Web3 incentives (tokens, airdrops, NFTs, etc.)''',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _walletSelectList() {
    final wallets = context.read<WalletConnectCubit>().wallets;
    return ScrollSnapList(
      itemBuilder: (context, index) {
        return Center(
          child: InkWell(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(wallets[index].logo),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      wallets[index].name,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async => context.read<WalletConnectCubit>().connect(
                  wallets[index].domain,
                ),
          ),
        );
      },
      itemCount: wallets.length,
      itemSize: MediaQuery.of(context).size.width * 0.4,
      onItemFocus: (index) {},
      dynamicItemSize: true,
    );
  }

  Widget _walletSelectHint() {
    return Text(
      "Select your wallet",
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
