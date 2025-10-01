import 'package:flutter/material.dart';
import '../../design_system/theme/theme_variations.dart';
import 'theme_preview.dart';

/// Theme selector widget for choosing theme variants
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
    required this.currentVariant,
    required this.onVariantChanged,
  });

  final ThemeVariant currentVariant;
  final ValueChanged<ThemeVariant> onVariantChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tema Seçimi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Theme previews
        SizedBox(
          height: 110,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ThemeVariations.variants.map((variant) {
                final isSelected = variant == currentVariant;
                return GestureDetector(
                  onTap: () => onVariantChanged(variant),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ThemePreview(variant: variant, isSelected: isSelected),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            variant.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? variant.config.primary
                                  : scheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Detailed list view
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Tema Detayları',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...ThemeVariations.variants.map((variant) {
          final isSelected = variant == currentVariant;
          final config = variant.config;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? config.primary : scheme.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      config.primary,
                      config.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check : _getIconForVariant(variant),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                variant.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                variant.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.radio_button_checked, color: config.primary)
                  : Icon(Icons.radio_button_unchecked, color: scheme.outline),
              onTap: () => onVariantChanged(variant),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getIconForVariant(ThemeVariant variant) {
    return switch (variant) {
      ThemeVariant.world => Icons.public,
      ThemeVariant.ocean => Icons.waves,
      ThemeVariant.golden => Icons.wb_sunny,
      ThemeVariant.earth => Icons.landscape,
      ThemeVariant.forest => Icons.forest,
      ThemeVariant.purple => Icons.auto_awesome,
    };
  }
}
