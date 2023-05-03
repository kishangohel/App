import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';

class AuthHeaderImage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthHeaderImageState();
}

class _AuthHeaderImageState extends State<AuthHeaderImage>
    with TickerProviderStateMixin {
  late FlutterGifController controller;
  @override
  void initState() {
    controller = FlutterGifController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(27);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = (Theme.of(context).brightness == Brightness.light)
        ? 'assets/VeriFi_white_bg.gif'
        : 'assets/VeriFi_black_bg.gif';
    return GifImage(
      controller: controller,
      image: AssetImage(
        imagePath,
      ),
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
