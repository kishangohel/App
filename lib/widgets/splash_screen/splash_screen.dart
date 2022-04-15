import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: const FlutterLogo(
          size: 48,
          style: FlutterLogoStyle.horizontal,
          textColor: Colors.white,
        ),
      ),
    );
  }
}
