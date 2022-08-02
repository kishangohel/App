import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ThemeState extends Equatable {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final PaletteGenerator? palette;

  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    this.palette,
  });

  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    PaletteGenerator? palette,
  }) =>
      ThemeState(
        lightTheme: lightTheme ?? this.lightTheme,
        darkTheme: darkTheme ?? this.darkTheme,
        palette: palette ?? this.palette,
      );

  @override
  List<Object?> get props => [
        lightTheme.toString(),
        darkTheme.toString(),
        palette.toString(),
      ];
}
