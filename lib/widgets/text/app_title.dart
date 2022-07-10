import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  final double fontSize;
  final Color? fontColor;
  final TextAlign textAlign;

  /// Displays VeriFi title w/ Quantico font
  ///
  const AppTitle({
    required this.fontSize,
    this.fontColor = Colors.white,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          "VeriFi",
          style: GoogleFonts.quantico(
            fontSize: fontSize,
            color: fontColor,
          ),
          textAlign: textAlign,
        ),
      ),
    );
  }
}
