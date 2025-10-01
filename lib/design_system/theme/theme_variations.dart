import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../tokens/radii.dart';

/// Theme variations based on different accent colors from our design system
class ThemeVariations {
  ThemeVariations._();

  /// Available theme variants
  static const List<ThemeVariant> variants = [
    ThemeVariant.world,
    ThemeVariant.ocean,
    ThemeVariant.golden,
    ThemeVariant.earth,
    ThemeVariant.forest,
    ThemeVariant.purple,
  ];

  /// Generate light theme for a specific variant
  static ThemeData light(ThemeVariant variant) {
    final base = ThemeData.light(useMaterial3: true);
    final config = variant.config;

    final scheme = ColorScheme.fromSeed(
      seedColor: config.primary,
      surface: config.lightSurface,
      surfaceContainerHighest: config.lightBackground,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: config.lightBackground,
      textTheme: AppTypography.build(base.textTheme),
      // Make popups/sheets match page background
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: config.lightBackground,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: config.lightBackground,
      ),
      dialogTheme: DialogThemeData(backgroundColor: config.lightBackground),
      popupMenuTheme: PopupMenuThemeData(color: config.lightBackground),
      cardTheme: CardThemeData(
        color: config.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      iconTheme: IconThemeData(color: config.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: config.lightBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: variant == ThemeVariant.world
          ? NavigationBarThemeData(
              backgroundColor: config.lightSurface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent, // Indicator'ı kaldır
              iconTheme: WidgetStateProperty.all(
                const IconThemeData(
                  color: Colors.transparent,
                ), // Icon renkleri custom widget'ta ayarlanacak
              ),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  color: Colors.transparent,
                  fontSize: 12,
                ), // Label renkleri custom widget'ta ayarlanacak
              ),
            )
          : NavigationBarThemeData(
              backgroundColor: config.lightSurface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: config.primary.withValues(alpha: 0.12),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: config.primary);
                }
                return IconThemeData(color: scheme.onSurfaceVariant);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(color: config.primary, fontSize: 12);
                }
                return TextStyle(color: scheme.onSurfaceVariant, fontSize: 12);
              }),
            ),
    );
  }

  /// Generate dark theme for a specific variant
  static ThemeData dark(ThemeVariant variant) {
    final base = ThemeData.dark(useMaterial3: true);
    final config = variant.config;

    final scheme = ColorScheme.fromSeed(
      seedColor: config.primary,
      brightness: Brightness.dark,
      surface: config.darkSurface,
      surfaceContainerHighest: config.darkBackground,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: config.darkBackground,
      textTheme: AppTypography.build(
        base.textTheme.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        ),
      ),
      // Make popups/sheets match page background
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: config.darkBackground,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: config.darkBackground,
      ),
      dialogTheme: DialogThemeData(backgroundColor: config.darkBackground),
      popupMenuTheme: PopupMenuThemeData(color: config.darkBackground),
      cardTheme: CardThemeData(
        color: config.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      iconTheme: IconThemeData(color: config.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: config.darkBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      navigationBarTheme: variant == ThemeVariant.world
          ? NavigationBarThemeData(
              backgroundColor: config.darkSurface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: Colors.transparent, // Indicator'ı kaldır
              iconTheme: WidgetStateProperty.all(
                const IconThemeData(
                  color: Colors.transparent,
                ), // Icon renkleri custom widget'ta ayarlanacak
              ),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  color: Colors.transparent,
                  fontSize: 12,
                ), // Label renkleri custom widget'ta ayarlanacak
              ),
            )
          : NavigationBarThemeData(
              backgroundColor: config.darkSurface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: config.primary.withValues(alpha: 0.24),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: config.primary);
                }
                return IconThemeData(color: scheme.onSurfaceVariant);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(color: config.primary, fontSize: 12);
                }
                return TextStyle(color: scheme.onSurfaceVariant, fontSize: 12);
              }),
            ),
    );
  }
}

/// Available theme variants
enum ThemeVariant {
  world('Dünya', 'Tüm renklerin harmonisi'),
  ocean('Okyanus', 'Sakin mavi tema'),
  golden('Altın', 'Sıcak altın tema'),
  earth('Toprak', 'Toprak renkleri'),
  forest('Orman', 'Doğal yeşil tema'),
  purple('Mistik', 'Mistik mor tema');

  const ThemeVariant(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Extension to get theme configuration for each variant
extension ThemeVariantConfig on ThemeVariant {
  ThemeConfig get config => switch (this) {
    ThemeVariant.world => ThemeConfig(
      primary: AppColors.seed, // Ana renk olarak yeşil
      lightBackground: const Color(0xFFFAFAFA), // Modern beyaz
      lightSurface: const Color(0xFFFFFFFF), // Pure beyaz
      darkBackground: const Color(0xFF121212), // Modern siyah
      darkSurface: const Color(0xFF1E1E1E), // Hafif açık siyah
      isMultiColor: true, // Çoklu renk sistemi aktif
    ),
    ThemeVariant.ocean => ThemeConfig(
      primary: AppColors.accentBlue,
      lightBackground: const Color(0xFFE8F4F8),
      lightSurface: const Color(0xFFF0F8FB),
      darkBackground: const Color(0xFF0F1419),
      darkSurface: const Color(0xFF1A2329),
    ),
    ThemeVariant.golden => ThemeConfig(
      primary: AppColors.accentGold,
      lightBackground: const Color(0xFFF7F3E8),
      lightSurface: const Color(0xFFFAF6EB),
      darkBackground: const Color(0xFF1A1814),
      darkSurface: const Color(0xFF252018),
    ),
    ThemeVariant.earth => ThemeConfig(
      primary: AppColors.accentClay,
      lightBackground: const Color(0xFFF2EDE8),
      lightSurface: const Color(0xFFF5F0EB),
      darkBackground: const Color(0xFF19150F),
      darkSurface: const Color(0xFF241E19),
    ),
    ThemeVariant.forest => ThemeConfig(
      primary: AppColors.accentGreenDark,
      lightBackground: const Color(0xFFEDF2E8),
      lightSurface: const Color(0xFFF0F5EB),
      darkBackground: const Color(0xFF141911),
      darkSurface: const Color(0xFF1F241C),
    ),
    ThemeVariant.purple => ThemeConfig(
      primary: AppColors.accentPurple,
      lightBackground: const Color(0xFFF2EFFA),
      lightSurface: const Color(0xFFF5F2FB),
      darkBackground: const Color(0xFF16141A),
      darkSurface: const Color(0xFF211E25),
    ),
  };
}

/// Theme configuration class
class ThemeConfig {
  const ThemeConfig({
    required this.primary,
    required this.lightBackground,
    required this.lightSurface,
    required this.darkBackground,
    required this.darkSurface,
    this.isMultiColor = false,
  });

  final Color primary;
  final Color lightBackground;
  final Color lightSurface;
  final Color darkBackground;
  final Color darkSurface;
  final bool isMultiColor;

  /// Get accent colors for multi-color themes
  List<Color> get accentColors => [
    AppColors.accentBlue,
    AppColors.accentGold,
    AppColors.accentClay,
    AppColors.accentGreenDark,
    AppColors.accentPurple,
  ];
}
