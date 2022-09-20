import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  final bool appBar;

  /// Displays VeriFi title w/ Quantico font
  ///
  const AppTitle({this.appBar = false});

  @override
  Widget build(BuildContext context) {
    Color _fontColor = (appBar) ? Colors.white : Colors.black;
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.dark && !appBar) _fontColor = Colors.white;
    return Material(
      type: MaterialType.transparency,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: AutoSizeText(
          "VeriFi",
          style: GoogleFonts.quanticoTextTheme().titleLarge?.copyWith(
                color: _fontColor,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
