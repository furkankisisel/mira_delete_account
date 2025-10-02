import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/emoji_presets.dart';
import '../domain/habit_types.dart';
import '../domain/category_repository.dart';

// Logical step identifiers to allow reordering without changing logic.
// Enums cannot be declared inside classes in Dart, so this must be top-level.
enum _StepId { type, details, frequency, scheduling }

class AdvancedHabitWizardScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? editingHabit;
  // When true, show Scheduling step before Frequency step
  final bool scheduleBeforeFrequency;
  // When true, Scheduling step uses vision-day offsets (1-365)
  final bool useVisionDayOffsets;
  // Optional explicit vision start date to compute 1-based day offsets.
  final DateTime? visionStartDate;

  const AdvancedHabitWizardScreen({
    super.key,
    this.isEditing = false,
    this.editingHabit,
    this.scheduleBeforeFrequency = false,
    this.useVisionDayOffsets = false,
    this.visionStartDate,
  });

  @override
  State<AdvancedHabitWizardScreen> createState() =>
      _AdvancedHabitWizardScreenState();
}

class _AdvancedHabitWizardScreenState extends State<AdvancedHabitWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  int get _totalSteps => _steps.length;

  List<_StepId> get _steps {
    // In vision-day-offsets mode, frequency step is not needed; remove it.
    if (widget.useVisionDayOffsets) {
      return const [_StepId.details, _StepId.type, _StepId.scheduling];
    }
    // Default: retain configurable order of frequency/scheduling
    return widget.scheduleBeforeFrequency
        ? const [
            _StepId.details,
            _StepId.type,
            _StepId.scheduling,
            _StepId.frequency,
          ]
        : const [
            _StepId.details,
            _StepId.type,
            _StepId.frequency,
            _StepId.scheduling,
          ];
  }

  // Step 1: Category
  String? _selectedCategoryId;
  final List<HabitCategory> _predefinedCategories = [
    // Names will be localized at render-time using l10n and these IDs
    HabitCategory('health', 'health', Icons.favorite, Colors.red, emoji: '💊'),
    HabitCategory(
      'fitness',
      'fitness',
      Icons.fitness_center,
      Colors.orange,
      emoji: '🏋️',
    ),
    HabitCategory(
      'productivity',
      'productivity',
      Icons.work,
      Colors.blue,
      emoji: '💼',
    ),
    HabitCategory(
      'mindfulness',
      'mindfulness',
      Icons.self_improvement,
      Colors.purple,
      emoji: '🧘',
    ),
    HabitCategory(
      'education',
      'education',
      Icons.school,
      Colors.green,
      emoji: '📚',
    ),
    HabitCategory('social', 'social', Icons.groups, Colors.teal, emoji: '👥'),
  ];
  final List<HabitCategory> _customCategories = [];

  // Step 2: Habit Type
  HabitType? _selectedHabitType;

  // Numerical Habit Configuration
  int _numericalTarget = 1;
  NumericalTargetType _numericalTargetType = NumericalTargetType.exact;
  String _numericalUnit = '';
  // Removed _numericalDailyFrequency & _numericalTimePeriod (UI simplified)

  // Timer Habit Configuration
  int _timerTargetMinutes = 30;
  TimerTargetType _timerTargetType = TimerTargetType.minimum;
  // Removed _timerDailyFrequency & _timerTimePeriod (UI simplified)

  // Step 3: Details
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Visual identity when not using predefined category
  Color _selectedColor = Colors.blue;
  String _selectedEmoji = '🌟';

  // Additional controllers for manual input
  final _numericalTargetController = TextEditingController();
  final _numericalUnitController = TextEditingController();
  // Removed _numericalFrequencyController
  final _timerTargetController = TextEditingController();
  // Removed _timerFrequencyController

  // Step 4: Frequency
  FrequencyType? _selectedFrequencyType;
  List<int> _selectedWeekdays = [];
  List<int> _selectedMonthDays = [];
  List<DateTime> _selectedYearDays = [];
  int _periodicDays = 1;

  // Step 5: Scheduling
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _hasEndDate = false;

  // Vision-day scheduling (1-365) when enabled
  int _visionStartDay = 1;
  int? _visionEndDay;
  String? _visionEndError;
  String? _visionStartError;
  final TextEditingController _visionStartDayCtrl = TextEditingController();
  final TextEditingController _visionEndDayCtrl = TextEditingController();
  // Manual active days within [start..end] when using vision offsets
  final Set<int> _activeOffsets = <int>{};

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Düzenleme modundaysa mevcut değerleri yükle
    if (widget.isEditing && widget.editingHabit != null) {
      _loadHabitForEditing();
    }

    // Load persisted custom categories
    _loadCustomCategories();
  }

  Future<void> _loadCustomCategories() async {
    await CategoryRepository.instance.initialize();
    setState(() {
      _customCategories
        ..clear()
        ..addAll(CategoryRepository.instance.customCategories);
    });
    // Listen for external changes while this screen is alive
    CategoryRepository.instance.addListener(_onCategoriesChanged);
  }

  // Listener cleanup merged into main dispose below

  void _onCategoriesChanged() {
    setState(() {
      _customCategories
        ..clear()
        ..addAll(CategoryRepository.instance.customCategories);
    });
  }

  void _loadHabitForEditing() {
    final habit = widget.editingHabit!;

    // Temel bilgileri yükle
    _nameController.text = habit['title'] ?? '';
    _descriptionController.text = habit['description'] ?? '';

    // Habit tipini ayarla
    if (habit['habitType'] != null) {
      _selectedHabitType = habit['habitType'];
    }

    // Kategori: düzenlemede mevcut görsel kimliği koru; mümkünse otomatik eşleştir
    _selectedCategoryId = null;
    try {
      // 1) Emoji ile eşleşme
      final em = habit['emoji']?.toString();
      if (em != null && em.isNotEmpty) {
        final cat = _predefinedCategories.firstWhere(
          (c) => c.emoji == em,
          orElse: () => HabitCategory('_none', '', Icons.help, Colors.grey),
        );
        if (cat.id != '_none') {
          _selectedCategoryId = cat.id;
        }
      }
      // 2) İkon + renk ile eşleşme (predefined içinde)
      if (_selectedCategoryId == null) {
        final ic = habit['icon'];
        final col = habit['color'];
        final codePoint = ic is IconData
            ? ic.codePoint
            : (ic is int ? ic : null);
        final colorVal = col is Color ? col.value : (col is int ? col : null);
        if (codePoint != null && colorVal != null) {
          for (final c in _predefinedCategories) {
            if (c.icon.codePoint == codePoint && c.color.value == colorVal) {
              _selectedCategoryId = c.id;
              break;
            }
          }
        }
      }
    } catch (_) {}

    // Tip özel ayarları yükle
    if (_selectedHabitType == HabitType.numerical) {
      _numericalTarget = habit['targetCount'] ?? 1;
      _numericalUnit = habit['unit'] ?? '';
      _numericalTargetController.text = _numericalTarget.toString();
      _numericalUnitController.text = _numericalUnit;
      // Prefill target policy type if provided
      final nt = habit['numericalTargetType']?.toString().toLowerCase();
      if (nt != null) {
        if (nt.contains('exact')) {
          _numericalTargetType = NumericalTargetType.exact;
        } else if (nt.contains('maximum') || nt.contains('max')) {
          _numericalTargetType = NumericalTargetType.maximum;
        } else {
          _numericalTargetType = NumericalTargetType.minimum;
        }
      }
    } else if (_selectedHabitType == HabitType.timer) {
      _timerTargetMinutes = habit['targetCount'] ?? 1;
      _timerTargetController.text = _timerTargetMinutes.toString();
      // Prefill timer policy type if provided
      final tt = habit['timerTargetType']?.toString().toLowerCase();
      if (tt != null) {
        if (tt.contains('exact')) {
          _timerTargetType = TimerTargetType.exact;
        } else if (tt.contains('maximum') || tt.contains('max')) {
          _timerTargetType = TimerTargetType.maximum;
        } else {
          _timerTargetType = TimerTargetType.minimum;
        }
      }
    }

    // Scheduling: initialize from provided start/end dates
    try {
      final startStr = habit['startDate']?.toString();
      final endStr = habit['endDate']?.toString();
      if (startStr != null) {
        _startDate = DateTime.parse(startStr);
      }
      if (endStr != null) {
        _hasEndDate = true;
        _endDate = DateTime.parse(endStr);
      }

      if (widget.useVisionDayOffsets) {
        final today = DateTime.now();
        final today0 = DateTime(today.year, today.month, today.day);
        final base = widget.visionStartDate != null
            ? DateTime(
                widget.visionStartDate!.year,
                widget.visionStartDate!.month,
                widget.visionStartDate!.day,
              )
            : today0;
        _visionStartDay = _startDate.difference(base).inDays + 1;
        if (_visionStartDay < 1) _visionStartDay = 1;
        _visionEndDay = (_endDate ?? _startDate).difference(base).inDays + 1;
        if (_visionEndDay! < _visionStartDay) {
          _visionEndDay = _visionStartDay;
        }
        _visionStartDayCtrl.text = _visionStartDay.toString();
        _visionEndDayCtrl.text = (_visionEndDay ?? '').toString();

        // Initialize manual active days from editingHabit if provided
        final offs = habit['activeOffsets'];
        final sched = habit['scheduledDates'];
        _activeOffsets.clear();
        if (sched is List && sched.isNotEmpty) {
          for (final s in sched.whereType<String>()) {
            try {
              final d = DateTime.parse(s);
              final o = d.difference(today0).inDays + 1; // 1-based
              _activeOffsets.add(o);
            } catch (_) {}
          }
        } else if (offs is List) {
          _activeOffsets.addAll(offs.whereType<num>().map((e) => e.toInt()));
        }
        // Clamp to new range
        _activeOffsets.removeWhere(
          (d) => d < _visionStartDay || d > (_visionEndDay ?? _visionStartDay),
        );
      }
    } catch (_) {}

    // Frekans: varsa map'ten oku; yoksa düzenlemede günlük (daily) seçili başlasın
    try {
      final ft = habit['frequencyType']?.toString().toLowerCase();
      if (ft != null) {
        if (ft.contains('daily')) {
          _selectedFrequencyType = FrequencyType.daily;
        } else if (ft.contains('specificweekdays')) {
          _selectedFrequencyType = FrequencyType.specificWeekdays;
        } else if (ft.contains('specificmonthdays')) {
          _selectedFrequencyType = FrequencyType.specificMonthDays;
        } else if (ft.contains('specificyeardays')) {
          _selectedFrequencyType = FrequencyType.specificYearDays;
        } else if (ft.contains('periodic')) {
          _selectedFrequencyType = FrequencyType.periodic;
        }
      }
      // Seçimler
      final w = habit['selectedWeekdays'];
      if (w is List) {
        _selectedWeekdays = w.whereType<num>().map((e) => e.toInt()).toList();
      }
      final m = habit['selectedMonthDays'];
      if (m is List) {
        _selectedMonthDays = m.whereType<num>().map((e) => e.toInt()).toList();
      }
      final y = habit['selectedYearDays'];
      if (y is List) {
        _selectedYearDays = y
            .map((e) => DateTime.tryParse(e.toString()))
            .whereType<DateTime>()
            .toList();
      }
      final p = habit['periodicDays'];
      if (p is num) _periodicDays = p.toInt();
    } catch (_) {}
    // Eğer hiçbir şey gelmediyse varsayılan günlük
    _selectedFrequencyType ??= FrequencyType.daily;
  }

  void _initializeControllers() {
    _numericalTargetController.text = _numericalTarget.toString();
    _numericalUnitController.text = _numericalUnit;
    // Frequency controller removed
    _timerTargetController.text = _timerTargetMinutes.toString();
    // Timer frequency controller removed
  }

  @override
  void dispose() {
    // Remove repository listener
    CategoryRepository.instance.removeListener(_onCategoriesChanged);
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _numericalTargetController.dispose();
    _numericalUnitController.dispose();
    _timerTargetController.dispose();
    // Removed frequency controllers dispose
    _visionStartDayCtrl.dispose();
    _visionEndDayCtrl.dispose();
    super.dispose();
  }

  HabitCategory? _getSelectedCategory() {
    if (_selectedCategoryId == null) return null;
    final all = <HabitCategory>[..._predefinedCategories, ..._customCategories];
    try {
      return all.firstWhere((c) => c.id == _selectedCategoryId);
    } catch (_) {
      return null;
    }
  }

  String _localizedCategoryName(String id, AppLocalizations l10n) {
    switch (id) {
      case 'health':
        return l10n.health;
      case 'fitness':
        return l10n.fitness;
      case 'productivity':
        return l10n.productivity;
      case 'mindfulness':
        return l10n.mindfulness;
      case 'education':
        return l10n.education;
      case 'social':
        return l10n.social;
      default:
        // Fallback to id for unforeseen custom cases (custom categories already store localized name directly)
        return id;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      // Slightly longer duration and smoother easing for a more polished feel
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      // Match the forward duration for symmetry
      _pageController.previousPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool _canProceed() {
    final current = _steps[_currentStep];
    switch (current) {
      case _StepId.type:
        if (_selectedHabitType == null) return false;
        switch (_selectedHabitType!) {
          case HabitType.simple:
            return true;
          case HabitType.numerical:
            return _numericalTarget > 0 && _numericalUnit.trim().isNotEmpty;
          case HabitType.timer:
            return _timerTargetMinutes > 0;
        }
      case _StepId.details:
        return _nameController.text.trim().isNotEmpty;
      case _StepId.frequency:
        // When using manual active days for vision offsets, frequency is optional
        if (widget.useVisionDayOffsets) return true;
        if (_selectedFrequencyType == null) return false;
        switch (_selectedFrequencyType!) {
          case FrequencyType.daily:
            return true;
          case FrequencyType.specificWeekdays:
            return _selectedWeekdays.isNotEmpty;
          case FrequencyType.specificMonthDays:
            return _selectedMonthDays.isNotEmpty;
          case FrequencyType.specificYearDays:
            return _selectedYearDays.isNotEmpty;
          case FrequencyType.periodic:
            return _periodicDays > 0;
        }
      case _StepId.scheduling:
        if (widget.useVisionDayOffsets) {
          if (_visionStartDay < 1 || _visionStartDay > 365) return false;
          if (_visionEndDay == null) return false;
          if (_visionEndError != null) return false;
          // Require at least one active day to be selected
          if (_activeOffsets.isEmpty) return false;
          return true;
        }
        return true;
    }
  }

  void _finishHabitCreation() {
    final selectedCategory = _getSelectedCategory();
    final habit = {
      // Not a real category in data model anymore; used only to pick icon & color
      'categoryId': _selectedCategoryId,
      'type': _selectedHabitType.toString(),
      'name': _nameController.text,
      'description': _descriptionController.text,
      // Persist visual identity from the chosen "category" only if selected;
      // otherwise include manually selected color/emoji
      if (selectedCategory != null) ...{
        'icon': selectedCategory.icon.codePoint,
        'color': selectedCategory.color.value,
        // Use the actual category emoji when available (covers custom categories)
        'emoji': selectedCategory.emoji,
        // Also include a categoryName field so downstream code can show the
        // user-provided name for custom categories or a localized label for
        // predefined ones.
        'categoryName':
            _predefinedCategories.any((c) => c.id == selectedCategory.id)
            ? _localizedCategoryName(
                selectedCategory.id,
                AppLocalizations.of(context),
              )
            : selectedCategory.name,
      } else ...{
        'icon': Icons.star.codePoint,
        'color': _selectedColor.value,
        'emoji': _selectedEmoji,
      },

      // Habit type specific configuration
      if (_selectedHabitType == HabitType.numerical) ...{
        'numericalTarget': _numericalTarget,
        'numericalTargetType': _numericalTargetType.toString(),
        'numericalUnit': _numericalUnit,
        // Removed numericalDailyFrequency & numericalTimePeriod (simplified UI)
      },
      if (_selectedHabitType == HabitType.timer) ...{
        'timerTargetMinutes': _timerTargetMinutes,
        'timerTargetType': _timerTargetType.toString(),
        // Removed timerDailyFrequency & timerTimePeriod (simplified UI)
      },

      'frequencyType': _selectedFrequencyType.toString(),
      'selectedWeekdays': _selectedWeekdays,
      'selectedMonthDays': _selectedMonthDays,
      'selectedYearDays': _selectedYearDays
          .map((d) => d.toIso8601String())
          .toList(),
      'periodicDays': _periodicDays,
      // If using vision-day offsets, convert offsets to actual dates relative to today
      ...(() {
        if (widget.useVisionDayOffsets) {
          final today = DateTime.now();
          final today0 = DateTime(today.year, today.month, today.day);
          final base = widget.visionStartDate != null
              ? DateTime(
                  widget.visionStartDate!.year,
                  widget.visionStartDate!.month,
                  widget.visionStartDate!.day,
                )
              : today0;
          final s = base.add(Duration(days: _visionStartDay - 1));
          final e = _visionEndDay != null
              ? base.add(Duration(days: _visionEndDay! - 1))
              : null;
          return {
            'startDate': s.toIso8601String(),
            'endDate': e?.toIso8601String(),
          };
        } else {
          return {
            'startDate': _startDate.toIso8601String(),
            'endDate': _endDate?.toIso8601String(),
          };
        }
      })(),
      // Reminder/notification fields removed from returned map
      'createdAt': DateTime.now().toIso8601String(),
      'isAdvanced': true,
    };

    // If using vision-day offsets and manual active days are selected,
    // prefer explicit activeOffsets and ignore frequency fields
    if (widget.useVisionDayOffsets && _activeOffsets.isNotEmpty) {
      habit['activeOffsets'] = _activeOffsets.toList()..sort();
      habit.remove('frequencyType');
      habit.remove('selectedWeekdays');
      habit.remove('selectedMonthDays');
      habit.remove('selectedYearDays');
      habit.remove('periodicDays');
    }

    Navigator.of(context).pop(habit);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.editHabit : l10n.createAdvancedHabit,
        ),
        backgroundColor: colorScheme.surfaceVariant,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.stepOf(_currentStep + 1, _totalSteps),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        // Keep user swipes disabled but ensure programmatic animations feel smooth
        physics: const NeverScrollableScrollPhysics(),
        children: _steps.map<Widget>((s) {
          switch (s) {
            case _StepId.type:
              return _buildHabitTypeSelectionPage(l10n, theme, colorScheme);
            case _StepId.details:
              return _buildHabitDetailsPage(l10n, theme, colorScheme);
            case _StepId.frequency:
              return _buildFrequencySelectionPage(l10n, theme, colorScheme);
            case _StepId.scheduling:
              return _buildSchedulingPage(l10n, theme, colorScheme);
          }
        }).toList(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text(l10n.previous),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: _canProceed()
                    ? (_currentStep == _totalSteps - 1
                          ? _finishHabitCreation
                          : _nextStep)
                    : null,
                child: Text(
                  _currentStep == _totalSteps - 1 ? l10n.finish : l10n.next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionPage(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectCategory,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chooseBestCategory,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Predefined Categories
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _predefinedCategories.length,
            itemBuilder: (context, index) {
              final category = _predefinedCategories[index];
              final isSelected = _selectedCategoryId == category.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withOpacity(0.1)
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? category.color : colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (category.hasEmoji)
                          ? Text(
                              category.emoji!,
                              style: const TextStyle(fontSize: 32),
                            )
                          : Icon(
                              category.icon,
                              size: 32,
                              color: isSelected
                                  ? category.color
                                  : colorScheme.onSurfaceVariant,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        // For predefined categories use localized labels;
                        // for custom categories show the stored name (user typed).
                        _predefinedCategories.any((c) => c.id == category.id)
                            ? _localizedCategoryName(category.id, l10n)
                            : category.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? category.color
                              : colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Create New Category Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showCreateCategoryDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.createNewCategory),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Custom Categories
          if (_customCategories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              l10n.customCategories,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _customCategories.length,
              itemBuilder: (context, index) {
                final category = _customCategories[index];
                final isSelected = _selectedCategoryId == category.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                    });
                  },
                  onLongPress: () => _showCustomCategoryMenu(category),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.1)
                          : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? category.color
                            : colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (category.hasEmoji)
                            ? Text(
                                category.emoji!,
                                style: const TextStyle(fontSize: 32),
                              )
                            : Icon(
                                category.icon,
                                size: 32,
                                color: isSelected
                                    ? category.color
                                    : colorScheme.onSurfaceVariant,
                              ),
                        const SizedBox(height: 8),
                        Text(
                          _predefinedCategories.any((c) => c.id == category.id)
                              ? _localizedCategoryName(category.id, l10n)
                              : category.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? category.color
                                : colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitTypeSelectionPage(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectHabitType,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.howToTrackHabit,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          _buildHabitTypeCard(
            HabitType.simple,
            l10n.yesNoType,
            l10n.yesNoDescription,
            Icons.check_circle_outline,
            l10n.yesNoExample,
            l10n,
            theme,
            colorScheme,
          ),

          const SizedBox(height: 16),

          _buildHabitTypeCard(
            HabitType.numerical,
            l10n.numericalType,
            l10n.numericalDescription,
            Icons.numbers,
            l10n.numericExample,
            l10n,
            theme,
            colorScheme,
          ),

          const SizedBox(height: 16),

          _buildHabitTypeCard(
            HabitType.timer,
            l10n.timerType,
            l10n.timerDescription,
            Icons.timer_outlined,
            l10n.timerExample,
            l10n,
            theme,
            colorScheme,
          ),

          // Configuration for selected habit type
          if (_selectedHabitType != null) ...[
            const SizedBox(height: 24),
            _buildHabitTypeConfiguration(l10n, theme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitTypeCard(
    HabitType type,
    String title,
    String description,
    IconData icon,
    String example,
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedHabitType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHabitType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.onPrimary : colorScheme.surface,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.examplePrefix(example),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.8,
                            )
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitTypeConfiguration(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    switch (_selectedHabitType!) {
      case HabitType.numerical:
        return _buildNumericalConfiguration(l10n, theme, colorScheme);
      case HabitType.timer:
        return _buildTimerConfiguration(l10n, theme, colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNumericalConfiguration(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.numericSettings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),

          // Target value
          Text(
            l10n.targetValue,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.numberLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: _numericalTargetController,
                  onChanged: (value) {
                    setState(() {
                      _numericalTarget = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: l10n.unitHint,
                    border: const OutlineInputBorder(),
                  ),
                  controller: _numericalUnitController,
                  onChanged: (value) {
                    setState(() {
                      _numericalUnit = value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Target type
          Text(l10n.targetType, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              for (final t in [
                NumericalTargetType.minimum,
                NumericalTargetType.exact,
                NumericalTargetType.maximum,
              ])
                t == _numericalTargetType
                    ? FilledButton.icon(
                        style: _selectedCompactStyle(),
                        onPressed: () {},
                        icon: Icon(_iconForNumericalType(t), size: 20),
                        label: Text(_labelForNumericalType(context, l10n, t)),
                      )
                    : OutlinedButton.icon(
                        style: _unselectedCompactStyle(),
                        onPressed: () =>
                            setState(() => _numericalTargetType = t),
                        icon: Icon(_iconForNumericalType(t), size: 20),
                        label: Text(_labelForNumericalType(context, l10n, t)),
                      ),
            ],
          ),

          const SizedBox(height: 16),

          // Daily frequency & time period removed per simplified configuration
        ],
      ),
    );
  }

  Widget _buildTimerConfiguration(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.timerSettings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),

          // Target duration
          Text(
            l10n.targetDurationMinutes,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: l10n.minutes,
              border: const OutlineInputBorder(),
              suffixText: l10n.minutesSuffixShort,
            ),
            keyboardType: TextInputType.number,
            controller: _timerTargetController,
            onChanged: (value) {
              setState(() {
                _timerTargetMinutes = int.tryParse(value) ?? 30;
              });
            },
          ),

          const SizedBox(height: 16),

          // Timer target type
          Text(
            l10n.durationType,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              for (final t in [
                TimerTargetType.minimum,
                TimerTargetType.exact,
                TimerTargetType.maximum,
              ])
                t == _timerTargetType
                    ? FilledButton.icon(
                        style: _selectedCompactStyle(),
                        onPressed: () {},
                        icon: Icon(_iconForTimerType(t), size: 20),
                        label: Text(_labelForTimerType(context, l10n, t)),
                      )
                    : OutlinedButton.icon(
                        style: _unselectedCompactStyle(),
                        onPressed: () => setState(() => _timerTargetType = t),
                        icon: Icon(_iconForTimerType(t), size: 20),
                        label: Text(_labelForTimerType(context, l10n, t)),
                      ),
            ],
          ),

          const SizedBox(height: 16),

          // Daily frequency & completion period removed per simplified configuration
        ],
      ),
    );
  }

  IconData _iconForNumericalType(NumericalTargetType t) {
    switch (t) {
      case NumericalTargetType.minimum:
        return Icons.trending_up;
      case NumericalTargetType.exact:
        return Icons.my_location;
      case NumericalTargetType.maximum:
        return Icons.trending_down;
    }
  }

  String _labelForNumericalType(
    BuildContext context,
    AppLocalizations l10n,
    NumericalTargetType t,
  ) {
    switch (t) {
      case NumericalTargetType.minimum:
        return l10n.atLeast;
      case NumericalTargetType.exact:
        return l10n.exact;
      case NumericalTargetType.maximum:
        return l10n.atMost;
    }
  }

  IconData _iconForTimerType(TimerTargetType t) {
    switch (t) {
      case TimerTargetType.minimum:
        return Icons.timer;
      case TimerTargetType.exact:
        return Icons.schedule;
      case TimerTargetType.maximum:
        return Icons.timer_off;
    }
  }

  String _labelForTimerType(
    BuildContext context,
    AppLocalizations l10n,
    TimerTargetType t,
  ) {
    switch (t) {
      case TimerTargetType.minimum:
        return l10n.atLeast;
      case TimerTargetType.exact:
        return l10n.exact;
      case TimerTargetType.maximum:
        return l10n.atMost;
    }
  }

  // Compact button styles used for target-type buttons so they fit side-by-side
  ButtonStyle _selectedCompactStyle() {
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      minimumSize: const Size(64, 40),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }

  ButtonStyle _unselectedCompactStyle() {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      minimumSize: const Size(60, 40),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildHabitDetailsPage(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitDetails,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.enterNameAndDesc,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.habitName,
              hintText: l10n.nameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            onChanged: (value) => setState(() {}),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.habitDescription,
              hintText: l10n.descHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            maxLines: 4,
            minLines: 3,
          ),

          const SizedBox(height: 24),

          // Color and Emoji selection buttons
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (buttonCtx) => OutlinedButton.icon(
                    onPressed: () async {
                      final color = await _openColorPopup(buttonCtx);
                      if (color != null) setState(() => _selectedColor = color);
                    },
                    icon: Icon(Icons.color_lens, color: _selectedColor),
                    label: Text(l10n.chooseColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (buttonCtx) => OutlinedButton.icon(
                    onPressed: () async {
                      final emoji = await _openEmojiPopup(buttonCtx);
                      if (emoji != null && emoji.isNotEmpty)
                        setState(() => _selectedEmoji = emoji);
                    },
                    icon: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    label: Text(l10n.chooseEmoji),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Color?> _openColorPopup(BuildContext buttonCtx) async {
    // Show a centered AlertDialog page listing colors in a grid and return
    // the selected color.
    // Expanded, more curated palette including softer/pastel tones.
    final colors = [
      // Vibrant options
      Colors.red.shade600,
      Colors.deepOrange.shade600,
      Colors.orange.shade400,
      Colors.amber.shade600,
      Colors.yellow.shade600,
      Colors.lime.shade600,
      Colors.green.shade600,
      Colors.teal.shade600,
      Colors.cyan.shade400,
      Colors.lightBlue.shade400,
      Colors.blue.shade600,
      Colors.indigo.shade600,
      Colors.deepPurple.shade400,

      // Pastel / softer tones
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.amber.shade200,
      Colors.lime.shade200,
      Colors.lightGreen.shade200,
      Colors.teal.shade200,
      Colors.cyan.shade200,
      Colors.lightBlue.shade200,
      Colors.blue.shade200,
      Colors.indigo.shade200,
      Colors.deepPurple.shade200,
    ];

    return showDialog<Color?>(
      context: buttonCtx,
      builder: (dctx) {
        final l10n = AppLocalizations.of(dctx);
        return AlertDialog(
          title: Text(l10n.chooseColor),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: colors
                      .map(
                        (color) => GestureDetector(
                          onTap: () => Navigator.of(dctx).pop(color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              // minimal subtle shadow for depth
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _openEmojiPopup(BuildContext buttonCtx) async {
    // Show a centered AlertDialog with emoji presets and a small input for
    // custom emoji text.
    final l10n = AppLocalizations.of(buttonCtx);
    String custom = '';
    String selected = _selectedEmoji;
    return showDialog<String?>(
      context: buttonCtx,
      builder: (dctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(l10n.chooseEmoji),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: kEmojiPresets
                        .map(
                          (e) => GestureDetector(
                            onTap: () => setDialogState(() => selected = e),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected == e
                                      ? Theme.of(ctx).colorScheme.primary
                                      : Colors.transparent,
                                  width: selected == e ? 2 : 0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Minimal custom emoji input (small height)
                  SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        hintText: l10n.customEmojiOptional,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (v) => setDialogState(() => custom = v),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dctx).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(
                  dctx,
                ).pop((custom.trim().isNotEmpty) ? custom.trim() : selected),
                child: Text(l10n.select),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFrequencySelectionPage(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectFrequency,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.howOftenDoHabit,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          _buildFrequencyOption(
            FrequencyType.daily,
            l10n.everyday,
            l10n.repeatEveryDay,
            Icons.calendar_today,
            theme,
            colorScheme,
          ),

          const SizedBox(height: 12),

          _buildFrequencyOption(
            FrequencyType.specificWeekdays,
            l10n.specificDaysOfWeek,
            l10n.onSpecificWeekdays,
            Icons.view_week,
            theme,
            colorScheme,
          ),

          const SizedBox(height: 12),

          _buildFrequencyOption(
            FrequencyType.specificMonthDays,
            l10n.specificDaysOfMonth,
            l10n.onSpecificMonthDays,
            Icons.calendar_month,
            theme,
            colorScheme,
          ),

          const SizedBox(height: 12),

          _buildFrequencyOption(
            FrequencyType.specificYearDays,
            l10n.specificDaysOfYear,
            l10n.onSpecificYearDays,
            Icons.event,
            theme,
            colorScheme,
          ),

          const SizedBox(height: 12),

          _buildFrequencyOption(
            FrequencyType.periodic,
            l10n.periodicSelection,
            l10n.onPeriodic,
            Icons.schedule,
            theme,
            colorScheme,
          ),

          // Extra configuration for selected frequency type
          if (_selectedFrequencyType != null) ...[
            const SizedBox(height: 24),
            _buildFrequencyConfiguration(l10n, theme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(
    FrequencyType type,
    String title,
    String description,
    IconData icon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedFrequencyType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequencyType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyConfiguration(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    switch (_selectedFrequencyType!) {
      case FrequencyType.specificWeekdays:
        return _buildWeekdaySelector(l10n, theme, colorScheme);
      case FrequencyType.specificMonthDays:
        return _buildMonthDaySelector(l10n, theme, colorScheme);
      case FrequencyType.specificYearDays:
        return _buildYearDaySelector(l10n, theme, colorScheme);
      case FrequencyType.periodic:
        return _buildPeriodicConfiguration(l10n, theme, colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWeekdaySelector(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final weekdays = [
      l10n.weekdaysShortMon,
      l10n.weekdaysShortTue,
      l10n.weekdaysShortWed,
      l10n.weekdaysShortThu,
      l10n.weekdaysShortFri,
      l10n.weekdaysShortSat,
      l10n.weekdaysShortSun,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whichWeekdays,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final isSelected = _selectedWeekdays.contains(index + 1);
              return FilterChip(
                label: Text(weekdays[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedWeekdays.add(index + 1);
                    } else {
                      _selectedWeekdays.remove(index + 1);
                    }
                    _selectedWeekdays.sort();
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDaySelector(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whichMonthDays,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(31, (index) {
              final day = index + 1;
              final isSelected = _selectedMonthDays.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMonthDays.remove(day);
                    } else {
                      _selectedMonthDays.add(day);
                    }
                    _selectedMonthDays.sort();
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDaySelector(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.addSpecialDays,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedYearDays.isNotEmpty) ...[
            ...(_selectedYearDays.map(
              (date) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedYearDays.remove(date);
                        });
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
          FilledButton.icon(
            onPressed: () async {
              final DateTime firstAllowedForYear =
                  widget.visionStartDate != null
                  ? DateTime(
                      widget.visionStartDate!.year,
                      widget.visionStartDate!.month,
                      widget.visionStartDate!.day,
                    )
                  : DateTime.now();
              final DateTime initialForYear = widget.visionStartDate != null
                  ? DateTime(
                      widget.visionStartDate!.year,
                      widget.visionStartDate!.month,
                      widget.visionStartDate!.day,
                    )
                  : DateTime.now();
              final date = await showDatePicker(
                context: context,
                initialDate: initialForYear,
                firstDate: firstAllowedForYear,
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (date != null && !_selectedYearDays.contains(date)) {
                setState(() {
                  _selectedYearDays.add(date);
                  _selectedYearDays.sort();
                });
              }
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.addDate),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodicConfiguration(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.everyNDaysQuestion,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _periodicDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: l10n.nDaysLabel(_periodicDays),
                  onChanged: (value) {
                    setState(() {
                      _periodicDays = value.round();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.nDaysLabel(_periodicDays),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingPage(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.schedulingOptions,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scheduleHabit,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          if (widget.useVisionDayOffsets) ...[
            // Vision Start Day
            Text(
              l10n.visionStartDayQuestion,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _visionStartDayCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1 - 365',
                border: const OutlineInputBorder(),
                errorText: _visionStartError,
              ),
              inputFormatters: [
                // Only digits
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                final parsed = int.tryParse(value);
                setState(() {
                  _visionStartDay = parsed ?? 0;
                  // Validation for start day (no auto-correction)
                  if (_visionStartDay < 1 || _visionStartDay > 365) {
                    _visionStartError = l10n.visionStartDayInvalid;
                  } else {
                    _visionStartError = null;
                  }
                  // Update end-day error state (do not auto-overwrite end value)
                  if (_visionEndDay != null &&
                      _visionEndDay! < _visionStartDay) {
                    _visionEndError = l10n.visionEndDayLess;
                  } else if (_visionEndDay != null &&
                      (_visionEndDay! < 1 || _visionEndDay! > 365)) {
                    _visionEndError = l10n.visionEndDayInvalid;
                  } else {
                    _visionEndError = null;
                  }
                  // Prune active offsets below new start
                  _activeOffsets.removeWhere((d) => d < _visionStartDay);
                });
              },
            ),
            const SizedBox(height: 24),

            // Vision End Day (required)
            Text(
              l10n.visionEndDayQuestion,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _visionEndDayCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1 - 365',
                border: const OutlineInputBorder(),
                errorText: _visionEndError,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final v = int.tryParse(value);
                setState(() {
                  // Allow clearing while typing; don't auto-fill
                  _visionEndDay = v;
                  // Validate and set error (do not modify user's text)
                  if (v == null) {
                    _visionEndError = l10n.visionEndDayRequired;
                  } else if (v < 1 || v > 365) {
                    _visionEndError = l10n.visionEndDayInvalid;
                  } else if (v < _visionStartDay) {
                    _visionEndError = l10n.visionEndDayLess;
                  } else {
                    _visionEndError = null;
                    // Prune active offsets above new valid end
                    _activeOffsets.removeWhere((d) => d > v);
                  }
                });
              },
            ),

            const SizedBox(height: 24),
            Text(
              l10n.whichDaysActive,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: (_visionEndDay != null && _visionEndError == null)
                      ? () {
                          final end = _visionEndDay!;
                          setState(() {
                            _activeOffsets
                              ..clear()
                              ..addAll(
                                List<int>.generate(
                                  (end - _visionStartDay + 1),
                                  (i) => _visionStartDay + i,
                                ),
                              );
                          });
                        }
                      : null,
                  child: Text(l10n.selectAll),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    setState(() => _activeOffsets.clear());
                  },
                  child: Text(l10n.clear),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.surfaceVariant.withOpacity(0.2),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (_visionEndDay != null && _visionEndError == null)
                    for (int d = _visionStartDay; d <= _visionEndDay!; d++)
                      FilterChip(
                        selected: _activeOffsets.contains(d),
                        label: Text(d.toString()),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _activeOffsets.add(d);
                            } else {
                              _activeOffsets.remove(d);
                            }
                          });
                        },
                      )
                  else
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        l10n.visionEndDayRequired,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            // Calendar-based scheduling (default)
            Text(
              l10n.startDate,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectStartDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.endDate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _hasEndDate,
                  onChanged: (value) {
                    setState(() {
                      _hasEndDate = value;
                      if (!value) _endDate = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_hasEndDate)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.surfaceVariant.withOpacity(0.1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.noEndDate,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : l10n.selectEndDate,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.onSurfaceVariant,
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

  void _showCreateCategoryDialog() async {
    final l10n = AppLocalizations.of(context);
    final categoryNameController = TextEditingController();
    String selectedEmoji = '🌟';
    Color selectedColor = Colors.blue;

    final result = await showDialog<HabitCategory>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.createNewCategory),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseEmoji,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kEmojiPresets
                      .map(
                        (e) => GestureDetector(
                          onTap: () => setDialogState(() => selectedEmoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedEmoji == e
                                    ? selectedColor
                                    : Colors.grey,
                                width: selectedEmoji == e ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.customEmojiOptional,
                    hintText: l10n.customEmojiHint,
                  ),
                  onChanged: (v) => setDialogState(() {
                    if (v.trim().isNotEmpty) selectedEmoji = v.trim();
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseColor,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            Colors.red,
                            Colors.deepOrange,
                            Colors.orange,
                            Colors.amber,
                            Colors.yellow,
                            Colors.lime,
                            Colors.lightGreen,
                            Colors.green,
                            Colors.teal,
                            Colors.cyan,
                            Colors.lightBlue,
                            Colors.blue,
                            Colors.indigo,
                            Colors.deepPurple,
                            Colors.purple,
                            Colors.pink,
                            Colors.brown,
                            Colors.blueGrey,
                            Colors.grey,
                          ]
                          .map(
                            (color) => GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedColor = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (categoryNameController.text.trim().isNotEmpty) {
                  final newCategory = HabitCategory(
                    DateTime.now().millisecondsSinceEpoch.toString(),
                    categoryNameController.text.trim(),
                    Icons.star,
                    selectedColor,
                    emoji: selectedEmoji,
                  );
                  Navigator.of(context).pop(newCategory);
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      // Persist and update selection
      await CategoryRepository.instance.initialize();
      await CategoryRepository.instance.addCustom(result);
      setState(() {
        _selectedCategoryId = result.id;
      });
    }
  }

  Future<void> _showEditCategoryDialog(HabitCategory category) async {
    final l10n = AppLocalizations.of(context);
    final categoryNameController = TextEditingController(text: category.name);
    String selectedEmoji = category.emoji ?? '🌟';
    Color selectedColor = category.color;

    final result = await showDialog<HabitCategory>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.editCategory),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseEmoji,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kEmojiPresets
                      .map(
                        (e) => GestureDetector(
                          onTap: () => setDialogState(() => selectedEmoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedEmoji == e
                                    ? selectedColor
                                    : Colors.grey,
                                width: selectedEmoji == e ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: selectedEmoji),
                  decoration: InputDecoration(
                    labelText: l10n.customEmojiOptional,
                    hintText: l10n.customEmojiHint,
                  ),
                  onChanged: (v) => setDialogState(() {
                    if (v.trim().isNotEmpty) selectedEmoji = v.trim();
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.chooseColor,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            Colors.red,
                            Colors.deepOrange,
                            Colors.orange,
                            Colors.amber,
                            Colors.yellow,
                            Colors.lime,
                            Colors.lightGreen,
                            Colors.green,
                            Colors.teal,
                            Colors.cyan,
                            Colors.lightBlue,
                            Colors.blue,
                            Colors.indigo,
                            Colors.deepPurple,
                            Colors.purple,
                            Colors.pink,
                            Colors.brown,
                            Colors.blueGrey,
                            Colors.grey,
                          ]
                          .map(
                            (color) => GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedColor = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (categoryNameController.text.trim().isNotEmpty) {
                  final updated = HabitCategory(
                    category.id,
                    categoryNameController.text.trim(),
                    category.icon, // keep legacy icon value
                    selectedColor,
                    emoji: selectedEmoji,
                  );
                  Navigator.of(context).pop(updated);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await CategoryRepository.instance.updateCustom(result);
      setState(() {
        if (_selectedCategoryId == result.id) {
          // keep selected; no change needed beyond UI update
        }
      });
    }
  }

  void _showCustomCategoryMenu(HabitCategory category) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.edit),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditCategoryDialog(category);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[600]),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: Colors.red[600]),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed =
                      await showDialog<bool>(
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: Text(l10n.deleteCategoryTitle),
                          content: Text(l10n.deleteCustomCategoryConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dctx, false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red[600],
                              ),
                              onPressed: () => Navigator.pop(dctx, true),
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (confirmed) {
                    await CategoryRepository.instance.removeCustom(category.id);
                    setState(() {
                      if (_selectedCategoryId == category.id) {
                        _selectedCategoryId = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime defaultFirst = DateTime(DateTime.now().year - 5, 1, 1);
    final DateTime firstAllowed = widget.visionStartDate != null
        ? DateTime(
            widget.visionStartDate!.year,
            widget.visionStartDate!.month,
            widget.visionStartDate!.day,
          )
        : defaultFirst;
    // Ensure initialDate is within [firstAllowed, lastDate]
    final DateTime lastAllowed = DateTime(DateTime.now().year + 2, 12, 31);
    DateTime initial = _startDate;
    if (initial.isBefore(firstAllowed)) initial = firstAllowed;
    if (initial.isAfter(lastAllowed)) initial = lastAllowed;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // Allow selecting only from the vision start (if set) or the default range
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    // Ensure end-date selection cannot be before the vision start when provided
    final DateTime minFirst = widget.visionStartDate != null
        ? DateTime(
            widget.visionStartDate!.year,
            widget.visionStartDate!.month,
            widget.visionStartDate!.day,
          )
        : _startDate;
    final DateTime firstAllowed = _startDate.isAfter(minFirst)
        ? _startDate
        : minFirst;
    final DateTime lastAllowed = DateTime.now().add(
      const Duration(days: 365 * 2),
    );

    DateTime initial = _endDate ?? _startDate.add(const Duration(days: 30));
    if (initial.isBefore(firstAllowed)) initial = firstAllowed;
    if (initial.isAfter(lastAllowed)) initial = lastAllowed;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }
}
