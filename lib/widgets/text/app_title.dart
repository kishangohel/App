import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  final double fontSize;
  final TextAlign textAlign;

  /// Displays VeriFi title w/ Quantico font
  ///
  const AppTitle({
    required this.fontSize,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return Material(
      type: MaterialType.transparency,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          "VeriFi",
          style: GoogleFonts.quantico(
            fontSize: fontSize,
            color: brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}
