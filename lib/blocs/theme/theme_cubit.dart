import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_theme/json_theme.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/theme/theme_state.dart';

final _defaultLightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(primary: Colors.black),
  textTheme: GoogleFonts.juraTextTheme().apply(displayColor: Colors.black),
);

final _defaultDarkTheme = ThemeData.from(
  colorScheme: const ColorScheme.dark(primary: Colors.white),
  textTheme: GoogleFonts.juraTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  ).apply(displayColor: Colors.white),
);

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          lightTheme: _defaultLightTheme,
          darkTheme: _defaultDarkTheme,
        ));

  void updateColors(PaletteGenerator palette) {
    final colors = _getColorsFromPalette(palette);
    emit(state.copyWith(colors: colors));
    updateThemeWithColor(colors[0]);
  }

  void _updateTheme(
    ColorScheme lightColorScheme,
    ColorScheme darkColorScheme,
  ) {
    emit(state.copyWith(
      lightTheme: ThemeData.from(
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.juraTextTheme().apply(
          displayColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.juraTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).apply(
          displayColor: Colors.white,
        ),
      ),
    ));
  }

  void updateThemeWithColor(Color color) {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: color,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: color,
    );
    _updateTheme(lightColorScheme, darkColorScheme);
  }

  List<Color> _getColorsFromPalette(PaletteGenerator palette) {
    final Map<Color, int> colorMap = {};
    for (PaletteColor color in palette.paletteColors) {
      final r = color.color.red;
      final g = color.color.green;
      final b = color.color.blue;

      final rgDiff = (r - g).abs();
      final gbDiff = (g - b).abs();
      final brDiff = (b - r).abs();
      final diffSum = rgDiff + gbDiff + brDiff;
      colorMap[color.color] = diffSum;
    }
    var sortedKeys = colorMap.keys.toList(growable: false)
      ..sort((k2, k1) => colorMap[k1]!.compareTo(colorMap[k2]!));
    final sortedMap = LinkedHashMap<Color, int>.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => colorMap[k]!);

    return sortedMap.keys.toList(growable: false);
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) => ThemeState(
        lightTheme: ThemeDecoder.decodeThemeData(json["light_theme"])!,
        darkTheme: ThemeDecoder.decodeThemeData(json["dark_theme"])!,
        colors: (json["colors"] as List<int>?)
                ?.map((value) => Color(value))
                .toList(growable: false) ??
            [],
      );

  @override
  Map<String, dynamic>? toJson(ThemeState state) => {
        "light_theme": ThemeEncoder.encodeThemeData(state.lightTheme),
        "dark_theme": ThemeEncoder.encodeThemeData(state.darkTheme),
        "colors":
            state.colors.map((color) => color.value).toList(growable: false),
      };
}
