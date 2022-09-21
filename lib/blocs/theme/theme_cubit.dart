import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_theme/json_theme.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/theme/theme_state.dart';

final jura = GoogleFonts.juraTextTheme();
final juraSemiBoldLightTextTheme = TextTheme(
  displayLarge: jura.displayLarge?.copyWith(fontWeight: FontWeight.w600),
  displayMedium: jura.displayMedium?.copyWith(fontWeight: FontWeight.w600),
  displaySmall: jura.displaySmall?.copyWith(fontWeight: FontWeight.w600),
  headlineLarge: jura.headlineLarge?.copyWith(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  headlineMedium: jura.headlineMedium?.copyWith(
    color: Colors.black,
    fontWeight: FontWeight.w600,
  ),
  headlineSmall: jura.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
  titleLarge: jura.titleLarge?.copyWith(fontWeight: FontWeight.w600),
  titleMedium: jura.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  titleSmall: jura.titleSmall?.copyWith(fontWeight: FontWeight.w600),
  bodyLarge: jura.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
  bodyMedium: jura.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
  bodySmall: jura.bodySmall?.copyWith(fontWeight: FontWeight.w600),
  labelLarge: jura.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  labelMedium: jura.labelMedium?.copyWith(fontWeight: FontWeight.w600),
  labelSmall: jura.labelSmall?.copyWith(fontWeight: FontWeight.w600),
);
final juraSemiBoldDarkTextTheme = TextTheme(
  displayLarge: jura.displayLarge?.copyWith(fontWeight: FontWeight.w600),
  displayMedium: jura.displayMedium?.copyWith(fontWeight: FontWeight.w600),
  displaySmall: jura.displaySmall?.copyWith(fontWeight: FontWeight.w600),
  headlineLarge: jura.headlineLarge?.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  ),
  headlineMedium: jura.headlineMedium?.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  ),
  headlineSmall: jura.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
  titleLarge: jura.titleLarge?.copyWith(fontWeight: FontWeight.w600),
  titleMedium: jura.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  titleSmall: jura.titleSmall?.copyWith(fontWeight: FontWeight.w600),
  bodyLarge: jura.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
  bodyMedium: jura.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
  bodySmall: jura.bodySmall?.copyWith(fontWeight: FontWeight.w600),
  labelLarge: jura.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  labelMedium: jura.labelMedium?.copyWith(fontWeight: FontWeight.w600),
  labelSmall: jura.labelSmall?.copyWith(fontWeight: FontWeight.w600),
);
final defaultLightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(
    primary: Colors.black,
    outline: Colors.black,
  ),
  textTheme: juraSemiBoldLightTextTheme,
);

final defaultDarkTheme = ThemeData.from(
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    outline: Colors.white,
  ),
  textTheme: juraSemiBoldDarkTextTheme.apply(
    displayColor: Colors.white,
    bodyColor: Colors.white,
  ),
);

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          lightTheme: defaultLightTheme,
          darkTheme: defaultDarkTheme,
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
        textTheme: juraSemiBoldLightTextTheme,
      ),
      darkTheme: ThemeData.from(
        colorScheme: darkColorScheme,
        textTheme: juraSemiBoldDarkTextTheme.apply(
          displayColor: Colors.white,
          bodyColor: Colors.white,
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
