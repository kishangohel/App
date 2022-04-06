import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData veriFiAppTheme() {
  return ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    textTheme: GoogleFonts.ralewayTextTheme(),
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
    textTheme: GoogleFonts.ralewayTextTheme().merge(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    backgroundColor: Colors.blueGrey[800],
    canvasColor: Colors.blueGrey[800],
    primaryColor: Colors.deepOrange[400],
    colorScheme: ColorScheme.dark(
      primary: Colors.deepOrange[400]!,
      secondary: Colors.deepPurpleAccent,
    ),
  );
}
