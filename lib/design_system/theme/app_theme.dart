import 'package:flutter/material.dart';
import 'theme_variations.dart';

class AppTheme {
  AppTheme._();

  /// Default theme variant
  static const ThemeVariant defaultVariant = ThemeVariant.world;

  /// Get light theme for default variant
  static ThemeData light([ThemeVariant? variant]) {
    return ThemeVariations.light(variant ?? defaultVariant);
  }

  /// Get dark theme for default variant
  static ThemeData dark([ThemeVariant? variant]) {
    return ThemeVariations.dark(variant ?? defaultVariant);
  }
}
