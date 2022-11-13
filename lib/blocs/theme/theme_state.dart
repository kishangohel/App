import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final List<Color> colors;

  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    this.colors = const [],
  });

  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    List<Color>? colors,
  }) =>
      ThemeState(
        lightTheme: lightTheme ?? this.lightTheme,
        darkTheme: darkTheme ?? this.darkTheme,
        colors: colors ?? this.colors,
      );

  @override
  List<Object?> get props => [
        lightTheme.hashCode,
        darkTheme.hashCode,
        colors.hashCode,
      ];
}
