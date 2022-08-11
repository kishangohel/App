import 'package:flutter/material.dart';
import 'package:verifi/widgets/text/app_title.dart';

class HeroVerifiTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'verifi-title',
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        height: kToolbarHeight,
        width: MediaQuery.of(context).size.width * 0.5,
        child: const AppTitle(appBar: true),
      ),
    );
  }
}
