import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  final bool appBar;

  /// Displays VeriFi title w/ Quantico font
  const AppTitle({this.appBar = false});

  @override
  Widget build(BuildContext context) {
    Color fontColor = (appBar) ? Colors.white : Colors.black;
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark && !appBar) {
      fontColor = Colors.white;
    }
    return FittedBox(
      fit: BoxFit.contain,
      child: AutoSizeText(
        "VeriFi",
        style: GoogleFonts.quanticoTextTheme().headlineSmall?.copyWith(
              color: fontColor,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
