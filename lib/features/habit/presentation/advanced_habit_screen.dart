import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mira/l10n/app_localizations.dart';

import '../domain/habit_model.dart';
import '../domain/habit_types.dart';
import '../domain/subtask_model.dart';

/// Minimalist gelişmiş alışkanlık oluşturma ekranı.
/// Sayısal ve zamanlayıcı destekli alışkanlıklar için.
class AdvancedHabitScreen extends StatefulWidget {
  const AdvancedHabitScreen({
    super.key,
    this.existingHabit,
    this.editingHabitMap,
    this.useVisionDayOffsets = false,
    this.visionStartDate,
    this.returnAsMap = false,
  });

  /// Mevcut habit objesi (düzenleme modu)
  final Habit? existingHabit;

  /// Vision ekranlarından gelen Map formatında alışkanlık verisi
  final Map<String, dynamic>? editingHabitMap;

  /// Vision gün offsetleri kullanılsın mı (1-365 format)
  final bool useVisionDayOffsets;

  /// Vision başlangıç tarihi (offset hesaplaması için)
  final DateTime? visionStartDate;

  /// True ise Habit yerine Map döndürür (vision modunda kullanılır)
  final bool returnAsMap;

  bool get isEditing => existingHabit != null || editingHabitMap != null;

  @override
  State<AdvancedHabitScreen> createState() => _AdvancedHabitScreenState();
}

class _AdvancedHabitScreenState extends State<AdvancedHabitScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _scrollController = ScrollController();

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // State
  HabitType _habitType = HabitType.numerical;
  String _selectedEmoji = '🎯';
  Color _selectedColor = const Color(0xFF6366F1);
  String _selectedFrequency = 'daily';
  final Set<int> _weeklyDays = {};
  final Set<int> _monthDays = {};
  final List<String> _yearDays = [];
  int _periodicDays = 2;
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  // Hedef tipi
  NumericalTargetType _numericalTargetType = NumericalTargetType.minimum;
  TimerTargetType _timerTargetType = TimerTargetType.minimum;
  Duration _timerDuration = const Duration(minutes: 30);

  // Date Range
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  // Emoji picker state
  bool _emojiExpanded = false;
  final _customEmojiController = TextEditingController();

  // Subtasks state
  final List<TextEditingController> _subtaskControllers = [];
  final List<String> _subtaskIds = [];

  // Renk paleti - Canlı renkler
  static const List<Color> _colors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF14B8A6),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
  ];

  // Pastel renk paleti
  static const List<Color> _pastelColors = [
    Color(0xFFA5B4FC), // Pastel Indigo
    Color(0xFFC4B5FD), // Pastel Violet
    Color(0xFFF9A8D4), // Pastel Pink
    Color(0xFFFCA5A5), // Pastel Red
    Color(0xFFFDBA74), // Pastel Orange
    Color(0xFFFDE047), // Pastel Yellow
    Color(0xFF86EFAC), // Pastel Green
    Color(0xFF5EEAD4), // Pastel Teal
    Color(0xFF67E8F9), // Pastel Cyan
    Color(0xFF93C5FD), // Pastel Blue
    Color(0xFFD8B4FE), // Pastel Purple
    Color(0xFFFBCFE8), // Pastel Rose
  ];

  // Emoji listesi - Kategorize edilmiş
  static const List<String> _quickEmojis = [
    '🎯',
    '💪',
    '⏱️',
    '📚',
    '💧',
    '🏃',
    '🧘',
    '🍎',
  ];

  static Map<String, List<String>> _getEmojiCategories(AppLocalizations l10n) =>
      {
        l10n.emojiCategoryPopular: [
          '🎯',
          '💪',
          '⏱️',
          '📚',
          '💧',
          '🏃',
          '🧘',
          '🍎',
          '🔥',
          '⭐',
        ],
        l10n.emojiCategoryHealth: [
          '💊',
          '🏥',
          '🩺',
          '💉',
          '🧬',
          '🦷',
          '👁️',
          '🫀',
          '🧠',
          '🦴',
        ],
        l10n.emojiCategorySport: [
          '🏋️',
          '🚴',
          '🏊',
          '⚽',
          '🎾',
          '🏀',
          '🥊',
          '🧗',
          '🎿',
          '🏌️',
        ],
        l10n.emojiCategoryLife: [
          '🏠',
          '🌱',
          '☀️',
          '🌙',
          '❤️',
          '⚡',
          '🎉',
          '🎂',
          '🎁',
          '💤',
        ],
        l10n.emojiCategoryProductivity: [
          '✍️',
          '💻',
          '📱',
          '📝',
          '📖',
          '🎨',
          '🎵',
          '💰',
          '📊',
          '⏰',
        ],
        l10n.emojiCategoryFood: [
          '🥗',
          '🥤',
          '🍵',
          '☕',
          '🥛',
          '🍎',
          '🥑',
          '🥕',
          '🍳',
          '🥪',
        ],
        l10n.emojiCategoryNature: [
          '🌿',
          '🌸',
          '🌺',
          '🌻',
          '🍀',
          '🌲',
          '🌊',
          '⛰️',
          '🌈',
          '🦋',
        ],
        l10n.emojiCategoryAnimals: [
          '🐕',
          '🐈',
          '🐦',
          '🐠',
          '🐢',
          '🦔',
          '🐰',
          '🦁',
          '🐼',
          '🦊',
        ],
        l10n.emojiCategoryCare: [
          '🚿',
          '🧴',
          '🧼',
          '🧹',
          '🧺',
          '🧷',
          '💅',
          '💇',
          '🧔',
          '🧍',
        ],
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
    _loadFromMap();
  }

  void _loadExistingHabit() {
    final h = widget.existingHabit;
    if (h == null) return;

    _nameController.text = h.title;
    _descriptionController.text = h.description;
    _selectedColor = h.color;
    _selectedEmoji = h.emoji ?? '🎯';
    _habitType = h.habitType;
    _reminderEnabled = h.reminderEnabled;
    _reminderTime = h.reminderTime ?? const TimeOfDay(hour: 9, minute: 0);

    if (h.targetCount > 0) {
      _targetController.text = h.targetCount.toString();
      // Timer için targetCount dakika cinsinden saklanıyor
      if (h.habitType == HabitType.timer) {
        _timerDuration = Duration(minutes: h.targetCount);
      }
    }
    if (h.unit != null) {
      _unitController.text = h.unit!;
    }
    _numericalTargetType = h.numericalTargetType;
    _timerTargetType = h.timerTargetType;

    if (h.startDate != null) {
      try {
        _startDate = DateTime.parse(h.startDate!);
      } catch (_) {}
    }
    if (h.endDate != null) {
      try {
        _endDate = DateTime.parse(h.endDate!);
      } catch (_) {}
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

    // Subtasks yükle
    if (h.subtasks.isNotEmpty) {
      for (final subtask in h.subtasks) {
        final controller = TextEditingController(text: subtask.title);
        _subtaskControllers.add(controller);
        _subtaskIds.add(subtask.id);
      }
    }
  }

  /// Map formatından alışkanlık verisi yükle (vision modları için)
  void _loadFromMap() {
    final m = widget.editingHabitMap;
    if (m == null) return;

    _nameController.text =
        (m['title'] as String?) ?? (m['name'] as String?) ?? '';
    _descriptionController.text = m['description'] as String? ?? '';

    if (m['color'] != null) {
      _selectedColor = m['color'] is Color
          ? m['color'] as Color
          : Color(m['color'] as int);
    }

    _selectedEmoji = m['emoji'] as String? ?? '🎯';

    if (m['habitType'] != null) {
      final val = m['habitType'];
      if (val is HabitType) {
        _habitType = val;
      } else if (val is String) {
        _habitType = HabitType.values.firstWhere(
          (e) => e.toString() == val || e.toString() == 'HabitType.$val',
          orElse: () => HabitType.simple,
        );
      }
    }

    int? tc;
    if (m['targetCount'] != null) {
      tc = m['targetCount'] as int;
    } else if (m['numericalTarget'] != null) {
      tc = (m['numericalTarget'] as num).toInt();
    } else if (m['timerTargetMinutes'] != null) {
      tc = (m['timerTargetMinutes'] as num).toInt();
    }

    if (tc != null) {
      _targetController.text = tc.toString();
      if (_habitType == HabitType.timer) {
        _timerDuration = Duration(minutes: tc);
      }
    }

    if (m['unit'] != null) {
      _unitController.text = m['unit'] as String;
    } else if (m['numericalUnit'] != null) {
      _unitController.text = m['numericalUnit'] as String;
    }

    if (m['numericalTargetType'] != null) {
      final val = m['numericalTargetType'];
      if (val is NumericalTargetType) {
        _numericalTargetType = val;
      } else if (val is String) {
        // Handle both "NumericalTargetType.minimum" and "minimum" formats
        if (val.contains('exact')) {
          _numericalTargetType = NumericalTargetType.exact;
        } else if (val.contains('max')) {
          _numericalTargetType = NumericalTargetType.maximum;
        } else {
          _numericalTargetType = NumericalTargetType.minimum;
        }
      }
    }
    if (m['timerTargetType'] != null) {
      final val = m['timerTargetType'];
      if (val is TimerTargetType) {
        _timerTargetType = val;
      } else if (val is String) {
        if (val.contains('exact')) {
          _timerTargetType = TimerTargetType.exact;
        } else if (val.contains('max')) {
          _timerTargetType = TimerTargetType.maximum;
        } else {
          _timerTargetType = TimerTargetType.minimum;
        }
      }
    }

    if (m['startDate'] != null) {
      try {
        _startDate = DateTime.parse(m['startDate'] as String);
      } catch (_) {}
    }
    if (m['endDate'] != null) {
      try {
        _endDate = DateTime.parse(m['endDate'] as String);
      } catch (_) {}
    }

    _reminderEnabled = m['reminderEnabled'] as bool? ?? false;
    if (m['reminderTime'] != null) {
      final rt = m['reminderTime'];
      if (rt is Map) {
        _reminderTime = TimeOfDay(
          hour: rt['hour'] as int? ?? 9,
          minute: rt['minute'] as int? ?? 0,
        );
      } else if (rt is TimeOfDay) {
        _reminderTime = rt;
      }
    }

    // Sıklık bilgisi
    final ft =
        (m['frequencyType'] as String?)?.toLowerCase() ??
        (m['frequency'] as String?)?.toLowerCase();
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

    if (m['selectedWeekdays'] != null) {
      _weeklyDays.addAll((m['selectedWeekdays'] as List).cast<int>());
    }
    if (m['selectedMonthDays'] != null) {
      _monthDays.addAll((m['selectedMonthDays'] as List).cast<int>());
    }
    if (m['selectedYearDays'] != null) {
      _yearDays.addAll((m['selectedYearDays'] as List).cast<String>());
    }
    if (m['periodicDays'] != null) {
      _periodicDays = (m['periodicDays'] as num).toInt();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    _scrollController.dispose();
    _animController.dispose();
    _customEmojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(theme, colorScheme),
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

                    // Alışkanlık Tipi
                    _buildSection(
                      title: AppLocalizations.of(context)!.habitTypeLabel,
                      child: _buildHabitTypeSelector(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Emoji Seçici
                    _buildSection(
                      title: AppLocalizations.of(context)!.emojiLabel,
                      child: _buildEmojiPicker(colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Renk Seçici
                    _buildSection(
                      title: AppLocalizations.of(context)!.colorLabel,
                      child: _buildColorPicker(colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // İsim
                    _buildSection(
                      title: AppLocalizations.of(context)!.nameLabel,
                      child: _buildNameField(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Açıklama
                    _buildSection(
                      title: AppLocalizations.of(context)!.descriptionLabel,
                      subtitle: AppLocalizations.of(context)!.optionalLabel,
                      child: _buildDescriptionField(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Hedef
                    _buildTargetSection(theme, colorScheme),
                    const SizedBox(height: 28),

                    // Alt Görevler (sadece subtasks türü için)
                    if (_habitType == HabitType.subtasks) ...[
                      _buildSubtasksSection(theme, colorScheme),
                      const SizedBox(height: 28),
                    ],

                    // Sıklık
                    _buildSection(
                      title: AppLocalizations.of(context)!.frequencyLabel,
                      child: _buildFrequencySelector(theme, colorScheme),
                    ),
                    const SizedBox(height: 28),

                    // Tarih Aralığı
                    _buildSection(
                      title: AppLocalizations.of(context)!.dateRangeLabel,
                      child: _buildDateRangeSection(theme, colorScheme),
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

  Widget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
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
          widget.isEditing
              ? AppLocalizations.of(context)!.edit
              : AppLocalizations.of(context)!.advancedHabitTitle,
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
        ? AppLocalizations.of(context)!.habitNamePlaceholder
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
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
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
                        _getHabitTypeText(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _selectedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '• ${_getTargetText()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      '• ${_getFrequencyText()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
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
              Flexible(
                child: Text(
                  '($subtitle)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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

  Widget _buildHabitTypeSelector(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      (
        HabitType.numerical,
        l10n.numericalType,
        Icons.numbers_rounded,
        l10n.numericalDescription,
      ),
      (
        HabitType.timer,
        l10n.timerType,
        Icons.timer_outlined,
        l10n.timerDescription,
      ),
      (
        HabitType.checkbox,
        l10n.checkboxType,
        Icons.check_box_outlined,
        l10n.checkboxTypeDesc,
      ),
      (
        HabitType.subtasks,
        l10n.subtasksType,
        Icons.checklist_rounded,
        l10n.subtasksTypeDesc,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: types.map((t) {
        final isSelected = _habitType == t.$1;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _habitType = t.$1);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor.withOpacity(0.12)
                  : colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: _selectedColor, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withOpacity(0.15)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    t.$3,
                    color: isSelected
                        ? _selectedColor
                        : colorScheme.onSurface.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.$2,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _selectedColor : colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  t.$4,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
                    AppLocalizations.of(context)!.selectEmoji,
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
          ..._getEmojiCategories(AppLocalizations.of(context)!).entries.map(
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
            AppLocalizations.of(context)!.customEmoji,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.typeEmojiHint,
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
                AppLocalizations.of(context)!.cancel,
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
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorPicker(ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Canlı renkler
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _colors
              .map((color) => _buildColorItem(color, colorScheme))
              .toList(),
        ),
        const SizedBox(height: 16),

        // Pastel başlığı
        Text(
          l10n.pastelColors,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        // Pastel renkler
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _pastelColors
              .map(
                (color) => _buildColorItem(color, colorScheme, isPastel: true),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildColorItem(
    Color color,
    ColorScheme colorScheme, {
    bool isPastel = false,
  }) {
    final isSelected = color.value == _selectedColor.value;
    final checkColor = isPastel ? colorScheme.onSurface : Colors.white;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedColor = color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 34 : 30,
        height: isSelected ? 34 : 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  width: 2.5,
                )
              : (isPastel
                    ? Border.all(
                        color: colorScheme.outline.withOpacity(0.15),
                        width: 1,
                      )
                    : null),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(Icons.check_rounded, color: checkColor, size: 16)
            : null,
      ),
    );
  }

  Widget _buildNameField(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _nameController,
      onChanged: (_) => setState(() {}),
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: _habitType == HabitType.timer
            ? l10n.habitNameHintTimer
            : l10n.habitNameHintNumerical,
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
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _descriptionController,
      maxLines: 2,
      onChanged: (_) => setState(() {}),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: l10n.habitDescriptionHint,
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

  // Predefined unit types for numerical habits
  List<(String, String)> _getPredefinedUnits(AppLocalizations l10n) {
    return [
      (l10n.unitAdet, '🔢'),
      (l10n.unitBardak, '🥤'),
      (l10n.unitSayfa, '📄'),
      (l10n.unitKm, '🛣️'),
      (l10n.unitLitre, '💧'),
      (l10n.unitKalori, '🔥'),
      (l10n.unitAdim, '👣'),
      (l10n.unitKez, '🔄'),
    ];
  }

  Widget _buildTargetSection(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;

    // Checkbox türü için hedef gerekmiyor
    if (_habitType == HabitType.checkbox) {
      return const SizedBox.shrink();
    }

    // Subtasks türü için hedef gerekmiyor (alt görevler tamamlanma kriteri)
    if (_habitType == HabitType.subtasks) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: l10n.target,
      child: _habitType == HabitType.timer
          ? _buildTimerTargetSection(theme, colorScheme)
          : _buildNumericalTargetSection(theme, colorScheme),
    );
  }

  Widget _buildNumericalTargetSection(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final predefinedUnits = _getPredefinedUnits(l10n);
    final currentUnit = _unitController.text.isNotEmpty
        ? _unitController.text
        : l10n.unitAdet;
    final isCustomUnit = !predefinedUnits.any((u) => u.$1 == currentUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hedef tipi seçici
        _buildTargetTypeRow(theme, colorScheme),
        const SizedBox(height: 16),

        // Hedef değer
        TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: l10n.amount,
            labelStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Birim başlığı
        Text(
          l10n.unit,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Predefined unit chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...predefinedUnits.map((u) {
              final isSelected = currentUnit == u.$1;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _unitController.text = u.$1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withOpacity(0.15)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _selectedColor
                          : colorScheme.outline.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(u.$2, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        u.$1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? _selectedColor
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Custom unit button
            GestureDetector(
              onTap: () => _showCustomUnitDialog(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isCustomUnit
                      ? _selectedColor.withOpacity(0.15)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCustomUnit
                        ? _selectedColor
                        : colorScheme.outline.withOpacity(0.1),
                    width: isCustomUnit ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: isCustomUnit
                          ? _selectedColor
                          : colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCustomUnit ? currentUnit : l10n.custom,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isCustomUnit
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isCustomUnit
                            ? _selectedColor
                            : colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomUnitDialog() {
    final customController = TextEditingController(text: _unitController.text);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.customUnit),
        content: TextField(
          controller: customController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.customUnitHint,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _selectedColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              if (customController.text.trim().isNotEmpty) {
                setState(
                  () => _unitController.text = customController.text.trim(),
                );
              }
              Navigator.pop(context);
            },
            child: Text(
              l10n.ok,
              style: TextStyle(
                color: _selectedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetTypeRow(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      (NumericalTargetType.minimum, l10n.atLeast, Icons.trending_up_rounded),
      (NumericalTargetType.exact, l10n.exact, Icons.check_circle_outline),
      (NumericalTargetType.maximum, l10n.atMost, Icons.trending_down_rounded),
    ];

    return Row(
      children: types.map((t) {
        final isSelected = _numericalTargetType == t.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _numericalTargetType = t.$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: t.$1 != NumericalTargetType.maximum ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? _selectedColor.withOpacity(0.12)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: _selectedColor, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    t.$3,
                    size: 18,
                    color: isSelected
                        ? _selectedColor
                        : colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.$2,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? _selectedColor
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimerTargetSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer hedef tipi
        _buildTimerTargetTypeRow(theme, colorScheme),
        const SizedBox(height: 16),

        // Süre seçici
        GestureDetector(
          onTap: _pickDuration,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _selectedColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: _selectedColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  _formatDuration(_timerDuration),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _selectedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerTargetTypeRow(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      (TimerTargetType.minimum, l10n.atLeast, Icons.trending_up_rounded),
      (TimerTargetType.exact, l10n.exact, Icons.check_circle_outline),
      (TimerTargetType.maximum, l10n.atMost, Icons.trending_down_rounded),
    ];

    return Row(
      children: types.map((t) {
        final isSelected = _timerTargetType == t.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _timerTargetType = t.$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: t.$1 != TimerTargetType.maximum ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? _selectedColor.withOpacity(0.12)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: _selectedColor, width: 2)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    t.$3,
                    size: 18,
                    color: isSelected
                        ? _selectedColor
                        : colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.$2,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? _selectedColor
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final frequencies = [
      ('daily', l10n.everyDay, Icons.wb_sunny_outlined),
      ('weekly', l10n.weekly, Icons.view_week_outlined),
      ('monthly', l10n.monthly, Icons.calendar_month_outlined),
      ('periodic', l10n.periodic, Icons.loop_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.weekdaysShortMon,
      l10n.weekdaysShortTue,
      l10n.weekdaysShortWed,
      l10n.weekdaysShortThu,
      l10n.weekdaysShortFri,
      l10n.weekdaysShortSat,
      l10n.weekdaysShortSun,
    ];

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
            AppLocalizations.of(context)!.everyLabel,
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
            AppLocalizations.of(context)!.daysIntervalLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
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
                        AppLocalizations.of(context)!.reminderLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _reminderEnabled
                            ? _reminderTime.format(context)
                            : AppLocalizations.of(context)!.offLabel,
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

  Widget _buildSubtasksSection(ThemeData theme, ColorScheme colorScheme) {
    return _buildSection(
      title: AppLocalizations.of(context)!.subtasksType,
      subtitle: AppLocalizations.of(context)!.completeAllSubtasksToFinish,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mevcut alt görevler - maksimum yükseklik ile sınırlı
          if (_subtaskControllers.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _subtaskControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskControllers[index],
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.subtaskIndex(index + 1),
                              hintStyle: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest
                                  .withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: _selectedColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _subtaskControllers[index].dispose();
                              _subtaskControllers.removeAt(index);
                              _subtaskIds.removeAt(index);
                            });
                          },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (_subtaskControllers.isNotEmpty) const SizedBox(height: 12),
          // Yeni alt görev ekle butonu
          GestureDetector(
            onTap: () {
              setState(() {
                _subtaskControllers.add(TextEditingController());
                _subtaskIds.add(
                  DateTime.now().millisecondsSinceEpoch.toString(),
                );
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: _selectedColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.addSubtask,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Future<void> _pickDuration() async {
    final result = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DurationPickerSheet(
        initialDuration: _timerDuration,
        accentColor: _selectedColor,
      ),
    );
    if (result != null) setState(() => _timerDuration = result);
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '$hours sa $minutes dk';
    if (hours > 0) return '$hours saat';
    return '$minutes dakika';
  }

  String _getHabitTypeText() {
    switch (_habitType) {
      case HabitType.timer:
        return 'Zamanlayıcı';
      case HabitType.numerical:
        return 'Sayısal';
      default:
        return 'Sayısal';
    }
  }

  String _getTargetText() {
    if (_habitType == HabitType.timer) {
      final prefix = _timerTargetType == TimerTargetType.minimum
          ? 'En az'
          : _timerTargetType == TimerTargetType.maximum
          ? 'En fazla'
          : 'Tam';
      return '$prefix ${_formatDuration(_timerDuration)}';
    } else {
      final target = int.tryParse(_targetController.text) ?? 1;
      final unit = _unitController.text.isEmpty ? 'adet' : _unitController.text;
      final prefix = _numericalTargetType == NumericalTargetType.minimum
          ? 'En az'
          : _numericalTargetType == NumericalTargetType.maximum
          ? 'En fazla'
          : 'Tam';
      return '$prefix $target $unit';
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

  Widget _buildDateRangeSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildDateRow(
          theme,
          colorScheme,
          label: 'Başlangıç',
          date: _startDate,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              locale: const Locale('tr'),
            );
            if (picked != null) {
              setState(() => _startDate = picked);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildDateRow(
          theme,
          colorScheme,
          label: 'Bitiş',
          date: _endDate,
          isOptional: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
              firstDate: _startDate,
              lastDate: DateTime(2030),
              locale: const Locale('tr'),
            );
            if (picked != null) {
              setState(() => _endDate = picked);
            }
          },
          onClear: () => setState(() => _endDate = null),
        ),
      ],
    );
  }

  Widget _buildDateRow(
    ThemeData theme,
    ColorScheme colorScheme, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool isOptional = false,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? _formatDate(date) : 'Seçilmedi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: date != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            if (isOptional && date != null && onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
                color: colorScheme.onSurface.withOpacity(0.5),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}.${d.month}.${d.year}';
  }

  void _saveHabit() {
    if (_nameController.text.trim().isEmpty) return;

    final startDateStr = _dateKey(_startDate);
    final endDateStr = _endDate != null ? _dateKey(_endDate!) : null;
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

    // Vision Map modunda Map döndür
    if (widget.returnAsMap) {
      final existingId =
          widget.editingHabitMap?['id'] ??
          widget.existingHabit?.id ??
          UniqueKey().toString();
      final map = <String, dynamic>{
        'id': existingId,
        'title': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'color': _selectedColor,
        'emoji': _selectedEmoji,
        'habitType': _habitType,
        'targetCount': _habitType == HabitType.timer
            ? _timerDuration.inMinutes
            : _habitType == HabitType.checkbox
            ? 1
            : _habitType == HabitType.subtasks
            ? 1
            : (int.tryParse(_targetController.text) ?? 1),
        if (_habitType == HabitType.numerical &&
            _unitController.text.isNotEmpty)
          'unit': _unitController.text,
        'numericalTargetType': _numericalTargetType,
        'timerTargetType': _timerTargetType,
        'frequency': _selectedFrequency,
        'frequencyType': frequencyType,
        if (selectedWeekdays != null) 'selectedWeekdays': selectedWeekdays,
        if (selectedMonthDays != null) 'selectedMonthDays': selectedMonthDays,
        if (selectedYearDays != null) 'selectedYearDays': selectedYearDays,
        if (periodicDays != null) 'periodicDays': periodicDays,
        'scheduledDates': scheduled,
        'startDate': startDateStr,
        'endDate': endDateStr,
        'reminderEnabled': _reminderEnabled,
        if (_reminderEnabled)
          'reminderTime': {
            'hour': _reminderTime.hour,
            'minute': _reminderTime.minute,
          },
        // Subtasks
        if (_habitType == HabitType.subtasks)
          'subtasks': _subtaskControllers
              .asMap()
              .entries
              .where((e) => e.value.text.trim().isNotEmpty)
              .map(
                (e) => {
                  'id': _subtaskIds[e.key],
                  'title': e.value.text.trim(),
                  'isCompleted': false,
                },
              )
              .toList(),
        'isAdvanced': true,
        // Mevcut verileri koru
        if (widget.editingHabitMap?['currentStreak'] != null)
          'currentStreak': widget.editingHabitMap!['currentStreak'],
        if (widget.editingHabitMap?['isCompleted'] != null)
          'isCompleted': widget.editingHabitMap!['isCompleted'],
        if (widget.editingHabitMap?['visionId'] != null)
          'visionId': widget.editingHabitMap!['visionId'],
        if (widget.editingHabitMap?['visionStartDate'] != null)
          'visionStartDate': widget.editingHabitMap!['visionStartDate'],
        if (widget.editingHabitMap?['visionEndDate'] != null)
          'visionEndDate': widget.editingHabitMap!['visionEndDate'],
      };
      Navigator.of(context).pop(map);
      return;
    }

    final habit = Habit(
      id:
          widget.existingHabit?.id ??
          widget.editingHabitMap?['id'] as String? ??
          UniqueKey().toString(),
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: widget.existingHabit?.icon ?? Icons.check_circle_outline,
      emoji: _selectedEmoji,
      color: _selectedColor,
      habitType: _habitType,
      // Timer için targetCount dakika cinsinden
      // Checkbox ve subtasks için targetCount 1
      targetCount: _habitType == HabitType.timer
          ? _timerDuration.inMinutes
          : _habitType == HabitType.checkbox
          ? 1
          : _habitType == HabitType.subtasks
          ? 1
          : (int.tryParse(_targetController.text) ?? 1),
      unit: _habitType == HabitType.numerical
          ? (_unitController.text.isEmpty ? null : _unitController.text)
          : null,
      numericalTargetType: _numericalTargetType,
      timerTargetType: _timerTargetType,
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
      startDate: startDateStr,
      endDate: endDateStr,
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderEnabled ? _reminderTime : null,
      subtasks: _habitType == HabitType.subtasks
          ? _subtaskControllers
                .asMap()
                .entries
                .where((e) => e.value.text.trim().isNotEmpty)
                .map(
                  (e) => Subtask(
                    id: _subtaskIds[e.key],
                    title: e.value.text.trim(),
                    isCompleted: false,
                  ),
                )
                .toList()
          : [],
    )..isAdvanced = true;

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

    final DateTime end;
    if (_endDate != null) {
      end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    } else {
      end = startOnly.add(Duration(days: horizonDays - 1));
    }

    if (_selectedFrequency == 'daily') {
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        dates.add(_dateKey(d));
        d = d.add(const Duration(days: 1));
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

/// Süre seçici bottom sheet
class _DurationPickerSheet extends StatefulWidget {
  const _DurationPickerSheet({
    required this.initialDuration,
    required this.accentColor,
  });

  final Duration initialDuration;
  final Color accentColor;

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes.remainder(60);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Süre Seç',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),

          // Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hours
              _buildPickerColumn(
                value: _hours,
                maxValue: 23,
                label: 'Saat',
                onChanged: (v) => setState(() => _hours = v),
                theme: theme,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 24),
              Text(':', style: theme.textTheme.headlineMedium),
              const SizedBox(width: 24),
              // Minutes
              _buildPickerColumn(
                value: _minutes,
                maxValue: 59,
                step: 5,
                label: 'Dakika',
                onChanged: (v) => setState(() => _minutes = v),
                theme: theme,
                colorScheme: colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Confirm button
          GestureDetector(
            onTap: () {
              Navigator.pop(
                context,
                Duration(hours: _hours, minutes: _minutes),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Tamam',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPickerColumn({
    required int value,
    required int maxValue,
    int step = 1,
    required String label,
    required ValueChanged<int> onChanged,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final items = <int>[];
    for (int i = 0; i <= maxValue; i += step) {
      items.add(i);
    }

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(
              initialItem: items.indexOf(value),
            ),
            onSelectedItemChanged: (index) => onChanged(items[index]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final isSelected = items[index] == value;
                return Center(
                  child: Text(
                    items[index].toString().padLeft(2, '0'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? widget.accentColor
                          : colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
