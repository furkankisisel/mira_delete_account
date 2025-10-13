import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/emoji_presets.dart';
import '../domain/habit_model.dart';
import '../domain/habit_types.dart';
import 'advanced_habit_wizard_screen.dart';

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

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedFrequency = 'daily';
  // Detailed frequency selections
  final Set<int> _weeklyDays = <int>{}; // 1=Mon..7=Sun
  final Set<int> _monthDays = <int>{}; // 1..31
  final List<String> _yearDays = <String>[]; // 'MM-DD'
  int _periodicDays = 1;
  Color _selectedColor = Colors.blue;
  String _selectedEmoji = '✅';
  // Notifications removed

  // Reminder settings
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  final List<Color> _colors = [
    // Expanded Material palette
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
  ];

  final List<String> _emojiPresets = kEmojiPresets;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openColorDialog() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(ctx).chooseColor,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colors.map((c) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedColor = c;
                      Navigator.of(ctx).pop();
                    }),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
        final scheme = Theme.of(ctx).colorScheme;
        final maxH = MediaQuery.of(ctx).size.height * 0.75;
        return SizedBox(
          height: maxH,
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
                Text(
                  AppLocalizations.of(ctx).chooseEmoji,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                // Center the emoji chips so rows are balanced; reduce spacing
                // slightly so one more column can fit on narrower widths.
                Center(
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: _emojiPresets.map((e) {
                      final sel = _selectedEmoji == e;
                      return ChoiceChip(
                        selected: sel,
                        onSelected: (_) => setState(() {
                          _selectedEmoji = e;
                          Navigator.of(ctx).pop();
                        }),
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        selectedColor: _selectedColor.withOpacity(0.18),
                        backgroundColor: scheme.surfaceVariant.withOpacity(0.4),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: sel ? _selectedColor : scheme.outlineVariant,
                            width: sel ? 1.5 : 1,
                          ),
                        ),
                        // Slightly smaller emoji text to help fitting an extra
                        // column while keeping visual balance.
                        label: Text(
                          e,
                          style: TextStyle(
                            fontSize: 15,
                            color: sel
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx).customEmojiOptional,
                    hintText: AppLocalizations.of(ctx).customEmojiHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => custom = v,
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      setState(() => _selectedEmoji = v.trim());
                      Navigator.of(ctx).pop();
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
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: Text(AppLocalizations.of(ctx).apply),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Prefill when editing a simple habit
    final h = widget.existingHabit;
    if (widget.isEditing && h != null) {
      _titleController.text = h.title;
      _descriptionController.text = h.description;
      _selectedColor = h.color;
      _selectedEmoji = (h.emoji == null || h.emoji!.trim().isEmpty)
          ? _selectedEmoji
          : h.emoji!.trim();
      // Frequency: prefer detailed fields if present, fallback to simple string
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
      } else {
        final f = h.frequency?.toLowerCase();
        if (f == 'weekly')
          _selectedFrequency = 'weekly';
        else if (f == 'monthly')
          _selectedFrequency = 'monthly';
        else if (f == 'yearly')
          _selectedFrequency = 'yearly';
        else if (f == 'periodic')
          _selectedFrequency = 'periodic';
        else
          _selectedFrequency = 'daily';
      }
      // Preselect lists if available
      if (h.selectedWeekdays != null) {
        _weeklyDays
          ..clear()
          ..addAll(h.selectedWeekdays!.where((e) => e >= 1 && e <= 7));
      }
      if (h.selectedMonthDays != null) {
        _monthDays
          ..clear()
          ..addAll(h.selectedMonthDays!.where((e) => e >= 1 && e <= 31));
      }
      if (h.selectedYearDays != null) {
        _yearDays
          ..clear()
          ..addAll(h.selectedYearDays!);
      }
      if (h.periodicDays != null && h.periodicDays! > 0) {
        _periodicDays = h.periodicDays!;
      }
      // Load reminder settings
      _reminderEnabled = h.reminderEnabled;
      _reminderTime = h.reminderTime;
      print(
        '[CreateHabitScreen] Loaded reminder settings: enabled=$_reminderEnabled, time=$_reminderTime',
      );
    }
  }

  String _frequencySummary() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedFrequency) {
      case 'weekly':
        if (_weeklyDays.isEmpty) return l10n.weekly;
        String shortLabelFor(int d) {
          switch (d) {
            case 1:
              return l10n.weekdaysShortMon;
            case 2:
              return l10n.weekdaysShortTue;
            case 3:
              return l10n.weekdaysShortWed;
            case 4:
              return l10n.weekdaysShortThu;
            case 5:
              return l10n.weekdaysShortFri;
            case 6:
              return l10n.weekdaysShortSat;
            case 7:
              return l10n.weekdaysShortSun;
            default:
              return d.toString();
          }
        }
        final days = _weeklyDays.toList()..sort();
        return '${l10n.weekly}: ' + days.map(shortLabelFor).join(', ');
      case 'monthly':
        if (_monthDays.isEmpty) return l10n.monthly;
        final days = _monthDays.toList()..sort();
        return '${l10n.monthly}: ' + days.join(', ');
      case 'yearly':
        if (_yearDays.isEmpty) return l10n.yearly;
        final list = [..._yearDays]..sort();
        return '${l10n.yearly}: ' + list.join(', ');
      case 'periodic':
        // Example: "Periodic: 5 days"
        return '${l10n.periodic}: ' + l10n.nDaysLabel(_periodicDays);
      default:
        return l10n.daily;
    }
  }

  Future<void> _openFrequencyDialog() async {
    // Local temp copies for cancel support
    String sel = _selectedFrequency;
    final Set<int> week = {..._weeklyDays};
    final Set<int> mon = {..._monthDays};
    final List<String> year = [..._yearDays];
    int per = _periodicDays;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            Widget body() {
              switch (sel) {
                case 'weekly':
                  return _WeeklyPicker(
                    selected: week,
                    onChanged: (s) => setSheet(() {
                      week
                        ..clear()
                        ..addAll(s);
                    }),
                  );
                case 'monthly':
                  return _MonthDayPicker(
                    selected: mon,
                    onChanged: (s) => setSheet(() {
                      mon
                        ..clear()
                        ..addAll(s);
                    }),
                  );
                case 'yearly':
                  return _YearDayPicker(
                    selected: year,
                    onAdd: (md) => setSheet(() {
                      if (!year.contains(md)) year.add(md);
                    }),
                    onRemove: (md) => setSheet(() {
                      year.remove(md);
                    }),
                  );
                case 'periodic':
                  return Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).repeatEveryNDays + ': ',
                      ),
                      SizedBox(
                        width: 72,
                        child: TextFormField(
                          initialValue: per.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) {
                            final n = int.tryParse(v.trim());
                            setSheet(() => per = (n == null || n <= 0) ? 1 : n);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context).periodic),
                    ],
                  );
                default:
                  return const SizedBox.shrink();
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).schedulingOptions,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _FrequencyOptionGrid(
                    selectedKey: sel,
                    onSelect: (k) => setSheet(() => sel = k),
                  ),
                  const SizedBox(height: 16),
                  body(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(AppLocalizations.of(context).cancel),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          // Validation
                          if (sel == 'weekly' && week.isEmpty) return;
                          if (sel == 'monthly' && mon.isEmpty) return;
                          if (sel == 'yearly' && year.isEmpty) return;
                          if (sel == 'periodic' && per <= 0) return;

                          setState(() {
                            _selectedFrequency = sel;
                            _weeklyDays
                              ..clear()
                              ..addAll(week);
                            _monthDays
                              ..clear()
                              ..addAll(mon);
                            _yearDays
                              ..clear()
                              ..addAll(year);
                            _periodicDays = per;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context).apply),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Future<void> _selectReminderTime() async {
    print(
      '[CreateHabitScreen] Opening time picker, current _reminderTime: $_reminderTime',
    );
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    print('[CreateHabitScreen] Time picker result: $time');
    if (time != null) {
      setState(() {
        _reminderTime = time;
        print('[CreateHabitScreen] Updated _reminderTime to: $_reminderTime');
      });
    } else {
      print('[CreateHabitScreen] Time picker was cancelled');
    }
  }

  void _createHabit() {
    print('[CreateHabitScreen] _createHabit called');
    print('[CreateHabitScreen] _reminderEnabled: $_reminderEnabled');
    print('[CreateHabitScreen] _reminderTime: $_reminderTime');
    if (_formKey.currentState!.validate()) {
      final today = DateTime.now();
      final startDateStr = _dateKey(today);

      // Build schedule and details depending on selection
      final scheduled = _generateScheduledDates(start: today);

      // Map simple selection to detailed config keys for future edits
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

      final result = <String, dynamic>{
        'title': _titleController.text,
        'description': _descriptionController.text,
        'frequency': _selectedFrequency,
        'color': _selectedColor.value,
        'emoji': _selectedEmoji,
        'startDate': startDateStr,
        'scheduledDates': scheduled,
        'frequencyType': frequencyType,
        'reminderEnabled': _reminderEnabled,
        if (_reminderTime != null)
          'reminderTime': {
            'hour': _reminderTime!.hour,
            'minute': _reminderTime!.minute,
          },
        if (selectedWeekdays != null) 'selectedWeekdays': selectedWeekdays,
        if (selectedMonthDays != null) 'selectedMonthDays': selectedMonthDays,
        if (selectedYearDays != null) 'selectedYearDays': selectedYearDays,
        if (periodicDays != null) 'periodicDays': periodicDays,
      };
      // Only include createdAt when creating
      if (!widget.isEditing) {
        result['createdAt'] = DateTime.now();
      }
      Navigator.of(context).pop(result);
    }
  }

  void _navigateToAdvancedHabit() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => const AdvancedHabitWizardScreen(),
      ),
    );

    if (result != null) {
      // Gelişmiş habit sonucunu geri döndür
      Navigator.of(context).pop(result);
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.habitName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameHint;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.descHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.frequency,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _FrequencySummaryTile(
                summary: _frequencySummary(),
                onTap: _openFrequencyDialog,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.appearance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ColorButtonCard(
                      color: _selectedColor,
                      onTap: _openColorDialog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EmojiButtonCard(
                      emoji: _selectedEmoji,
                      onTap: _openEmojiDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Reminder section
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
                            l10n.reminder ?? 'Hatırlatıcı',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          l10n.enableReminder ?? 'Hatırlatıcıyı Etkinleştir',
                        ),
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
                                : (l10n.selectTime ?? 'Zaman Seç'),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _selectReminderTime,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _createHabit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? l10n.save : l10n.create,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _navigateToAdvancedHabit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                  icon: Icon(Icons.tune, color: colorScheme.primary),
                  label: Text(
                    l10n.advancedHabit,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Weekly picker (Mon..Sun)
class _WeeklyPicker extends StatelessWidget {
  const _WeeklyPicker({required this.selected, required this.onChanged});
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.weekdaysShortMon,
      l10n.weekdaysShortTue,
      l10n.weekdaysShortWed,
      l10n.weekdaysShortThu,
      l10n.weekdaysShortFri,
      l10n.weekdaysShortSat,
      l10n.weekdaysShortSun,
    ];
    return Wrap(
      spacing: 8,
      children: List.generate(7, (i) {
        final day = i + 1; // 1..7
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

// Month day picker (1..31)
class _MonthDayPicker extends StatelessWidget {
  const _MonthDayPicker({required this.selected, required this.onChanged});
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

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

// Year day picker using month-day strings (MM-DD)
class _YearDayPicker extends StatelessWidget {
  const _YearDayPicker({
    required this.selected,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> selected;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

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
          label: Text(AppLocalizations.of(context).addDate),
        ),
      ],
    );
  }
}

class _FrequencySummaryTile extends StatelessWidget {
  const _FrequencySummaryTile({required this.summary, required this.onTap});
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(AppLocalizations.of(context).frequency),
      subtitle: Text(summary),
      trailing: const Icon(Icons.chevron_right),
      tileColor: scheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// Removed unused private tiles reported by analyzer.

class _ColorButtonCard extends StatelessWidget {
  const _ColorButtonCard({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline, width: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context).chooseColor,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const Icon(Icons.color_lens_outlined),
          ],
        ),
      ),
    );
  }
}

class _EmojiButtonCard extends StatelessWidget {
  const _EmojiButtonCard({required this.emoji, required this.onTap});
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context).chooseEmoji,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const Icon(Icons.emoji_emotions_outlined),
          ],
        ),
      ),
    );
  }
}

class _FrequencyOptionGrid extends StatelessWidget {
  const _FrequencyOptionGrid({
    required this.selectedKey,
    required this.onSelect,
  });
  final String selectedKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('daily', Icons.calendar_today, AppLocalizations.of(context).daily),
      ('weekly', Icons.date_range, AppLocalizations.of(context).weekly),
      (
        'monthly',
        Icons.calendar_view_month,
        AppLocalizations.of(context).monthly,
      ),
      ('yearly', Icons.event, AppLocalizations.of(context).yearly),
      ('periodic', Icons.repeat, AppLocalizations.of(context).periodic),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (key, icon, label) in items)
          ChoiceChip(
            selected: key == selectedKey,
            onSelected: (_) => onSelect(key),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            selectedColor: scheme.primaryContainer,
            backgroundColor: scheme.surfaceVariant.withOpacity(0.4),
            shape: StadiumBorder(
              side: BorderSide(
                color: (key == selectedKey)
                    ? scheme.primary
                    : scheme.outlineVariant,
                width: (key == selectedKey) ? 1.5 : 1,
              ),
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: (key == selectedKey)
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: (key == selectedKey)
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
