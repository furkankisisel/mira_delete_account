import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/vision_template.dart';
import '../data/vision_template_repository.dart';
import '../data/vision_repository.dart';
import '../../habit/presentation/advanced_habit_screen.dart';
import '../../habit/domain/habit_types.dart';

class VisionTemplateBuilderScreen extends StatefulWidget {
  const VisionTemplateBuilderScreen({super.key});

  @override
  State<VisionTemplateBuilderScreen> createState() =>
      _VisionTemplateBuilderScreenState();
}

class _VisionTemplateBuilderScreenState
    extends State<VisionTemplateBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _emoji = '🎯';
  Color _color = Colors.teal;
  final List<VisionHabitTemplate> _habits = [];
  // Süre artık otomatik hesaplanıyor: en büyük endDay/activeOffsets'e göre
  int? get _autoDurationDays {
    if (_habits.isEmpty) return null;
    int maxDay = -1;
    for (final h in _habits) {
      if (h.activeOffsets != null && h.activeOffsets!.isNotEmpty) {
        for (final d in h.activeOffsets!) {
          if (d > maxDay) maxDay = d;
        }
      } else if (h.endDay != null) {
        if (h.endDay! > maxDay) maxDay = h.endDay!;
      }
    }
    return maxDay >= 0 ? maxDay : null;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addHabit() async {
    final map = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => const AdvancedHabitScreen(
          useVisionDayOffsets: true,
          returnAsMap: true,
        ),
      ),
    );
    if (map != null) {
      final tpl = _visionHabitFromAdvancedMap(map);
      setState(() => _habits.add(tpl));
    }
  }

  void _editHabit(int index) async {
    final initialMap = _advancedMapFromVisionHabit(_habits[index]);
    final map = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AdvancedHabitScreen(
          editingHabitMap: initialMap,
          useVisionDayOffsets: true,
          returnAsMap: true,
        ),
      ),
    );
    if (map != null) {
      final tpl = _visionHabitFromAdvancedMap(map);
      setState(() => _habits[index] = tpl);
    }
  }

  VisionHabitTemplate _visionHabitFromAdvancedMap(Map<String, dynamic> m) {
    String type = 'simple';
    final selType = m['habitType'] ?? m['type'];
    if (selType is HabitType) {
      switch (selType) {
        case HabitType.numerical:
          type = 'numerical';
          break;
        case HabitType.timer:
          type = 'timer';
          break;
        case HabitType.checkbox:
          type = 'checkbox';
          break;
        case HabitType.subtasks:
          type = 'subtasks';
          break;
        case HabitType.simple:
          type = 'simple';
          break;
      }
    } else if (selType is String) {
      final s = selType.toLowerCase();
      if (s.contains('numerical'))
        type = 'numerical';
      else if (s.contains('timer'))
        type = 'timer';
      else if (s.contains('checkbox'))
        type = 'checkbox';
      else if (s.contains('subtasks'))
        type = 'subtasks';
      else
        type = 'simple';
    }

    int? target;
    String? unit;
    String? numericalPolicy;
    String? timerPolicy;
    if (type == 'numerical') {
      target =
          (m['numericalTarget'] as num?)?.toInt() ??
          (m['targetCount'] as num?)?.toInt();
      unit = (m['numericalUnit'] as String?) ?? m['unit'] as String?;
      final p = m['numericalTargetType']?.toString();
      if (p != null) numericalPolicy = p;
    } else if (type == 'timer') {
      target =
          (m['timerTargetMinutes'] as num?)?.toInt() ??
          (m['targetCount'] as num?)?.toInt();
      unit = 'dakika';
      final p = m['timerTargetType']?.toString();
      if (p != null) timerPolicy = p;
    }

    String? freqType;
    final f = m['frequencyType'];
    if (f != null) {
      final s = f.toString();
      if (s.contains('daily'))
        freqType = 'daily';
      else if (s.contains('specificWeekdays'))
        freqType = 'specificWeekdays';
      else if (s.contains('specificMonthDays'))
        freqType = 'specificMonthDays';
      else if (s.contains('specificYearDays'))
        freqType = 'specificYearDays';
      else if (s.contains('periodic'))
        freqType = 'periodic';
    }
    final week = (m['selectedWeekdays'] as List?)
        ?.whereType<num>()
        .map((e) => e.toInt())
        .toList();
    final month = (m['selectedMonthDays'] as List?)
        ?.whereType<num>()
        .map((e) => e.toInt())
        .toList();
    final year = (m['selectedYearDays'] as List?)
        ?.map((e) => e.toString())
        .toList();
    final periodic = (m['periodicDays'] as num?)?.toInt();

    int startDay = 1;
    int? endDay;
    try {
      final startStr = m['startDate']?.toString();
      final endStr = m['endDate']?.toString();
      final today = DateTime.now();
      final today0 = DateTime(today.year, today.month, today.day);
      if (startStr != null) {
        final start = DateTime.parse(startStr);
        startDay = start.difference(today0).inDays + 1;
        if (startDay < 1) startDay = 1;
      }
      if (endStr != null) {
        final end = DateTime.parse(endStr);
        endDay = end.difference(today0).inDays + 1;
        if (endDay < startDay) endDay = startDay;
      }
    } catch (_) {}

    // Active offsets (manual selected days within [startDay..endDay])
    List<int>? activeOffsets =
        (m['activeOffsets'] as List?)
            ?.whereType<num>()
            .map((e) => e.toInt())
            .where((d) => d >= startDay && (endDay == null || d <= endDay))
            .toSet() // ensure unique
            .toList()
          ?..sort();

    final colorValue = (m['color'] as int?) ?? 0xFF2196F3;
    final emoji = (m['emoji'] as String?);

    return VisionHabitTemplate(
      title: (m['name'] as String?)?.trim().isNotEmpty == true
          ? m['name']
          : AppLocalizations.of(context).habit,
      description: (m['description'] as String?)?.trim().isNotEmpty == true
          ? m['description']
          : null,
      type: type,
      target: target,
      unit: unit,
      numericalTargetType: numericalPolicy,
      timerTargetType: timerPolicy,
      emoji: emoji,
      iconName: 'check_circle',
      colorValue: colorValue,
      startDay: startDay,
      endDay: endDay,
      frequencyType: freqType,
      selectedWeekdays: week,
      selectedMonthDays: month,
      selectedYearDays: year,
      periodicDays: periodic,
      activeOffsets: (activeOffsets == null || activeOffsets.isEmpty)
          ? null
          : activeOffsets,
    );
  }

  Map<String, dynamic> _advancedMapFromVisionHabit(VisionHabitTemplate h) {
    HabitType habitType = HabitType.simple;
    if (h.type == 'numerical') habitType = HabitType.numerical;
    if (h.type == 'timer') habitType = HabitType.timer;

    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);
    final startDate = today0.add(Duration(days: h.startDay - 1));
    final endDate = h.endDay != null
        ? today0.add(Duration(days: h.endDay! - 1))
        : null;

    return {
      'habitType': habitType,
      'name': h.title,
      'description': h.description,
      if (habitType == HabitType.numerical) ...{
        'numericalTarget': h.target ?? 1,
        'numericalUnit': h.unit ?? '',
        if (h.numericalTargetType != null)
          'numericalTargetType': h.numericalTargetType,
      },
      if (habitType == HabitType.timer) ...{
        'timerTargetMinutes': h.target ?? 1,
        if (h.timerTargetType != null) 'timerTargetType': h.timerTargetType,
      },
      'frequencyType': h.frequencyType ?? 'daily',
      'selectedWeekdays': h.selectedWeekdays ?? const <int>[],
      'selectedMonthDays': h.selectedMonthDays ?? const <int>[],
      'selectedYearDays': h.selectedYearDays ?? const <String>[],
      'periodicDays': h.periodicDays ?? 1,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      if (h.activeOffsets != null)
        'activeOffsets': List<int>.from(h.activeOffsets!),
      'emoji': h.emoji,
      'color': h.colorValue,
    };
  }

  Future<void> _shareLink() async {
    final t = VisionTemplate(
      id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim().isEmpty
          ? AppLocalizations.of(context).vision
          : _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      emoji: _emoji ?? '🎯',
      colorValue: _color.toARGB32(),
      habits: List.unmodifiable(_habits),
      autoSeed: false,
      endDate: null,
    );
    final link = VisionTemplateRepository.instance.toShareLink(t);
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).shareLinkCopied)),
    );
  }

  Future<void> _importFromLink() async {
    final ctrl = TextEditingController();
    final link = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).importFromLink),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'mira://vision?tpl=...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(AppLocalizations.of(context).importFromLink),
          ),
        ],
      ),
    );
    if (link == null || link.isEmpty) return;
    final t = VisionTemplateRepository.instance.fromShareLink(link);
    if (t == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).invalidLink)),
      );
      return;
    }
    setState(() {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _emoji = t.emoji ?? '🎯';
      _color = Color(t.colorValue);
      _habits
        ..clear()
        ..addAll(t.habits);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createVisionTemplateTitle),
        actions: [
          IconButton(onPressed: _importFromLink, icon: const Icon(Icons.link)),
          IconButton(onPressed: _shareLink, icon: const Icon(Icons.ios_share)),
        ],
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).taskTitle,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppLocalizations.of(context).taskTitleRequired
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).taskDescription,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).colorLabel,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _ColorPicker(
              selected: _color,
              onSelected: (c) => setState(() => _color = c),
            ),
            const Divider(height: 32),
            Text(
              AppLocalizations.of(context).visual,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Templates use emoji-only to keep content portable
            _EmojiPicker(
              selected: _emoji,
              onSelected: (e) => setState(() => _emoji = e),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).emojiLabel,
                hintText: AppLocalizations.of(context).customEmojiHint,
              ),
              onChanged: (v) {
                final t = v.trim();
                if (t.isNotEmpty) setState(() => _emoji = t);
              },
            ),
            const Divider(height: 32),
            Text(
              AppLocalizations.of(context).habitsSection,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_habits.isEmpty)
              Text(AppLocalizations.of(context).noHabitsAddedYet),
            ..._habits.asMap().entries.map((e) {
              final i = e.key;
              final h = e.value;
              final icon = VisionRepository.iconFromName(h.iconName);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(h.colorValue),
                    child: (h.emoji != null && h.emoji!.isNotEmpty)
                        ? Text(h.emoji!, style: const TextStyle(fontSize: 18))
                        : Icon(icon, color: Colors.white),
                  ),
                  title: Text(h.title),
                  subtitle: Text(
                    h.endDay != null
                        ? '${h.type.toUpperCase()} • '
                              '${AppLocalizations.of(context).dayRangeShort(h.endDay!, h.startDay)}'
                        : '${h.type.toUpperCase()} • '
                              '${AppLocalizations.of(context).dayShort(h.startDay)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editHabit(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setState(() => _habits.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addHabit,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).addHabit),
            ),
            const Divider(height: 32),
            Text(
              AppLocalizations.of(context).durationAutoLabel,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final d = _autoDurationDays;
                final text = d != null
                    ? AppLocalizations.of(context).visionAutoDurationInfo(d)
                    : AppLocalizations.of(context).visionNoEndDurationInfo;
                return Row(
                  children: [
                    Expanded(child: Text(text)),
                    const SizedBox(width: 8),
                    const Icon(Icons.auto_mode),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final d = _autoDurationDays; // null olabilir (açık uçlu)
                final tpl = VisionTemplate(
                  id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
                  title: _titleCtrl.text.trim().isEmpty
                      ? AppLocalizations.of(context).vision
                      : _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim().isEmpty
                      ? null
                      : _descCtrl.text.trim(),
                  emoji: _emoji ?? '🎯',
                  colorValue: _color.toARGB32(),
                  habits: List.unmodifiable(_habits),
                  autoSeed: false,
                  endDate: null,
                );
                final repo = VisionRepository.instance;
                final v = await repo.createFromTemplate(tpl, durationDays: d);
                if (!mounted) return;
                if (v != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).visionStartedMessage(v.title),
                      ),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).visionStartFailed,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(AppLocalizations.of(context).start),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  const _EmojiPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const emojis = [
      '🎯',
      '🌟',
      '🔥',
      '💪',
      '💧',
      '🍏',
      '📚',
      '🧘',
      '🚶',
      '🧠',
      '💤',
      '📝',
      '🧹',
      '📵',
      '🪙',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emojis
          .map(
            (e) => ChoiceChip(
              label: Text(e, style: const TextStyle(fontSize: 18)),
              selected: selected == e,
              onSelected: (_) => onSelected(e),
            ),
          )
          .toList(),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelected;
  const _ColorPicker({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = [
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
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors
          .map(
            (c) => GestureDetector(
              onTap: () => onSelected(c),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == c ? Colors.black : Colors.transparent,
                    width: selected == c ? 3 : 1,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
