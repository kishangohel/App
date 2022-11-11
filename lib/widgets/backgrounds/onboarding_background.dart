import 'package:flutter/material.dart';

Widget onBoardingBackground(BuildContext context) {
  return Center(
    child: Hero(
      tag: 'enter-the-metaverse',
      child: Image.asset(
        (MediaQuery.of(context).platformBrightness == Brightness.light)
            ? 'assets/white_particles_shrinked.gif'
            : 'assets/black_particles_shrinked.gif',
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    ),
  );
}
