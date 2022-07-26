import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_theme/json_theme.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/theme/theme_state.dart';

final _defaultLightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(primary: Colors.black),
  textTheme: GoogleFonts.juraTextTheme(),
);

final _defaultDarkTheme = ThemeData.from(
  colorScheme: const ColorScheme.dark(primary: Colors.white),
  textTheme: GoogleFonts.juraTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  ),
);

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          lightTheme: _defaultLightTheme,
          darkTheme: _defaultDarkTheme,
        ));

  void updateTheme(
    ColorScheme lightColorScheme,
    ColorScheme darkColorScheme,
  ) {
    emit(ThemeState(
      lightTheme: ThemeData.from(
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.juraTextTheme(),
      ),
      darkTheme: ThemeData.from(
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.juraTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
    ));
  }

  void updateThemeWithPalette(PaletteGenerator palette) {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: palette.lightVibrantColor?.color ??
          palette.lightMutedColor?.color ??
          palette.vibrantColor?.color ??
          Colors.grey[200]!,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: palette.darkVibrantColor?.color ??
          palette.darkMutedColor?.color ??
          palette.vibrantColor?.color ??
          Colors.grey[800]!,
    );
    updateTheme(lightColorScheme, darkColorScheme);
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) => ThemeState(
        lightTheme: ThemeDecoder.decodeThemeData(json["light_theme"])!,
        darkTheme: ThemeDecoder.decodeThemeData(json["dark_theme"])!,
      );

  @override
  Map<String, dynamic>? toJson(ThemeState state) => {
        "light_theme": ThemeEncoder.encodeThemeData(state.lightTheme),
        "dark_theme": ThemeEncoder.encodeThemeData(state.darkTheme),
      };
}
