import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/nfts/nfts.dart';
import 'package:verifi/models/nft.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';
import 'package:verifi/widgets/text/app_title.dart';

class ProfilePictureSelectScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePictureSelectState();
}

class _ProfilePictureSelectState extends State<ProfilePictureSelectScreen> {
  double opacity = 0;
  Color textColor = Colors.black;
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
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark) textColor = Colors.white;
    return Scaffold(
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
              _profilePictureScreenContents(),
            ],
          ),
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
                _pfpPageView(),
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
      style: Theme.of(context).textTheme.headline4?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _pfpPageView() {
    final List<Nft> nfts = context.watch<NftsCubit>().state;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: nfts.length,
              itemBuilder: (context, index) {
                final nft = nfts[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16.0,
                          ),
                          child: Image.network(nft.image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: AutoSizeText(
                          nft.name,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.headline4?.copyWith(
                                    color: (textColor == Colors.white)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          bottom: 16.0,
                        ),
                        child: AutoSizeText(
                          nft.collectionName,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    color: (textColor == Colors.white)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Swipe left/right to select",
              style: Theme.of(context).textTheme.caption?.copyWith(
                    color: textColor,
                  ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              context.read<ProfileCubit>().setProfilePhoto(
                    nfts[_controller.page!.toInt()].image,
                  );
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/onboarding/settingThingsUp',
                ModalRoute.withName('/'),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Complete Setup",
                style: Theme.of(context).textTheme.headline5?.copyWith(
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
          ),
        ],
      ),
    );
  }
}
