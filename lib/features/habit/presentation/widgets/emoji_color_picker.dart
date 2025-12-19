import 'package:flutter/material.dart';
import 'package:mira/l10n/app_localizations.dart';
import '../../../../core/utils/emoji_presets.dart';

/// Emoji ve renk seçici widget.
/// Basit ve gelişmiş alışkanlık ekranlarında kullanılır.
class EmojiColorPicker extends StatelessWidget {
  const EmojiColorPicker({
    super.key,
    required this.selectedEmoji,
    required this.selectedColor,
    required this.onEmojiChanged,
    required this.onColorChanged,
  });

  final String selectedEmoji;
  final Color selectedColor;
  final ValueChanged<String> onEmojiChanged;
  final ValueChanged<Color> onColorChanged;

  static const List<Color> defaultColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji Seçici
        Text(
          'Emoji',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showEmojiPicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selectedColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      selectedEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).chooseEmoji.replaceAll(':', ''),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dokunarak değiştir',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Renk Seçici
        Text(
          'Renk',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: defaultColors.map((color) {
            final isSelected = selectedColor.value == color.value;
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _showEmojiPicker(BuildContext context) async {
    final theme = Theme.of(context);
    String? customEmoji;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emoji Seç',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Özel emoji girişi
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Özel Emoji',
                      hintText: 'Emoji yapıştır veya yaz',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          if (customEmoji != null && customEmoji!.isNotEmpty) {
                            onEmojiChanged(customEmoji!);
                            Navigator.pop(ctx);
                          }
                        },
                      ),
                    ),
                    onChanged: (v) => customEmoji = v.trim(),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        onEmojiChanged(v.trim());
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Preset emojiler
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: kEmojiPresets.length,
                      itemBuilder: (_, index) {
                        final emoji = kEmojiPresets[index];
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () {
                            onEmojiChanged(emoji);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedColor.withOpacity(0.2)
                                  : theme.colorScheme.surfaceContainerHighest
                                        .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? selectedColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
