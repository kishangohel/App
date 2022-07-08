import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData veriFiAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    textTheme: GoogleFonts.juraTextTheme(),
    primaryColor: Colors.deepOrange[600],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(Colors.deepOrange[600]!),
      ),
    ),
  );
}

ThemeData veriFiAppDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    textTheme: GoogleFonts.juraTextTheme().merge(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    backgroundColor: Colors.black,
    canvasColor: Colors.black,
    primaryColor: Colors.white,
  );
}
