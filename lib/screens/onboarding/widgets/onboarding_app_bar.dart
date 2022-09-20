import 'package:flutter/material.dart';
import 'package:verifi/screens/onboarding/widgets/hero_verifi_title.dart';

class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: Hero(
        tag: 'verifi-logo',
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            'assets/launcher_icon/verifi_logo_white_transparent.png',
          ),
        ),
      ),
      title: HeroVerifiTitle(),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
