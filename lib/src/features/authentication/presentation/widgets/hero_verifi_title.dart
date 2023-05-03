import 'package:flutter/material.dart';
import 'package:verifi/src/features/authentication/presentation/widgets/app_title.dart';

class HeroVerifiTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Hero(
      tag: 'verifi-title',
      child: SizedBox(
        height: kToolbarHeight,
        child: AppTitle(appBar: true),
      ),
    );
  }
}
