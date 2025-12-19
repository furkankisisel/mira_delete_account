import 'package:flutter/material.dart';
import '../../../design_system/theme/theme_variations.dart';
import '../data/vision_template.dart';
import '../../../l10n/app_localizations.dart';

/// Habit Template Wizard
/// Steps: 1) Type (with inline target for numerical/timer)
///        2) Details
///        3) Schedule (and explicit active day offsets if endDay is set)
class HabitTemplateWizardScreen extends StatefulWidget {
  const HabitTemplateWizardScreen({super.key, this.initial, this.variant});
  final VisionHabitTemplate? initial;
  // If World theme is active globally, we force Earth here for better contrast
  final ThemeVariant? variant;

  @override
  State<HabitTemplateWizardScreen> createState() =>
      _HabitTemplateWizardScreenState();
}

class _HabitTemplateWizardScreenState extends State<HabitTemplateWizardScreen> {
  final PageController _page = PageController();
  int _step = 0;

  // Step 1: Type
  String _type = 'simple'; // 'simple' | 'numerical' | 'timer'
  int? _target; // for numerical/timer
  String? _unit; // for numerical

  // Step 2: Details
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _emoji;
  String _iconName = 'check_circle';
  Color _color = Colors.blue;

  // Step 3: Schedule
  int _startDay = 1; // 1..365
  int? _endDay; // 1..365, optional
  String? _startDayError;
  String? _endDayError;

  // Explicit active day indexes within [startDay..endDay].
  // If empty, defaults to daily frequency.
  final Set<int> _activeOffsets = <int>{};

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _titleCtrl.text = i.title;
      _descCtrl.text = i.description ?? '';
      _type = i.type;
      _target = i.target;
      _unit = i.unit;
      _emoji = i.emoji;
      _iconName = i.iconName;
      _color = Color(i.colorValue);
      _startDay = i.startDay;
      _endDay = i.endDay;
      // Frequency UI removed. If there are explicit activeOffsets, we respect them.
      _activeOffsets
        ..clear()
        ..addAll(i.activeOffsets ?? const []);
    }
  }

  @override
  void dispose() {
    _page.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  bool _canNext() {
    switch (_step) {
      case 0:
        if (!(_type == 'simple' || _type == 'numerical' || _type == 'timer')) {
          return false;
        }
        if (_type == 'simple') return true;
        return (_target ?? 0) > 0;
      case 1:
        return _titleCtrl.text.trim().isNotEmpty;
      case 2:
        return _startDay >= 1 &&
            _startDay <= 365 &&
            (_endDay == null || (_endDay! >= 1 && _endDay! <= 365)) &&
            (_endDay == null || _endDay! >= _startDay) &&
            _startDayError == null &&
            _endDayError == null;
      default:
        return true;
    }
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _page.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _page.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    final tpl = VisionHabitTemplate(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      type: _type,
      target: _type == 'simple' ? null : (_target ?? 1),
      unit: _type == 'numerical'
          ? (_unit?.trim().isEmpty == true ? null : _unit?.trim())
          : null,
      emoji: _emoji?.trim().isEmpty == true ? null : _emoji?.trim(),
      iconName: _iconName,
      colorValue: _color.toARGB32(),
      startDay: _startDay.clamp(1, 365),
      endDay: _endDay,
      // Frequency controls removed: default to daily if no explicit active offsets.
      frequencyType: _activeOffsets.isNotEmpty ? null : 'daily',
      selectedWeekdays: null,
      selectedMonthDays: null,
      selectedYearDays: null,
      periodicDays: null,
      activeOffsets: _activeOffsets.isEmpty
          ? null
          : List.unmodifiable(_activeOffsets.toList()..sort()),
    );
    Navigator.of(context).pop(tpl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ThemeData? forcedTheme = widget.variant == ThemeVariant.world
        ? (isDark
              ? ThemeVariations.dark(ThemeVariant.earth)
              : ThemeVariations.light(ThemeVariant.earth))
        : null;
    final body = Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).createHabitTemplateTitle),
      ),
      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTypeStep(theme),
          _buildDetailsStep(theme),
          _buildScheduleStep(theme),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _back,
                  child: Text(AppLocalizations.of(context).previous),
                ),
              ),
            if (_step > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _canNext() ? (_step == 2 ? _finish : _next) : null,
                child: Text(
                  _step == 2
                      ? AppLocalizations.of(context).save
                      : AppLocalizations.of(context).next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (forcedTheme != null) return Theme(data: forcedTheme, child: body);
    return body;
  }

  Widget _buildTypeStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
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
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildHabitTypeCard(
              'simple',
              l10n.yesNoType,
              l10n.yesNoDescription,
              Icons.check_circle_outline,
              l10n.yesNoExample,
              theme,
              cs,
            ),
            const SizedBox(height: 12),
            _buildHabitTypeCard(
              'numerical',
              l10n.numericalType,
              l10n.numericalDescription,
              Icons.numbers,
              l10n.numericExample,
              theme,
              cs,
            ),
            const SizedBox(height: 12),
            _buildHabitTypeCard(
              'timer',
              l10n.timerType,
              l10n.timerDescription,
              Icons.timer_outlined,
              l10n.timerExample,
              theme,
              cs,
            ),
            const SizedBox(height: 24),
            if (_type != 'simple') ...[
              Text(l10n.targetValueLabel, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _type == 'timer'
                      ? l10n.targetDurationMinutes
                      : l10n.targetValueLabel,
                ),
                onChanged: (v) => setState(() => _target = int.tryParse(v)),
              ),
              if (_type == 'numerical') ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(hintText: l10n.unitHint),
                  onChanged: (v) => setState(
                    () => _unit = v.trim().isEmpty ? null : v.trim(),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHabitTypeCard(
    String type,
    String title,
    String description,
    IconData icon,
    String example,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? cs.onPrimary : cs.surface,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).examplePrefix(example),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          (isSelected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurfaceVariant)
                              .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(labelText: l10n.taskTitle),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            decoration: InputDecoration(labelText: l10n.taskDescription),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text(l10n.emojiLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _EmojiPicker(
            selected: _emoji,
            onSelected: (e) => setState(() => _emoji = e),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _emoji ?? '',
            decoration: InputDecoration(hintText: l10n.customEmojiHint),
            onChanged: (v) => setState(() => _emoji = v.trim()),
          ),
          const SizedBox(height: 16),
          Text(l10n.colorLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final c in [
                Colors.blue,
                Colors.orange,
                Colors.green,
                Colors.purple,
                Colors.red,
                Colors.teal,
              ])
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(
                    backgroundColor: c,
                    child: _color == c
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scheduleLabel, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _startDay.toString(),
                  decoration: InputDecoration(labelText: l10n.startDayLabel),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {
                    final parsed = int.tryParse(v);
                    _startDay = parsed ?? 0;
                    if (_startDay < 1 || _startDay > 365) {
                      _startDayError = l10n.visionStartDayInvalid;
                    } else {
                      _startDayError = null;
                    }
                    if (_endDay != null && _endDay! < _startDay) {
                      _endDayError = l10n.visionEndDayLess;
                    } else if (_endDay != null &&
                        (_endDay! < 1 || _endDay! > 365)) {
                      _endDayError = l10n.visionEndDayInvalid;
                    } else {
                      _endDayError = null;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _endDay?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: l10n.endDayOptionalLabel,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {
                    final parsed = int.tryParse(v);
                    _endDay = parsed;
                    if (parsed == null) {
                      _endDayError = null; // empty is allowed
                    } else if (parsed < 1 || parsed > 365) {
                      _endDayError = l10n.visionEndDayInvalid;
                    } else if (parsed < _startDay) {
                      _endDayError = l10n.visionEndDayLess;
                    } else {
                      _endDayError = null;
                    }
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_startDayError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _startDayError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_endDayError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _endDayError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Text(l10n.visionDurationNote),
          const SizedBox(height: 16),
          if (_endDay != null) ...[
            Text(l10n.activeDays, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int d = _startDay; d <= (_endDay ?? _startDay); d++)
                  FilterChip(
                    label: Text('$d'),
                    selected: _activeOffsets.contains(d),
                    onSelected: (v) => setState(() {
                      if (v) {
                        _activeOffsets.add(d);
                      } else {
                        _activeOffsets.remove(d);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() {
                    _activeOffsets.clear();
                    for (int d = _startDay; d <= (_endDay ?? _startDay); d++) {
                      _activeOffsets.add(d);
                    }
                  }),
                  child: Text(l10n.selectAll),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _activeOffsets.clear()),
                  child: Text(l10n.clear),
                ),
              ],
            ),
          ] else ...[
            Text(l10n.noEndDayDefaultsDaily, style: theme.textTheme.bodyMedium),
          ],
        ],
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
