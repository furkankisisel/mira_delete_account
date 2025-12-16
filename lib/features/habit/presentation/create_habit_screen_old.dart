import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/emoji_presets.dart';
import '../domain/habit_model.dart';
import '../domain/habit_types.dart';
import 'widgets/habit_card_preview.dart';

/// Simple habit creation screen with multi-step flow.
/// Steps: 1) Emoji & Color, 2) Name & Description, 3) Frequency, 4) Reminder
class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({
    super.key,
    this.isEditing = false,
    this.existingHabit,
  });

  final bool isEditing;
  final Habit? existingHabit;

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1: Emoji & Color
  String _selectedEmoji = '✅';
  Color _selectedColor = Colors.blue;

  // Step 2: Name & Description
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Step 3: Frequency
  String _selectedFrequency = 'daily';
  final Set<int> _weeklyDays = <int>{};
  final Set<int> _monthDays = <int>{};
  final List<String> _yearDays = <String>[];
  int _periodicDays = 1;

  // Step 4: Reminder
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  // Color palette - sade versiyonunda daha az renk
  final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
  ];

  final List<String> _emojiPresets = kEmojiPresets;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadExistingHabitIfEditing();
  }

  void _loadExistingHabitIfEditing() {
    final h = widget.existingHabit;
    if (widget.isEditing && h != null) {
      _nameController.text = h.title;
      _descriptionController.text = h.description;
      _selectedColor = h.color;
      _selectedEmoji = (h.emoji == null || h.emoji!.trim().isEmpty)
          ? _selectedEmoji
          : h.emoji!.trim();

      // Load frequency
      final ft = h.frequencyType?.toLowerCase();
      if (ft != null) {
        if (ft.contains('daily'))
          _selectedFrequency = 'daily';
        else if (ft.contains('specificweekdays'))
          _selectedFrequency = 'weekly';
        else if (ft.contains('specificmonthdays'))
          _selectedFrequency = 'monthly';
        else if (ft.contains('specificyeardays'))
          _selectedFrequency = 'yearly';
        else if (ft.contains('periodic'))
          _selectedFrequency = 'periodic';
      }

      if (h.selectedWeekdays != null) {
        _weeklyDays.addAll(h.selectedWeekdays!.where((e) => e >= 1 && e <= 7));
      }
      if (h.selectedMonthDays != null) {
        _monthDays.addAll(h.selectedMonthDays!.where((e) => e >= 1 && e <= 31));
      }
      if (h.selectedYearDays != null) {
        _yearDays.addAll(h.selectedYearDays!);
      }
      if (h.periodicDays != null && h.periodicDays! > 0) {
        _periodicDays = h.periodicDays!;
      }

      _reminderEnabled = h.reminderEnabled;
      _reminderTime = h.reminderTime;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    // Validate current step
    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      return; // Stay on name/description step if validation fails
    }

    if (_currentStep == 2) {
      // Validate frequency
      if (_selectedFrequency == 'weekly' && _weeklyDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir gün seçin')),
        );
        return;
      }
      if (_selectedFrequency == 'monthly' && _monthDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir gün seçin')),
        );
        return;
      }
      if (_selectedFrequency == 'yearly' && _yearDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir tarih seçin')),
        );
        return;
      }
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishCreation() {
    final today = DateTime.now();
    final startDateStr = _dateKey(today);
    final scheduled = _generateScheduledDates(start: today);

    String? frequencyType;
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
    }

    final habit = Habit(
      id: widget.existingHabit?.id ?? '',
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: widget.existingHabit?.icon ?? Icons.check_circle_outline,
      emoji: _selectedEmoji,
      color: _selectedColor,
      targetCount: widget.existingHabit?.targetCount ?? 1,
      habitType: widget.existingHabit?.habitType ?? HabitType.simple,
      unit: widget.existingHabit?.unit ?? '',
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
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderTime,
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
    final Set<int> week = _weeklyDays.isEmpty
        ? {DateTime.now().weekday}
        : _weeklyDays;
    final Set<int> month = _monthDays;
    final Set<String> yearSet = _yearDays.toSet();

    if (_selectedFrequency == 'daily') {
      for (int i = 0; i < horizonDays; i++) {
        final d = startOnly.add(Duration(days: i));
        dates.add(_dateKey(d));
      }
      return dates;
    }

    if (_selectedFrequency == 'weekly') {
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        if (week.contains(d.weekday)) dates.add(_dateKey(d));
        d = d.add(const Duration(days: 1));
      }
      return dates;
    }

    if (_selectedFrequency == 'monthly') {
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        if (month.contains(d.day)) dates.add(_dateKey(d));
        d = d.add(const Duration(days: 1));
      }
      return dates;
    }

    if (_selectedFrequency == 'yearly') {
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        final md =
            '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        if (yearSet.contains(md)) dates.add(_dateKey(d));
        d = d.add(const Duration(days: 1));
      }
      return dates;
    }

    if (_selectedFrequency == 'periodic') {
      if (_periodicDays <= 0) _periodicDays = 1;
      DateTime d = startOnly;
      while (!d.isAfter(end)) {
        dates.add(_dateKey(d));
        d = d.add(Duration(days: _periodicDays));
      }
      return dates;
    }
    return dates;
  }

  Future<void> _openColorDialog() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Renk Seç', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedColor = c);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == c
                              ? Colors.black
                              : Colors.transparent,
                          width: _selectedColor == c ? 3 : 0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openEmojiDialog() async {
    String custom = '';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emoji Seç', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: _emojiPresets.map((e) {
                      final sel = _selectedEmoji == e;
                      return ChoiceChip(
                        selected: sel,
                        onSelected: (_) {
                          setState(() => _selectedEmoji = e);
                          Navigator.pop(ctx);
                        },
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selectedColor: _selectedColor.withOpacity(0.18),
                        backgroundColor: Theme.of(
                          ctx,
                        ).colorScheme.surfaceVariant.withOpacity(0.4),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: sel
                                ? _selectedColor
                                : Theme.of(ctx).colorScheme.outlineVariant,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        label: Text(e, style: TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'İsteğe Bağlı Özel Emoji',
                    hintText: 'Emoji girin',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => custom = v,
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      setState(() => _selectedEmoji = v.trim());
                      Navigator.pop(ctx);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      if (custom.trim().isNotEmpty) {
                        setState(() => _selectedEmoji = custom.trim());
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editHabit : l10n.createHabitTitle),
        backgroundColor: colorScheme.surfaceVariant,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adım ${_currentStep + 1}/$_totalSteps',
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index),
        children: [
          _buildEmojiColorStep(),
          _buildNameDescriptionStep(),
          _buildFrequencyStep(),
          _buildReminderStep(),
        ],
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
                  onPressed: _goToPreviousStep,
                  child: const Text('Geri'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _currentStep == _totalSteps - 1
                    ? _finishCreation
                    : _goToNextStep,
                child: Text(
                  _currentStep == _totalSteps - 1 ? 'Tamamla' : 'İleri',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiColorStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emoji ve Renk Seç',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alışkanlığını temsil edecek emoji ve rengi seç',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Preview
          HabitCardPreview(
            emoji: _selectedEmoji,
            color: _selectedColor,
            title: 'Alışkanlık Adı',
            description: 'Açıklama',
          ),
          const SizedBox(height: 32),
          // Emoji Picker
          Text(
            'Emoji',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _openEmojiDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                children: [
                  Text(_selectedEmoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emoji Seç', style: theme.textTheme.titleSmall),
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
          // Color Picker
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
            children: _colors.map((c) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == c
                          ? Colors.black
                          : Colors.transparent,
                      width: _selectedColor == c ? 3 : 0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameDescriptionStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alışkanlığı İsimlendir',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alışkanlığın adı ve açıklamasını gir',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            // Preview
            HabitCardPreview(
              emoji: _selectedEmoji,
              color: _selectedColor,
              title: _nameController.text,
              description: _descriptionController.text,
            ),
            const SizedBox(height: 32),
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Alışkanlık Adı *',
                hintText: 'örn. Sabah Yürüyüşü',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Ad gerekli' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Açıklama (İsteğe Bağlı)',
                hintText: 'Detayları ekle...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sıklığı Seç',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alışkanlığını ne sıklıkla yapacağını seç',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Frequency Options
          _buildFrequencyOptions(l10n, theme, colorScheme),
          const SizedBox(height: 24),
          // Detailed Frequency UI
          _buildDetailedFrequencyUI(l10n, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildFrequencyOptions(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FrequencyButton(
          label: 'Günlük',
          icon: Icons.calendar_today,
          isSelected: _selectedFrequency == 'daily',
          onTap: () => setState(() => _selectedFrequency = 'daily'),
        ),
        _FrequencyButton(
          label: 'Haftalık',
          icon: Icons.date_range,
          isSelected: _selectedFrequency == 'weekly',
          onTap: () => setState(() => _selectedFrequency = 'weekly'),
        ),
        _FrequencyButton(
          label: 'Aylık',
          icon: Icons.calendar_view_month,
          isSelected: _selectedFrequency == 'monthly',
          onTap: () => setState(() => _selectedFrequency = 'monthly'),
        ),
        _FrequencyButton(
          label: 'Yıllık',
          icon: Icons.event,
          isSelected: _selectedFrequency == 'yearly',
          onTap: () => setState(() => _selectedFrequency = 'yearly'),
        ),
      ],
    );
  }

  Widget _buildDetailedFrequencyUI(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    switch (_selectedFrequency) {
      case 'daily':
        return const SizedBox.shrink();

      case 'weekly':
        return _WeeklyDayPicker(
          selected: _weeklyDays,
          onChanged: (s) => setState(() {
            _weeklyDays.clear();
            _weeklyDays.addAll(s);
          }),
        );

      case 'monthly':
        return _MonthDayPicker(
          selected: _monthDays,
          onChanged: (s) => setState(() {
            _monthDays.clear();
            _monthDays.addAll(s);
          }),
        );

      case 'yearly':
        return _YearDayPicker(
          selected: _yearDays,
          onAdd: (md) => setState(() {
            if (!_yearDays.contains(md)) _yearDays.add(md);
          }),
          onRemove: (md) => setState(() => _yearDays.remove(md)),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReminderStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hatırlatıcı Ayarla',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hatırlatıcı almak istersen zamanı seç',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 0,
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hatırlatıcı',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hatırlatıcıyı Etkinleştir'),
                    value: _reminderEnabled,
                    onChanged: (v) => setState(() => _reminderEnabled = v),
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        _reminderTime != null
                            ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                            : 'Zaman Seç',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectReminderTime,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tamamlamaya Hazır!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Alışkanlığını oluşturmak için aşağıdaki Tamamla butonuna tıkla',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrequencyButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyDayPicker extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  const _WeeklyDayPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(7, (i) {
        final day = i + 1;
        final isSel = selected.contains(day);
        return FilterChip(
          label: Text(labels[i]),
          selected: isSel,
          onSelected: (v) {
            final s = {...selected};
            if (v)
              s.add(day);
            else
              s.remove(day);
            onChanged(s);
          },
        );
      }),
    );
  }
}

class _MonthDayPicker extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  const _MonthDayPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(31, (i) {
        final day = i + 1;
        final isSel = selected.contains(day);
        return ChoiceChip(
          label: Text('$day'),
          selected: isSel,
          onSelected: (v) {
            final s = {...selected};
            if (v)
              s.add(day);
            else
              s.remove(day);
            onChanged(s);
          },
        );
      }),
    );
  }
}

class _YearDayPicker extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _YearDayPicker({
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, 1, 1),
      lastDate: DateTime(now.year, 12, 31),
    );
    if (d != null) {
      final md =
          '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      onAdd(md);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selected
              .map(
                (md) =>
                    InputChip(label: Text(md), onDeleted: () => onRemove(md)),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickDate(context),
          icon: const Icon(Icons.event_available),
          label: const Text('Tarih Ekle'),
        ),
      ],
    );
  }
}
