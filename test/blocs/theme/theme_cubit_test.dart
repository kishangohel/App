import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:verifi/blocs/theme/theme_cubit.dart';
import 'package:verifi/blocs/theme/theme_state.dart';

import '../mocks/hydrated_storage.dart';

void main() {
  group('ThemeCubit', () {
    late ThemeCubit themeCubit;

    setUp(() {
      initHydratedStorage();
      themeCubit = ThemeCubit();
    });
    tearDown(() {
      themeCubit.close();
    });
    test('initial state is default dark / light themes', () {
      expect(
        themeCubit.state,
        ThemeState(
          lightTheme: ThemeCubit.defaultLightTheme,
          darkTheme: ThemeCubit.defaultDarkTheme,
        ),
      );
    });
    test('initial state text theme is custom Jura', () {
      expect(
        themeCubit.state.lightTheme.textTheme,
        ThemeCubit.defaultLightTheme.textTheme,
      );
      expect(
        themeCubit.state.darkTheme.textTheme,
        ThemeCubit.defaultDarkTheme.textTheme,
      );
    });
    test('hydration works properly', () {
      final toFromJsonState =
          themeCubit.fromJson(themeCubit.toJson(themeCubit.state));
      expect(
        toFromJsonState.lightTheme.colorScheme.primary,
        themeCubit.state.lightTheme.colorScheme.primary,
      );
      expect(
        toFromJsonState.darkTheme.colorScheme.primary,
        themeCubit.state.darkTheme.colorScheme.primary,
      );

      expect(
        toFromJsonState.colors,
        themeCubit.state.colors,
      );
    });
    test('update colors sorted correctly from least gray to most gray', () {
      themeCubit.updateColors(
        PaletteGenerator.fromColors([
          PaletteColor(Colors.lightGreen, 50),
          PaletteColor(Colors.yellowAccent, 50),
          PaletteColor(Colors.brown, 50),
          PaletteColor(Colors.red, 50),
        ]),
      );
      expect(themeCubit.state.colors, <Color>[
        Colors.yellowAccent,
        Colors.red,
        Colors.lightGreen,
        Colors.brown,
      ]);
    });
    test('update theme color produces new themes', () {
      final lightTheme = themeCubit.state.lightTheme;
      final darkTheme = themeCubit.state.darkTheme;
      themeCubit.updateThemeWithColor(Colors.red);
      expect(themeCubit.state.lightTheme != lightTheme, true);
      expect(themeCubit.state.darkTheme != darkTheme, true);
    });
  });
}
