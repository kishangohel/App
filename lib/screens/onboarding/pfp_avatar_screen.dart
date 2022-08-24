import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/screens/onboarding/widgets/hero_verifi_title.dart';
import 'package:verifi/widgets/backgrounds/onboarding_background.dart';

class PfpAvatarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PfpAvatarScreenState();
}

class _PfpAvatarScreenState extends State<PfpAvatarScreen> {
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
        title: HeroVerifiTitle(),
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
      "Select an avatar below for your profile picture",
      style: Theme.of(context).textTheme.headline4?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _pfpPageView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: 24,
              itemBuilder: (context, index) {
                final strIndex = (index + 1).toString().padLeft(2, "0");
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16.0,
                    ),
                    child: Image(
                      image: AssetImage(
                        'assets/profile_avatars/People-$strIndex.png',
                      ),
                      fit: BoxFit.contain,
                    ),
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
              final strIndex =
                  (_controller.page! + 1).toInt().toString().padLeft(2, "0");
              context.read<ProfileCubit>().setPfp(
                    'assets/profile_avatars/People-$strIndex.png',
                  );
              Navigator.of(context).pushNamed(
                '/onboarding/displayName',
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
