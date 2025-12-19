import 'package:flutter/material.dart';
import 'package:mira/l10n/app_localizations.dart';
import '../../habit/domain/habit_model.dart';
import '../../habit/domain/habit_repository.dart';
import '../../habit/domain/habit_types.dart';
import '../../../core/utils/emoji_presets.dart';

class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  Habit? _habit;

  // Editable fields
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  int _target = 1;
  Color _color = Colors.teal;
  String? _emoji;
  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    final repo = HabitRepository.instance;
    final h = repo.findById(widget.habitId);
    _habit = h;
    if (h != null) {
      print('[EditHabitScreen] Loading habit: ${h.emoji} ${h.title}');
      print('[EditHabitScreen] reminderEnabled: ${h.reminderEnabled}');
      print('[EditHabitScreen] reminderTime: ${h.reminderTime}');
      _titleCtrl.text = h.title;
      _descCtrl.text = h.description;
      _unitCtrl.text = h.unit ?? '';
      _target = h.targetCount;
      _color = h.color;
      _emoji = h.emoji;
      _reminderEnabled = h.reminderEnabled;
      _reminderTime = h.reminderTime;
      print(
        '[EditHabitScreen] State after loading: _reminderEnabled=$_reminderEnabled, _reminderTime=$_reminderTime',
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _habit;
    if (h == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).habit)),
        body: Center(child: Text(AppLocalizations.of(context).habitNotFound)),
      );
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).editHabit),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).habitName,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppLocalizations.of(context).nameRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).habitDescription,
                  hintText: AppLocalizations.of(context).descHint,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text(switch (h.habitType) {
                      HabitType.simple => AppLocalizations.of(
                        context,
                      ).simpleTypeShort,
                      HabitType.numerical => AppLocalizations.of(
                        context,
                      ).numericalType,
                      HabitType.timer => AppLocalizations.of(context).timerType,
                      HabitType.checkbox => AppLocalizations.of(
                        context,
                      ).simpleTypeShort,
                      HabitType.subtasks => AppLocalizations.of(
                        context,
                      ).advancedHabit,
                    }),
                    avatar: const Icon(Icons.category),
                  ),
                  Text(AppLocalizations.of(context).typeNotChangeable),
                ],
              ),
              const SizedBox(height: 16),
              if (h.habitType == HabitType.numerical ||
                  h.habitType == HabitType.timer) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _target.toString(),
                        decoration: InputDecoration(
                          labelText: h.habitType == HabitType.timer
                              ? AppLocalizations.of(
                                  context,
                                ).targetDurationMinutes
                              : AppLocalizations.of(context).targetValueLabel,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null && n > 0) _target = n;
                        },
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) {
                            return AppLocalizations.of(context).invalidValue;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unitCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).unit,
                          hintText: h.habitType == HabitType.timer
                              ? AppLocalizations.of(context).unitHint
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Basit alışkanlık için hedef sabit 1'dir.
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).simpleHabitTargetOne),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Text(
                AppLocalizations.of(context).chooseColor,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetColors
                    .map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == c
                                  ? colorScheme.onSurface
                                  : Colors.transparent,
                              width: _color == c ? 3 : 1,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).chooseEmoji,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kEmojiPresets
                    .map(
                      (e) => ChoiceChip(
                        label: Text(e, style: const TextStyle(fontSize: 18)),
                        selected: _emoji == e,
                        onSelected: (_) => setState(() => _emoji = e),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).customEmojiOptional,
                  hintText: AppLocalizations.of(context).customEmojiHint,
                ),
                onChanged: (v) {
                  final t = v.trim();
                  if (t.isNotEmpty) setState(() => _emoji = t);
                },
              ),
              const SizedBox(height: 24),
              // Reminder section
              Card(
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
                            AppLocalizations.of(context).reminder,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          AppLocalizations.of(context).enableReminder,
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
                                : AppLocalizations.of(context).selectTime,
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(AppLocalizations.of(context).save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    print(
      '[EditHabitScreen] Opening time picker, current _reminderTime: $_reminderTime',
    );
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    print('[EditHabitScreen] Time picker result: $time');
    if (time != null) {
      setState(() {
        _reminderTime = time;
        print('[EditHabitScreen] Updated _reminderTime to: $_reminderTime');
      });
    } else {
      print('[EditHabitScreen] Time picker was cancelled');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final h = _habit!;
    print('[EditHabitScreen] Saving habit: ${h.title}');
    print('[EditHabitScreen] _reminderEnabled: $_reminderEnabled');
    print('[EditHabitScreen] _reminderTime: $_reminderTime');
    final target = (h.habitType == HabitType.simple) ? 1 : _target;
    final updated = Habit(
      id: h.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      icon: h.icon, // icon unchanged
      emoji: _emoji,
      color: _color,
      targetCount: target,
      habitType: h.habitType, // immutable here
      unit: (h.habitType == HabitType.timer)
          ? (_unitCtrl.text.trim().isEmpty ? 'dk' : _unitCtrl.text.trim())
          : (_unitCtrl.text.trim().isEmpty ? h.unit : _unitCtrl.text.trim()),
      currentStreak: h.currentStreak,
      isCompleted: h.isCompleted,
      progressDate: h.progressDate,
      startDate: h.startDate,
      endDate: h.endDate,
      dailyLog: Map.of(h.dailyLog),
      leftoverSeconds: h.leftoverSeconds,
      listId: h.listId,
      scheduledDates: h.scheduledDates == null
          ? null
          : List<String>.from(h.scheduledDates!),
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderTime,
    )..isAdvanced = h.isAdvanced;

    await HabitRepository.instance.updateHabit(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).habitUpdatedMessage)),
    );
    Navigator.pop(context, true);
  }

  List<Color> get _presetColors => const [
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
}
