import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../app_theme.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeData themeData;
  final AppTheme appTheme;

  const ThemeLoaded({required this.themeData, required this.appTheme});

  @override
  List<Object> get props => [themeData, appTheme];
}
