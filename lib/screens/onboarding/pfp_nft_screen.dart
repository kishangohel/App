import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/nfts/nfts_cubit.dart';
import 'package:verifi/models/models.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_app_bar.dart';
import 'package:verifi/screens/onboarding/widgets/onboarding_outline_button.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class PfpNftScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PfpNftScreenState();
}

class _PfpNftScreenState extends State<PfpNftScreen> {
  double opacity = 0;
  final PageController _controller = PageController();

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
      appBar: OnboardingAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            ...onBoardingBackground(context),
            _profilePictureScreenContents(),
          ],
        ),
      ),
    );
  }

  Widget _profilePictureScreenContents() {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(seconds: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pfpTitle(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _pfpContents(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pfpTitle() {
    return Text(
      "Select an NFT from your wallet as your profile photo",
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _pfpContents() {
    return BlocBuilder<NftsCubit, List<Pfp>>(
      builder: (context, nfts) {
        return SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (nfts.isNotEmpty)
                  ? Expanded(
                      child: _pfpPageView(nfts),
                    )
                  : _noNftsFoundText(),
              Visibility(
                visible: nfts.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Swipe left/right to select",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              _continueSetupButton(nfts),
            ],
          ),
        );
      },
    );
  }

  Widget _pfpPageView(List<Pfp> nfts) {
    return PageView.builder(
      controller: _controller,
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        final nft = nfts[index];
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NFT image
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16.0,
                  ),
                  child: Image(
                    image: nft.image,
                  ),
                ),
              ),
              // NFT name
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: AutoSizeText(
                  nft.name ?? '',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              // NFT description
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: AutoSizeText(
                  nft.description ?? '',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _noNftsFoundText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AutoSizeText(
        "No NFTs found in your wallet",
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _continueSetupButton(List<Pfp> nfts) {
    return OnboardingOutlineButton(
      onPressed: () async {
        if (nfts.isNotEmpty) {
          context.read<ProfileCubit>().setPfp(nfts[_controller.page!.toInt()]);
        }
        await Navigator.of(context).pushNamed(
          '/onboarding/displayName',
        );
      },
      text: "Continue",
    );
  }
}
