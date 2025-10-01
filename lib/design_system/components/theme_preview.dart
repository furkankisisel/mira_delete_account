import 'package:flutter/material.dart';
import '../theme/theme_variations.dart';

/// A preview widget that shows how different theme variants look
class ThemePreview extends StatelessWidget {
  const ThemePreview({
    super.key,
    required this.variant,
    this.isSelected = false,
  });

  final ThemeVariant variant;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final config = variant.config;

    return Container(
      width: 120,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? config.primary : Colors.grey.shade300,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: config.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: _buildPreviewContent(config),
      ),
    );
  }

  Widget _buildPreviewContent(ThemeConfig config) {
    if (config.isMultiColor && variant == ThemeVariant.world) {
      return _buildWorldThemePreview(config);
    }
    return _buildStandardPreview(config);
  }

  Widget _buildWorldThemePreview(ThemeConfig config) {
    final colors = config.accentColors;
    return Column(
      children: [
        // App bar with gradient
        Container(
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                config.lightBackground,
                colors[0].withValues(alpha: 0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colors[1], colors[2]]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        // Body with multiple colored elements
        Expanded(
          child: Container(
            color: config.lightSurface,
            child: Column(
              children: [
                const SizedBox(height: 2),
                // Multi-colored cards
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors[0].withValues(alpha: 0.2),
                        colors[3].withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors[2].withValues(alpha: 0.2),
                        colors[4].withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom navigation with multiple colors
        Container(
          height: 15,
          color: config.lightBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors
                .take(5)
                .map(
                  (color) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardPreview(ThemeConfig config) {
    return Column(
      children: [
        // App bar simulation
        Container(
          height: 20,
          color: config.lightBackground,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 8,
                decoration: BoxDecoration(
                  color: config.primary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        // Body simulation
        Expanded(
          child: Container(
            color: config.lightSurface,
            child: Column(
              children: [
                const SizedBox(height: 2),
                // Card simulation
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 18,
                  decoration: BoxDecoration(
                    color: config.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 2),
                // Another card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: 12,
                  decoration: BoxDecoration(
                    color: config.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom navigation simulation
        Container(
          height: 15,
          color: config.lightBackground,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (index) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == 0
                      ? config.primary
                      : config.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
