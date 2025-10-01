import 'package:flutter/material.dart';
import '../../core/language_manager.dart';

/// Dil seçimi için modal bottom sheet
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  final SupportedLanguage currentLanguage;
  final ValueChanged<SupportedLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.language, color: scheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Dil Seçimi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Languages list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: SupportedLanguage.values.length,
              itemBuilder: (context, index) {
                final language = SupportedLanguage.values[index];
                final isSelected = language == currentLanguage;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  title: Text(
                    language.displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected ? scheme.primary : null,
                    ),
                  ),
                  subtitle: Text(
                    language.code.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: scheme.primary)
                      : null,
                  onTap: () {
                    onLanguageChanged(language);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dil seçimi modal'ını göster
void showLanguageSelector({
  required BuildContext context,
  required SupportedLanguage currentLanguage,
  required ValueChanged<SupportedLanguage> onLanguageChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => LanguageSelector(
        currentLanguage: currentLanguage,
        onLanguageChanged: onLanguageChanged,
      ),
    ),
  );
}
