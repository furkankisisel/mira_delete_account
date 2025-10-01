import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color seed = Color(0xFF5B6B4F);
  static const Color background = Color(0xFFEFE9DD);
  static const Color surface = Color(0xFFF5EFE4);

  static const Color accentBlue = Color(0xFF90B6C9);
  static const Color accentGold = Color(0xFFD8C27A);
  static const Color accentClay = Color(0xFFB59785);
  static const Color accentSand = Color(0xFFC1BA9F);
  static const Color accentGreen = Color(0xFF547341);
  static const Color accentGreenDark = Color(0xFF628353);
  static const Color accentPurple = Color(0xFF8B7AC7);

  static Color shadowSm([double o = .15]) => Colors.black.withValues(alpha: o);
  static Color overlay([double o = .08]) => Colors.black.withValues(alpha: o);
}

enum MoodToken { awful, ok, good, great }

extension MoodTokenColor on MoodToken {
  Color get color => switch (this) {
    MoodToken.awful => AppColors.accentClay,
    MoodToken.ok => AppColors.accentSand,
    MoodToken.good => AppColors.accentBlue,
    MoodToken.great => AppColors.accentGold,
  };
}
