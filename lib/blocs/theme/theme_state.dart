import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
  });

  @override
  List<Object?> get props => [lightTheme.toString(), darkTheme.toString()];
}
