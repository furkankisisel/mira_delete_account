import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/habit_model.dart';
import '../domain/habit_types.dart';

/// Minimalist basit alışkanlık oluşturma ekranı.
/// Tek sayfa, akıcı scroll tasarımı.
class SimpleHabitScreen extends StatefulWidget {
  const SimpleHabitScreen({super.key, this.existingHabit});

  final Habit? existingHabit;
  bool get isEditing => existingHabit != null;

  @override
  State<SimpleHabitScreen> createState() => _SimpleHabitScreenState();
}

class _SimpleHabitScreenState extends State<SimpleHabitScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // State
  String _selectedEmoji = '✅';
  Color _selectedColor = const Color(0xFF6366F1);
  String _selectedFrequency = 'daily';
  final Set<int> _weeklyDays = {};
  final Set<int> _monthDays = {};
  final List<String> _yearDays = [];
  int _periodicDays = 2;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _startDate = DateTime.now();

  // Emoji picker state
  bool _emojiExpanded = false;
  final _customEmojiController = TextEditingController();

  // Modern renk paleti
  static const List<Color> _colors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
  ];

  // Emoji listesi - Kategorize edilmiş
  static const List<String> _quickEmojis = [
    '✅',
    '⭐',
    '💪',
    '🎯',
    '📚',
    '💧',
    '🏃',
    '🧘',
  ];

  static const Map<String, List<String>> _emojiCategories = {
    'Popüler': ['✅', '⭐', '💪', '🎯', '📚', '💧', '🏃', '🧘', '💤', '🍎'],
    'Sağlık': ['💊', '🏥', '🩺', '💉', '🧬', '🦷', '👁️', '🫀', '🧠', '🦴'],
    'Spor': ['🏋️', '🚴', '🏊', '⚽', '🎾', '🏀', '🥊', '🧗', '🎿', '🏌️'],
    'Yaşam': ['🏠', '🌱', '☀️', '🌙', '❤️', '🔥', '⚡', '🎉', '🎂', '🎁'],
    'Üretkenlik': ['✍️', '💻', '📱', '📝', '📖', '🎨', '🎵', '💰', '📊', '⏰'],
    'Yiyecek': ['🥗', '🥤', '🍵', '☕', '🥛', '🍎', '🥑', '🥕', '🍳', '🥪'],
    'Doğa': ['🌿', '🌸', '🌺', '🌻', '🍀', '🌲', '🌊', '⛰️', '🌈', '🦋'],
    'Hayvanlar': ['🐕', '🐈', '🐦', '🐠', '🐢', '🦔', '🐰', '🦁', '🐼', '🦊'],
    'Bakım': ['🚿', '🧴', '🧼', '🧹', '🧺', '🧷', '💅', '💇', '🧔', '🧍'],
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _loadExistingHabit();
  }

  void _loadExistingHabit() {
    final h = widget.existingHabit;
    if (h == null) return;

    _nameController.text = h.title;
    _descriptionController.text = h.description;
    _selectedColor = h.color;
    _selectedEmoji = h.emoji ?? '✅';
    _reminderEnabled = h.reminderEnabled;
    _reminderTime = h.reminderTime ?? const TimeOfDay(hour: 9, minute: 0);

    // Load start date from existing habit
    if (h.startDate != null) {
      final parts = h.startDate!.split('-');
      if (parts.length == 3) {
        _startDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    final ft = h.frequencyType?.toLowerCase() ?? h.frequency?.toLowerCase();
    if (ft != null) {
      if (ft.contains('daily')) {
        _selectedFrequency = 'daily';
      } else if (ft.contains('weekly') || ft.contains('weekdays')) {
        _selectedFrequency = 'weekly';
      } else if (ft.contains('monthly') || ft.contains('monthdays')) {
        _selectedFrequency = 'monthly';
      } else if (ft.contains('yearly') || ft.contains('yeardays')) {
        _selectedFrequency = 'yearly';
      } else if (ft.contains('periodic')) {
        _selectedFrequency = 'periodic';
      }
    }

    if (h.selectedWeekdays != null) _weeklyDays.addAll(h.selectedWeekdays!);
    if (h.selectedMonthDays != null) _monthDays.addAll(h.selectedMonthDays!);
    if (h.selectedYearDays != null) _yearDays.addAll(h.selectedYearDays!);
    if (h.periodicDays != null && h.periodicDays! > 0) {
      _periodicDays = h.periodicDays!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _animController.dispose();
    _customEmojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Custom App Bar
            _buildAppBar(theme, colorScheme, isDark),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Önizleme Kartı
                    _buildPreviewCard(theme, colorScheme),
                    const SizedBox(height: 32),

                    // Emoji Seçici
                    _buildSection(
                      title: 'Emoji',
                      child: _buildEmojiPicker(colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Renk Seçici
                    _buildSection(
                      title: 'Renk',
                      child: _buildColorPicker(colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // İsim
                    _buildSection(
                      title: 'İsim',
                      child: _buildNameField(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Açıklama
                    _buildSection(
                      title: 'Açıklama',
                      subtitle: 'opsiyonel',
                      child: _buildDescriptionField(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Sıklık
                    _buildSection(
                      title: 'Sıklık',
                      child: _buildFrequencySelector(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Başlangıç Tarihi
                    _buildSection(
                      title: 'Başlangıç Tarihi',
                      child: _buildStartDatePicker(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Hatırlatıcı
                    _buildReminderSection(theme, colorScheme),

                    const SizedBox(height: 32),

                    // Kaydet Butonu
                    _buildSaveButton(theme, colorScheme),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return SliverAppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.isEditing ? 'Düzenle' : 'Yeni Alışkanlık',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, ColorScheme colorScheme) {
    final name = _nameController.text.isEmpty
        ? 'Alışkanlık Adı'
        : _nameController.text;
    final desc = _descriptionController.text.isEmpty
        ? null
        : _descriptionController.text;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedColor.withOpacity(0.12),
            _selectedColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _selectedColor.withOpacity(0.15), width: 1.5),
      ),
      child: Row(
        children: [
          // Emoji Container
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (desc != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getFrequencyText(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _selectedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Text(
                '($subtitle)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  Widget _buildEmojiPicker(ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seçili emoji ve genişletme butonu
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _emojiExpanded = !_emojiExpanded);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: _emojiExpanded
                  ? Border.all(color: _selectedColor, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Emoji seç',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _emojiExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Genişletilmiş emoji seçici
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _emojiExpanded
              ? _buildExpandedEmojiPicker(theme, colorScheme)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildExpandedEmojiPicker(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hızlı erişim + Özel emoji butonu
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _quickEmojis
                      .map(
                        (emoji) =>
                            _buildEmojiItem(emoji, colorScheme, size: 36),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              // Özel emoji ekleme butonu
              GestureDetector(
                onTap: _showCustomEmojiDialog,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: _selectedColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Kategoriler
          ..._emojiCategories.entries.map(
            (entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.value
                      .map((emoji) => _buildEmojiItem(emoji, colorScheme))
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiItem(
    String emoji,
    ColorScheme colorScheme, {
    double size = 32,
  }) {
    final isSelected = emoji == _selectedEmoji;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedEmoji = emoji;
          _emojiExpanded = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected
              ? _selectedColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: _selectedColor, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(emoji, style: TextStyle(fontSize: size * 0.55)),
        ),
      ),
    );
  }

  void _showCustomEmojiDialog() {
    _customEmojiController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Özel Emoji',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Klavyeden bir emoji yazın',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customEmojiController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32),
                maxLength: 2,
                decoration: InputDecoration(
                  hintText: '😀',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                    0.4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: _selectedColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'İptal',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            FilledButton(
              onPressed: () {
                final text = _customEmojiController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _selectedEmoji = text.characters.first;
                    _emojiExpanded = false;
                  });
                }
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(backgroundColor: _selectedColor),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorPicker(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _colors.map((color) {
        final isSelected = color.value == _selectedColor.value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedColor = color);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 36 : 32,
            height: isSelected ? 36 : 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colorScheme.surface, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNameField(ThemeData theme, ColorScheme colorScheme) {
    return TextField(
      controller: _nameController,
      onChanged: (_) => setState(() {}),
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Örn: Su içmek, Kitap okumak...',
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.3),
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _selectedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildDescriptionField(ThemeData theme, ColorScheme colorScheme) {
    return TextField(
      controller: _descriptionController,
      maxLines: 2,
      onChanged: (_) => setState(() {}),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Kısa bir açıklama ekle...',
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _selectedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme, ColorScheme colorScheme) {
    final frequencies = [
      ('daily', 'Her gün', Icons.wb_sunny_outlined),
      ('weekly', 'Haftalık', Icons.view_week_outlined),
      ('monthly', 'Aylık', Icons.calendar_month_outlined),
      ('periodic', 'Periyodik', Icons.loop_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ana seçenekler
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: frequencies.map((f) {
            final isSelected = _selectedFrequency == f.$1;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedFrequency = f.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _selectedColor.withOpacity(0.12)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: _selectedColor, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      f.$3,
                      size: 18,
                      color: isSelected
                          ? _selectedColor
                          : colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.$2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? _selectedColor
                            : colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Detay seçenekleri
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              if (_selectedFrequency == 'weekly') ...[
                const SizedBox(height: 18),
                _buildWeekdaySelector(theme, colorScheme),
              ],
              if (_selectedFrequency == 'monthly') ...[
                const SizedBox(height: 18),
                _buildMonthDaySelector(theme, colorScheme),
              ],
              if (_selectedFrequency == 'periodic') ...[
                const SizedBox(height: 18),
                _buildPeriodicSelector(theme, colorScheme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector(ThemeData theme, ColorScheme colorScheme) {
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = _weeklyDays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              if (isSelected) {
                _weeklyDays.remove(dayNum);
              } else {
                _weeklyDays.add(dayNum);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor
                  : colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                days[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMonthDaySelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(31, (index) {
          final day = index + 1;
          final isSelected = _monthDays.contains(day);
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (isSelected) {
                  _monthDays.remove(day);
                } else {
                  _monthDays.add(day);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? _selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriodicSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Her',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<int>(
              value: _periodicDays,
              underline: const SizedBox(),
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _selectedColor,
                size: 20,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _selectedColor,
              ),
              items: List.generate(29, (i) => i + 2).map((n) {
                return DropdownMenuItem(value: n, child: Text('$n'));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _periodicDays = v);
              },
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'günde bir',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartDatePicker(ThemeData theme, ColorScheme colorScheme) {
    final isToday = _isSameDay(_startDate, DateTime.now());

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: _selectedColor),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _startDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: _selectedColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? 'Bugün' : _formatDate(_startDate),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isToday)
                    Text(
                      _getDaysFromNow(_startDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) {
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _getDaysFromNow(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Bugün';
    if (diff == 1) return 'Yarın';
    if (diff == -1) return 'Dün';
    if (diff > 0) return '$diff gün sonra';
    return '${-diff} gün önce';
  }

  Widget _buildReminderSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: _selectedColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hatırlatıcı',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _reminderEnabled
                            ? _reminderTime.format(context)
                            : 'Kapalı',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch.adaptive(
                value: _reminderEnabled,
                onChanged: (v) => setState(() => _reminderEnabled = v),
                activeColor: _selectedColor,
              ),
            ],
          ),
          if (_reminderEnabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickReminderTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: _selectedColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _reminderTime.format(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _selectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, ColorScheme colorScheme) {
    final canSave = _nameController.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: canSave ? _saveHabit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: canSave
              ? _selectedColor
              : colorScheme.outline.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSave
              ? [
                  BoxShadow(
                    color: _selectedColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.isEditing ? 'Değişiklikleri Kaydet' : 'Alışkanlık Oluştur',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: canSave
                  ? Colors.white
                  : colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    int selectedHour = _reminderTime.hour;
    int selectedMinute = _reminderTime.minute;

    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return Container(
              height: 340,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'İptal',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          'Saat Seç',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(
                            context,
                            TimeOfDay(
                              hour: selectedHour,
                              minute: selectedMinute,
                            ),
                          ),
                          child: Text(
                            'Tamam',
                            style: TextStyle(
                              color: _selectedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Wheel pickers
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(
                              initialItem: selectedHour,
                            ),
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedHour = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 24,
                              builder: (context, index) {
                                final isSelected = index == selectedHour;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 28 : 20,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? _selectedColor
                                          : colorScheme.onSurface.withOpacity(
                                              0.4,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Separator
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        // Minutes
                        SizedBox(
                          width: 80,
                          child: ListWheelScrollView.useDelegate(
                            controller: FixedExtentScrollController(
                              initialItem: selectedMinute,
                            ),
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedMinute = index);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 60,
                              builder: (context, index) {
                                final isSelected = index == selectedMinute;
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: isSelected ? 28 : 20,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? _selectedColor
                                          : colorScheme.onSurface.withOpacity(
                                              0.4,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _reminderTime = result);
    }
  }

  String _getFrequencyText() {
    switch (_selectedFrequency) {
      case 'daily':
        return 'Her gün';
      case 'weekly':
        if (_weeklyDays.isEmpty) return 'Haftalık';
        final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
        final selected = _weeklyDays.toList()..sort();
        return selected.map((d) => days[d - 1]).join(', ');
      case 'monthly':
        if (_monthDays.isEmpty) return 'Aylık';
        final sorted = _monthDays.toList()..sort();
        return 'Ayın ${sorted.join(", ")}. günleri';
      case 'periodic':
        return 'Her $_periodicDays günde bir';
      default:
        return 'Her gün';
    }
  }

  void _saveHabit() {
    if (_nameController.text.trim().isEmpty) return;

    final startDateStr = _dateKey(_startDate);
    final scheduled = _generateScheduledDates(start: _startDate);

    String frequencyType;
    List<int>? selectedWeekdays;
    List<int>? selectedMonthDays;
    List<String>? selectedYearDays;
    int? periodicDays;

    switch (_selectedFrequency) {
      case 'daily':
        frequencyType = FrequencyType.daily.toString();
        break;
      case 'weekly':
        frequencyType = FrequencyType.specificWeekdays.toString();
        selectedWeekdays = _weeklyDays.toList()..sort();
        break;
      case 'monthly':
        frequencyType = FrequencyType.specificMonthDays.toString();
        selectedMonthDays = _monthDays.toList()..sort();
        break;
      case 'yearly':
        frequencyType = FrequencyType.specificYearDays.toString();
        selectedYearDays = List<String>.from(_yearDays)..sort();
        break;
      case 'periodic':
        frequencyType = FrequencyType.periodic.toString();
        periodicDays = _periodicDays;
        break;
      default:
        frequencyType = FrequencyType.daily.toString();
    }

    final habit = Habit(
      id: widget.existingHabit?.id ?? UniqueKey().toString(),
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: widget.existingHabit?.icon ?? Icons.check_circle_outline,
      emoji: _selectedEmoji,
      color: _selectedColor,
      habitType: HabitType.simple,
      targetCount: 1,
      unit: null,
      frequency: _selectedFrequency,
      frequencyType: frequencyType,
      selectedWeekdays: selectedWeekdays,
      selectedMonthDays: selectedMonthDays,
      selectedYearDays: selectedYearDays,
      periodicDays: periodicDays,
      scheduledDates: scheduled,
      currentStreak: widget.existingHabit?.currentStreak ?? 0,
      isCompleted: widget.existingHabit?.isCompleted ?? false,
      progressDate: startDateStr,
      startDate: widget.existingHabit?.startDate ?? startDateStr,
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderEnabled ? _reminderTime : null,
    );

    Navigator.of(context).pop(habit);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<String> _generateScheduledDates({
    required DateTime start,
    int horizonDays = 365,
  }) {
    final dates = <String>[];
    final startOnly = DateTime(start.year, start.month, start.day);
    final end = startOnly.add(Duration(days: horizonDays - 1));

    if (_selectedFrequency == 'daily') {
      for (int i = 0; i < horizonDays; i++) {
        dates.add(_dateKey(startOnly.add(Duration(days: i))));
      }
      return dates;
    }

    if (_selectedFrequency == 'weekly') {
      final week = _weeklyDays.isEmpty ? {DateTime.now().weekday} : _weeklyDays;
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        if (week.contains(d.weekday)) dates.add(_dateKey(d));
        d = d.add(const Duration(days: 1));
      }
      return dates;
    }

    if (_selectedFrequency == 'monthly') {
      final days = _monthDays.isEmpty ? {startOnly.day} : _monthDays;
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        if (days.contains(d.day)) dates.add(_dateKey(d));
        d = d.add(const Duration(days: 1));
      }
      return dates;
    }

    if (_selectedFrequency == 'periodic') {
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        dates.add(_dateKey(d));
        d = d.add(Duration(days: _periodicDays));
      }
      return dates;
    }

    return dates;
  }
}
