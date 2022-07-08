import 'package:flutter/material.dart';

List<Widget> onBoardingBackground(BuildContext context) {
  return [
    Hero(
      tag: 'enter-the-metaverse',
      child: Image.asset(
        (MediaQuery.of(context).platformBrightness == Brightness.light)
            ? 'assets/white_particles.gif'
            : 'assets/black_particles.gif',
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fitHeight,
      ),
    ),
    /* Hero( */
    /*   tag: 'enter-the-metaverse-filter', */
    /*   child: Container( */
    /*     color: Colors.black.withOpacity(0.1), */
    /*   ), */
    /* ), */
  ];
}
