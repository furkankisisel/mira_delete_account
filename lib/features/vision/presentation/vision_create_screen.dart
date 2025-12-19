import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mira/features/habit/domain/habit_model.dart';
import 'package:mira/features/habit/domain/habit_repository.dart';
import 'package:mira/features/habit/domain/habit_types.dart';
import 'package:mira/features/habit/presentation/advanced_habit_screen.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import 'package:image_picker/image_picker.dart';
import '../data/vision_model.dart';
import '../data/vision_repository.dart';
import '../data/vision_template_repository.dart';
import '../data/vision_template.dart';
import '../../../design_system/theme/theme_variations.dart';
import '../../gamification/gamification_repository.dart';
import '../../../core/utils/emoji_presets.dart';
// import 'habit_template_wizard_screen.dart'; // Replaced by AdvancedHabitWizard
// Removed linking existing habits to a vision; only creating new ones inside vision is supported.

class VisionCreateScreen extends StatefulWidget {
  const VisionCreateScreen({
    super.key,
    required this.variant,
    this.initialVision,
  });

  final Vision? initialVision; // if provided, acts as Edit screen
  final ThemeVariant variant;

  @override
  State<VisionCreateScreen> createState() => _VisionCreateScreenState();
}

class _VisionCreateScreenState extends State<VisionCreateScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<_ManualTabState> _manualKey = GlobalKey<_ManualTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ensure repos
    VisionRepository.instance.initialize();
    HabitRepository.instance.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialVision != null;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final ThemeData localTheme = widget.variant == ThemeVariant.world
        ? (isDark
              ? ThemeVariations.dark(ThemeVariant.earth)
              : ThemeVariations.light(ThemeVariant.earth))
        : theme;
    final accent = localTheme.colorScheme.primary;
    return Theme(
      data: localTheme.copyWith(
        colorScheme: localTheme.colorScheme.copyWith(
          primary: accent,
          secondary: accent,
          tertiary: accent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit
                ? AppLocalizations.of(context).visionEditTitle
                : AppLocalizations.of(context).visionCreateTitle,
          ),
          bottom: isEdit
              ? null
              : TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: AppLocalizations.of(context).templatesTabReady),
                    Tab(text: AppLocalizations.of(context).templatesTabManual),
                  ],
                ),
        ),
        body: isEdit
            ? _ManualTab(
                key: _manualKey,
                initial: widget.initialVision,
                variant: widget.variant,
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _TemplatesTab(
                    isEdit: false,
                    onApplyToManual: (t) async {
                      // Load full template by id and apply everything (header + habits)
                      final lang = Localizations.localeOf(context).languageCode;
                      final all = await VisionTemplateRepository.instance
                          .loadBundled(lang: lang);
                      final tpl = all.firstWhere(
                        (e) => e.id == t.id,
                        orElse: () => VisionTemplate(
                          id: t.id,
                          title: t.title,
                          description: t.description,
                          emoji: t.emoji,
                          colorValue: t.color.toARGB32(),
                          autoSeed: false,
                          habits: const [],
                          endDate: null,
                        ),
                      );
                      _manualKey.currentState?.applyFullTemplate(tpl);
                      _tabController.animateTo(1);
                    },
                  ),
                  _ManualTab(
                    key: _manualKey,
                    initial: widget.initialVision,
                    variant: widget.variant,
                  ),
                ],
              ),
      ),
    );
  }
}

class _TemplatesTab extends StatefulWidget {
  const _TemplatesTab({this.isEdit = false, this.onApplyToManual});

  final bool isEdit;
  final void Function(_TemplateItem item)? onApplyToManual;

  @override
  State<_TemplatesTab> createState() => _TemplatesTabState();
}

class _TemplatesTabState extends State<_TemplatesTab> {
  late Future<List<_TemplateItem>> _future;
  Locale? _lastLocale;

  @override
  void initState() {
    super.initState();
    _future = _loadTemplates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = Localizations.localeOf(context);
    if (_lastLocale != current) {
      _lastLocale = current;
      _reload();
    }
  }

  Future<List<_TemplateItem>> _loadTemplates() async {
    try {
      final raw = await _tryLoadTemplatesRaw();
      if (raw == null) {
        throw Exception('assets/seeds/vision_templates.json bulunamadı');
      }
      return raw
          .map(
            (e) => _TemplateItem(
              id: e['id']?.toString() ?? 'vision',
              title:
                  e['title']?.toString() ?? AppLocalizations.of(context).vision,
              emoji: e['emoji']?.toString() ?? '🎯',
              description: e['description']?.toString() ?? '',
              color: Color(
                (e['colorValue'] as num?)?.toInt() ?? Colors.teal.toARGB32(),
              ),
            ),
          )
          .toList();
    } catch (e) {
      // Propagate error to FutureBuilder for UI
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> _tryLoadTemplatesRaw() async {
    final lang = Localizations.localeOf(context).languageCode;
    final paths = <String>[
      if (lang.isNotEmpty) 'assets/seeds/vision_templates.$lang.json',
      'assets/seeds/vision_templates.json',
      'assets/vision_templates.json',
    ];
    for (final p in paths) {
      try {
        final jsonStr = await rootBundle.loadString(p);
        final raw = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
        return raw;
      } catch (_) {
        // try next
      }
    }
    return null;
  }

  void _reload() {
    setState(() {
      _future = _loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_TemplateItem>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber, size: 48),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).readyVisionsLoadFailed,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  snap.error.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).reload),
                ),
              ],
            ),
          );
        }
        final items = snap.data ?? const <_TemplateItem>[];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 48),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).noReadyVisionsFound,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).assetsReloadHint,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).reload),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final it = items[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: it.color,
                  child: Text(it.emoji),
                ),
                title: Text(it.title),
                subtitle: Text(it.description),
                trailing: const Icon(Icons.add),
                onTap: () => _showTemplateDetails(context, it),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTemplateDetails(
    BuildContext rootContext,
    _TemplateItem t,
  ) async {
    Map<String, dynamic>? data;
    try {
      final raw = await _tryLoadTemplatesRaw();
      data = raw?.firstWhere((e) => e['id'] == t.id, orElse: () => {});
      if (data == null || data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(rootContext).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(rootContext).templateDetailsNotFound,
              ),
            ),
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(rootContext).failedToLoad(e.toString()),
            ),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final habits =
            (data!['habits'] as List?)?.cast<Map<String, dynamic>>() ??
            const [];
        // Optional endDate from template (YYYY-MM-DD)
        DateTime? templateEndDate;
        final endStr = data['endDate'] as String?;
        if (endStr != null && endStr.length >= 10) {
          try {
            templateEndDate = DateTime.parse(endStr);
          } catch (_) {}
        }
        // Compute a finite duration in days for this vision preview
        int maxDay = -1;
        for (final h in habits) {
          final int? e = (h['endDay'] as num?)?.toInt();
          if (e != null && e > maxDay) maxDay = e;
          final offs = (h['activeOffsets'] as List?)
              ?.whereType<num>()
              .map((n) => n.toInt())
              .toList();
          if (offs != null && offs.isNotEmpty) {
            final m = offs.reduce((a, b) => a > b ? a : b);
            if (m > maxDay) maxDay = m;
          }
        }
        int durationDays = maxDay >= 0 ? maxDay : 30;
        if (durationDays < 1) durationDays = 1;
        if (durationDays > 365) durationDays = 365;
        // If a template end date exists, allow it to influence duration for the preview
        if (templateEndDate != null) {
          final now = DateTime.now();
          final diff = templateEndDate.difference(now).inDays;
          if (diff > 0) {
            durationDays = diff;
            if (durationDays < 1) durationDays = 1;
            if (durationDays > 365) durationDays = 365;
          }
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: t.color,
                    radius: 20,
                    child: Text(t.emoji),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: Theme.of(rootContext).textTheme.titleLarge,
                        ),
                        if ((t.description).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              t.description,
                              style: Theme.of(rootContext).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.av_timer, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(
                      rootContext,
                    ).approxVisionDurationDays(durationDays),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(rootContext).habitsSection,
                style: Theme.of(rootContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final h = habits[i];
                    final iconName =
                        (h['iconName'] as String?) ?? 'check_circle';
                    final icon = VisionRepository.iconFromName(iconName);
                    final color = Color(
                      (h['colorValue'] as num?)?.toInt() ??
                          Colors.blue.toARGB32(),
                    );
                    final type = (h['type'] as String?) ?? 'simple';
                    final target = (h['target'] as num?)?.toInt();
                    final unit = (h['unit'] as String?)?.toString();
                    // Range calculation: start/end from template or derive from offsets/duration
                    int startDay = (h['startDay'] as num?)?.toInt() ?? 1;
                    if (startDay < 1) startDay = 1;
                    if (startDay > 365) startDay = 365;
                    int? endDay = (h['endDay'] as num?)?.toInt();
                    int? offsMax;
                    final offs = (h['activeOffsets'] as List?)
                        ?.whereType<num>()
                        .map((n) => n.toInt())
                        .toList();
                    if (offs != null && offs.isNotEmpty) {
                      offsMax = offs.reduce((a, b) => a > b ? a : b);
                    }
                    int derivedEnd = endDay ?? offsMax ?? durationDays;
                    if (derivedEnd < 0) derivedEnd = 0;
                    if (derivedEnd > 365) derivedEnd = 365;
                    final int rangeStart = startDay;
                    final int rangeEnd = derivedEnd < rangeStart
                        ? rangeStart
                        : derivedEnd;
                    String details;
                    if (type == 'numerical') {
                      details = (target != null && unit != null)
                          ? AppLocalizations.of(
                              rootContext,
                            ).targetShort('$target $unit')
                          : AppLocalizations.of(rootContext).numericalGoalShort;
                    } else if (type == 'timer') {
                      details = target != null
                          ? AppLocalizations.of(rootContext).targetShort(
                              '$target ${AppLocalizations.of(rootContext).minutesSuffixShort}',
                            )
                          : AppLocalizations.of(rootContext).timerType;
                    } else {
                      details = AppLocalizations.of(
                        rootContext,
                      ).simpleTypeShort;
                    }
                    final rangeText =
                        ' • ${AppLocalizations.of(rootContext).dayRangeShort(rangeEnd, rangeStart)}';
                    details = '$details$rangeText';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Icon(icon, color: Colors.white),
                      ),
                      title: Text(h['title']?.toString() ?? ''),
                      subtitle: Text(
                        (h['description']?.toString() ?? '').isEmpty
                            ? details
                            : '${h['description']}\n$details',
                      ),
                      isThreeLine: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        // create via seed
                        final repo = VisionRepository.instance;
                        Vision? v = await repo.createFromSeed(t.id);
                        v ??= Vision(
                          id: 'vision_${DateTime.now().millisecondsSinceEpoch}',
                          title: t.title,
                          description: t.description,
                          emoji: t.emoji,
                          coverImage: null,
                          colorValue: t.color.toARGB32(),
                          linkedHabitIds: const [],
                          createdAt: DateTime.now(),
                          endDate: templateEndDate,
                          startDate: null,
                        );
                        // If seed did not create, add our manual vision with template endDate
                        if (v.linkedHabitIds.isEmpty) {
                          await repo.add(v);
                        } else if (templateEndDate != null) {
                          // Update the created vision to include endDate
                          await repo.update(
                            v.copyWith(endDate: templateEndDate),
                          );
                        }
                        // Gamification: XP for creating a vision
                        // ignore: unawaited_futures
                        GamificationRepository.instance.onVisionCreated(v);
                        if (mounted) {
                          // Close sheet, then close create screen with result
                          Navigator.pop(sheetContext);
                          Navigator.pop(rootContext, v);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: Text(AppLocalizations.of(rootContext).create),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TemplateItem {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final Color color;
  const _TemplateItem({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
  });
}

class _ManualTab extends StatefulWidget {
  const _ManualTab({super.key, this.initial, this.variant});
  final Vision? initial;
  final ThemeVariant? variant;
  @override
  State<_ManualTab> createState() => _ManualTabState();
}

class _ManualTabState extends State<_ManualTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Color _color = Colors.teal;
  String? _emoji = '🎯';
  String? _imagePath; // file path from gallery
  DateTime? _startDate; // optional explicit start date for the vision
  // Expanded color palette for dialogs
  static const List<Color> _palette = [
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
  // Yeni vizyon kapsamında oluşturulacak alışkanlıklar (şablon gibi)
  final List<VisionHabitTemplate> _newHabits = [];

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _setVisionStartDate(DateTime newStart, {bool force = false}) {
    if (!mounted) return;
    final normalized = _dateOnly(newStart);
    final current = _startDate != null ? _dateOnly(_startDate!) : null;
    final bool sameDay = current != null && _isSameDay(current, normalized);
    bool shouldUpdate;
    if (current == null) {
      shouldUpdate = true;
    } else if (force) {
      shouldUpdate = !sameDay;
    } else {
      shouldUpdate = !sameDay && normalized.isBefore(current);
    }
    if (!shouldUpdate) return;
    final previous = current;
    setState(() {
      if (previous != null) {
        _rebaseVisionHabits(previous, normalized);
      }
      _startDate = normalized;
    });
  }

  void _rebaseVisionHabits(DateTime oldBase, DateTime newBase) {
    if (_newHabits.isEmpty) return;
    final normalizedOld = _dateOnly(oldBase);
    final normalizedNew = _dateOnly(newBase);
    if (_isSameDay(normalizedOld, normalizedNew)) return;
    final updated = _newHabits
        .map((h) => _rebaseHabitTemplate(h, normalizedOld, normalizedNew))
        .toList();
    _newHabits
      ..clear()
      ..addAll(updated);
  }

  VisionHabitTemplate _rebaseHabitTemplate(
    VisionHabitTemplate h,
    DateTime oldBase,
    DateTime newBase,
  ) {
    final startDate = oldBase.add(Duration(days: h.startDay - 1));
    int startDay = startDate.difference(newBase).inDays + 1;
    if (startDay < 1) startDay = 1;
    int? endDay;
    if (h.endDay != null) {
      final endDate = oldBase.add(Duration(days: h.endDay! - 1));
      endDay = endDate.difference(newBase).inDays + 1;
      if (endDay < startDay) endDay = startDay;
    }
    List<int>? activeOffsets;
    if (h.activeOffsets != null && h.activeOffsets!.isNotEmpty) {
      final adjusted = <int>[];
      for (final offset in h.activeOffsets!) {
        final day = oldBase.add(Duration(days: offset - 1));
        final newOffset = day.difference(newBase).inDays + 1;
        if (newOffset >= startDay && (endDay == null || newOffset <= endDay)) {
          adjusted.add(newOffset);
        }
      }
      if (adjusted.isNotEmpty) {
        adjusted.sort();
        activeOffsets = adjusted;
      }
    }
    return VisionHabitTemplate(
      title: h.title,
      description: h.description,
      type: h.type,
      target: h.target,
      unit: h.unit,
      emoji: h.emoji,
      iconName: h.iconName,
      colorValue: h.colorValue,
      startDay: startDay,
      endDay: endDay,
      numericalTargetType: h.numericalTargetType,
      timerTargetType: h.timerTargetType,
      frequencyType: h.frequencyType,
      selectedWeekdays: h.selectedWeekdays == null
          ? null
          : List<int>.from(h.selectedWeekdays!),
      selectedMonthDays: h.selectedMonthDays == null
          ? null
          : List<int>.from(h.selectedMonthDays!),
      selectedYearDays: h.selectedYearDays == null
          ? null
          : List<String>.from(h.selectedYearDays!),
      periodicDays: h.periodicDays,
      activeOffsets: activeOffsets,
    );
  }

  // Listen to habit updates so edit buttons reflect changes immediately
  void _onHabitsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    HabitRepository.instance.removeListener(_onHabitsChanged);
    super.dispose();
  }

  // Allow Templates tab to prefill the manual form
  void applyTemplate(_TemplateItem t) {
    setState(() {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _color = t.color;
      _imagePath = null; // use emoji for template by default
      _emoji = t.emoji;
    });
  }

  // Apply a full VisionTemplate including its habits to Manual tab
  void applyFullTemplate(VisionTemplate tpl) {
    setState(() {
      _titleCtrl.text = tpl.title;
      _descCtrl.text = tpl.description ?? '';
      _color = Color(tpl.colorValue);
      _emoji = tpl.emoji ?? '🎯';
      _imagePath = null; // prefer emoji for portability

      // Convert template habits into newHabits for manual editing
      _newHabits
        ..clear()
        ..addAll(
          tpl.habits.map(
            (h) => VisionHabitTemplate(
              title: h.title,
              description: h.description,
              type: h.type,
              target: h.target,
              unit: h.unit,
              emoji: h.emoji,
              iconName: h.iconName,
              colorValue: h.colorValue,
              startDay: h.startDay,
              endDay: h.endDay,
              frequencyType: h.frequencyType,
              selectedWeekdays: h.selectedWeekdays == null
                  ? null
                  : List<int>.from(h.selectedWeekdays!),
              selectedMonthDays: h.selectedMonthDays == null
                  ? null
                  : List<int>.from(h.selectedMonthDays!),
              selectedYearDays: h.selectedYearDays == null
                  ? null
                  : List<String>.from(h.selectedYearDays!),
              periodicDays: h.periodicDays,
              activeOffsets: h.activeOffsets == null
                  ? null
                  : List<int>.from(h.activeOffsets!),
            ),
          ),
        );
    });
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
                AppLocalizations.of(context).chooseColor,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _palette.map((c) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _color = c;
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
                  AppLocalizations.of(context).chooseEmoji,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _EmojiGrid(
                  selectedEmoji: _emoji,
                  onSelect: (e) => setState(() {
                    _emoji = e;
                    Navigator.of(ctx).pop();
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).customEmoji,
                    hintText: AppLocalizations.of(context).customEmojiHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => custom = v.trim(),
                  onSubmitted: (_) {
                    if (custom.isNotEmpty) {
                      setState(() => _emoji = custom);
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      if (custom.isNotEmpty) {
                        setState(() => _emoji = custom);
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: Text(AppLocalizations.of(context).select),
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
    HabitRepository.instance.addListener(_onHabitsChanged);
    final v = widget.initial;
    if (v != null) {
      _titleCtrl.text = v.title;
      _descCtrl.text = v.description ?? '';
      _color = Color(v.colorValue);
      _emoji = v.emoji ?? '🎯';
      _imagePath = v.coverImage; // if null => emoji mode stays
      _startDate = v.startDate;
    } else {
      // For new visions, default the start date to today (normalized)
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day);
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initial = _startDate ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(
        () => _startDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Paylaş / İçe aktar butonları (şablon işlevini manuel ekran içine taşı)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _importFromLink,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.link, size: 18),
                  label: Text(AppLocalizations.of(context).importFromLink),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareAsLink,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -2,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: Text(AppLocalizations.of(context).shareAsLink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          // Start date UI moved to bottom; placeholder here to keep layout order
          // Visual section header
          Text(
            AppLocalizations.of(context).visual,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: Text(AppLocalizations.of(context).emojiLabel),
                selected: _imagePath == null,
                onSelected: (_) => setState(() => _imagePath = null),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(AppLocalizations.of(context).gallery),
                selected: _imagePath != null,
                onSelected: (_) async {
                  final pick = await _pickFromGallery();
                  if (pick != null) setState(() => _imagePath = pick);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          (_imagePath == null)
              ? const SizedBox.shrink()
              : _SelectedImage(path: _imagePath!, isFile: true),
          if (_imagePath == null) ...[
            const Divider(height: 32),
            Text(
              AppLocalizations.of(context).appearance,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: InkWell(
                      onTap: _imagePath == null ? _openColorDialog : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Opacity(
                        opacity: _imagePath == null ? 1 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(AppLocalizations.of(context).chooseColor),
                              const SizedBox(width: 12),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: InkWell(
                      onTap: _imagePath == null ? _openEmojiDialog : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Opacity(
                        opacity: _imagePath == null ? 1 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(AppLocalizations.of(context).chooseEmoji),
                              const SizedBox(width: 12),
                              Text(
                                _emoji ?? '🙂',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
          ],
          // Start date control placed above the main habits section
          Center(
            child: OutlinedButton(
              onPressed: _pickStartDate,
              child: Text(
                '${AppLocalizations.of(context).visionStartLabel}'
                '${_startDate != null ? "${_startDate!.day.toString().padLeft(2, "0")}/${_startDate!.month.toString().padLeft(2, "0")}/${_startDate!.year}" : AppLocalizations.of(context).select}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).habitsSection,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (widget.initial != null)
            _ExistingVisionHabitsList(
              habitIds: widget.initial!.linkedHabitIds,
              onEditHabit: (id) async {
                final repo = HabitRepository.instance;
                final h = repo.findById(id);
                if (h == null) return;
                final initialMap = _advancedMapFromExistingHabit(h);
                // Use the same local theme as VisionCreateScreen for the wizard
                final baseTheme = Theme.of(context);
                final bool isDark = baseTheme.brightness == Brightness.dark;
                final ThemeData localTheme =
                    (widget.variant == ThemeVariant.world)
                    ? (isDark
                          ? ThemeVariations.dark(ThemeVariant.earth)
                          : ThemeVariations.light(ThemeVariant.earth))
                    : baseTheme;
                final map = await Navigator.of(context)
                    .push<Map<String, dynamic>>(
                      MaterialPageRoute(
                        builder: (_) => Theme(
                          data: localTheme,
                          child: AdvancedHabitScreen(
                            editingHabitMap: initialMap,
                            useVisionDayOffsets: true,
                            returnAsMap: true,
                          ),
                        ),
                      ),
                    );
                if (map != null) {
                  await _applyAdvancedMapToExistingHabit(h, map);
                  if (mounted) setState(() {});
                }
              },
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 16),
          // Vizyon oluştur ekranı içinde yeni alışkanlık ekleme (şablon benzeri)
          Text(
            AppLocalizations.of(context).newHabits,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_newHabits.isEmpty)
            Text(AppLocalizations.of(context).notAddedYet),
          ..._newHabits.asMap().entries.map((e) {
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
                      ? AppLocalizations.of(
                          context,
                        ).dayRangeShort(h.endDay!, h.startDay)
                      : AppLocalizations.of(context).dayShort(h.startDay),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editNewHabit(i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() {
                        _newHabits.removeAt(i);
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addNewHabit,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context).addNewHabit),
          ),
          const SizedBox(height: 8),
          const Divider(height: 32),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(
              widget.initial == null
                  ? AppLocalizations.of(context).create
                  : AppLocalizations.of(context).save,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // (removed infinite/force logic: this app no longer supports 'infinite' vision mode)

  // Existing Habit -> Advanced wizard map (vision-day offsets mode)
  Map<String, dynamic> _advancedMapFromExistingHabit(Habit h) {
    HabitType habitType = h.habitType;
    // Dates
    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);
    DateTime start = today0;
    DateTime? end;
    try {
      start = DateTime.parse(h.startDate);
    } catch (_) {}
    if (h.endDate != null) {
      try {
        end = DateTime.parse(h.endDate!);
      } catch (_) {}
    }

    // Preserve scheduledDates and activeOffsets (1-based) if available
    List<int>? activeOffsets;
    List<String>? scheduledDates;
    if (h.scheduledDates != null && h.scheduledDates!.isNotEmpty) {
      scheduledDates = List<String>.from(h.scheduledDates!);
      final offs = <int>[];
      for (final ds in h.scheduledDates!) {
        try {
          final d = DateTime.parse(ds);
          offs.add(d.difference(today0).inDays + 1); // 1-based
        } catch (_) {}
      }
      if (offs.isNotEmpty) {
        offs.sort();
        activeOffsets = offs;
      }
    }

    return {
      'habitType': habitType,
      'name': h.title,
      'description': h.description,
      // Prefill frequency settings if stored on Habit
      if (h.frequencyType != null) 'frequencyType': h.frequencyType,
      if (h.selectedWeekdays != null)
        'selectedWeekdays': List<int>.from(h.selectedWeekdays!),
      if (h.selectedMonthDays != null)
        'selectedMonthDays': List<int>.from(h.selectedMonthDays!),
      if (h.selectedYearDays != null)
        'selectedYearDays': List<String>.from(h.selectedYearDays!),
      if (h.periodicDays != null) 'periodicDays': h.periodicDays,
      if (habitType == HabitType.numerical)
        'numericalTargetType': h.numericalTargetType.toString(),
      if (habitType == HabitType.timer)
        'timerTargetType': h.timerTargetType.toString(),
      if (habitType == HabitType.numerical) ...{
        'numericalTarget': h.targetCount,
        'numericalUnit': h.unit ?? '',
      },
      if (habitType == HabitType.timer) ...{
        'timerTargetMinutes': h.targetCount,
      },
      'startDate': start.toIso8601String(),
      'endDate': end?.toIso8601String(),
      if (activeOffsets != null) 'activeOffsets': activeOffsets,
      if (scheduledDates != null) 'scheduledDates': scheduledDates,
      'emoji': h.emoji,
      'color': h.color.value,
      // Reminder settings
      'reminderEnabled': h.reminderEnabled,
      if (h.reminderTime != null)
        'reminderTime': {
          'hour': h.reminderTime!.hour,
          'minute': h.reminderTime!.minute,
        },
      // Target policy types for preselecting segmented controls
      if (h.habitType == HabitType.numerical)
        'numericalTargetType': h.numericalTargetType.toString(),
      if (h.habitType == HabitType.timer)
        'timerTargetType': h.timerTargetType.toString(),
    };
  }

  // Apply Advanced wizard result back to an existing Habit
  Future<void> _applyAdvancedMapToExistingHabit(
    Habit h,
    Map<String, dynamic> m,
  ) async {
    // Type-specific fields
    int target = h.targetCount;
    String? unit = h.unit;
    final selType = m['habitType'] ?? m['type'];
    HabitType habitType = (selType is HabitType) ? selType : h.habitType;
    // Parse frequency-related values from the wizard result early so they're
    // available when building the updated Habit regardless of branch.
    final f = m['frequencyType'];
    String? freqType;
    if (f != null) {
      final s = f.toString();
      if (s.contains('daily')) {
        freqType = 'daily';
      } else if (s.contains('specificWeekdays'))
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
    if (habitType == HabitType.numerical) {
      target = (m['numericalTarget'] as num?)?.toInt() ?? target;
      unit = (m['numericalUnit'] as String?) ?? unit;
      final t = m['numericalTargetType']?.toString();
      if (t != null) {
        if (t.contains('exact')) {
          h.numericalTargetType = NumericalTargetType.exact;
        } else if (t.contains('maximum'))
          h.numericalTargetType = NumericalTargetType.maximum;
        else
          h.numericalTargetType = NumericalTargetType.minimum;
      }
    } else if (habitType == HabitType.timer) {
      target = (m['timerTargetMinutes'] as num?)?.toInt() ?? target;
      unit = AppLocalizations.of(context).minutesSuffixShort;
      final t = m['timerTargetType']?.toString();
      if (t != null) {
        if (t.contains('exact')) {
          h.timerTargetType = TimerTargetType.exact;
        } else if (t.contains('maximum'))
          h.timerTargetType = TimerTargetType.maximum;
        else
          h.timerTargetType = TimerTargetType.minimum;
      }
    } else {
      int startDay = 1;
      int? endDay;
      try {
        final startStr = m['startDate']?.toString();
        final endStr = m['endDate']?.toString();
        // Use vision start date as the base for computing 1-based offsets.
        final baseDate = _startDate ?? DateTime.now();
        final base = DateTime(baseDate.year, baseDate.month, baseDate.day);
        if (startStr != null) {
          final start = DateTime.parse(startStr);
          startDay = start.difference(base).inDays + 1;
          // If startDay < 1, allow shifting the Vision start earlier when
          // we're editing a Vision (i.e. _startDate exists). This lets users
          // pick a past date for an infinite habit without being blocked.
          if (startDay < 1) {
            if (_startDate == null) {
              // No vision start defined yet: set it to the selected date.
              setState(() {
                _startDate = DateTime(start.year, start.month, start.day);
              });
            } else {
              // Shift the existing vision start earlier to accommodate the selected date.
              setState(() {
                _startDate = _startDate!.subtract(Duration(days: 1 - startDay));
              });
            }
            startDay = 1;
          }
        }
        if (endStr != null) {
          final end = DateTime.parse(endStr);
          endDay = end.difference(base).inDays + 1;
          if (endDay < startDay) endDay = startDay;
        }
      } catch (_) {}
    }

    // Dates from wizard (these are absolute dates built from offsets)
    String startDate = h.startDate;
    String? endDate = h.endDate;
    try {
      final s = m['startDate']?.toString();
      if (s != null) {
        final parsedS = DateTime.parse(s);
        startDate = parsedS.toIso8601String().substring(0, 10);
        // Check if this new start date is before the vision start date
        if (_startDate != null) {
          final visionStart = _dateOnly(_startDate!);
          final habitStart = _dateOnly(parsedS);
          if (habitStart.isBefore(visionStart)) {
            // Update vision start date to accommodate this earlier habit
            _setVisionStartDate(habitStart);
          }
        }
      }
      final e = m['endDate']?.toString();
      if (e != null) {
        endDate = DateTime.parse(e).toIso8601String().substring(0, 10);
      }
    } catch (_) {}

    // Scheduled dates from activeOffsets
    List<String>? scheduledDates;
    final offs = m['activeOffsets'];
    if (offs is List && offs.isNotEmpty) {
      final today = DateTime.now();
      final today0 = DateTime(today.year, today.month, today.day);
      final list = <String>[];
      for (final o in offs.whereType<num>()) {
        final d = today0.add(Duration(days: o.toInt() - 1));
        final ds =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        list.add(ds);
      }
      list.sort();
      scheduledDates = list;
    } else if (m['scheduledDates'] is List &&
        (m['scheduledDates'] as List).isNotEmpty) {
      scheduledDates = List<String>.from(m['scheduledDates']);
    } else {
      // If no explicit offsets provided, keep existing schedule as-is
      scheduledDates = h.scheduledDates == null
          ? null
          : List<String>.from(h.scheduledDates!);
    }

    int colorValue = h.color.value;
    if (m['color'] is Color) {
      colorValue = (m['color'] as Color).value;
    } else if (m['color'] is int) {
      colorValue = m['color'] as int;
    }

    final updated =
        Habit(
            id: h.id,
            title: (m['title'] as String?)?.trim().isNotEmpty == true
                ? m['title']
                : (m['name'] as String?)?.trim().isNotEmpty == true
                ? m['name']
                : h.title,
            description: (m['description'] as String?) ?? h.description,
            icon: h.icon,
            emoji: (m['emoji'] as String?) ?? h.emoji,
            color: Color(colorValue),
            targetCount: target,
            habitType: habitType,
            unit: unit,
            currentStreak: h.currentStreak,
            isCompleted: h.isCompleted,
            progressDate: h.progressDate,
            startDate: startDate,
            endDate: endDate,
            dailyLog: Map.of(h.dailyLog),
            leftoverSeconds: h.leftoverSeconds,
            listId: h.listId,
            scheduledDates: scheduledDates,
            // Preserve/apply target-type policy selections
            numericalTargetType: h.numericalTargetType,
            timerTargetType: h.timerTargetType,
            // Reminder settings
            reminderEnabled: m.containsKey('reminderEnabled')
                ? (m['reminderEnabled'] as bool? ?? false)
                : h.reminderEnabled,
            reminderTime: (() {
              if (m.containsKey('reminderTime')) {
                final rt = m['reminderTime'];
                if (rt is Map) {
                  final hour = rt['hour'] as int?;
                  final minute = rt['minute'] as int?;
                  if (hour != null && minute != null) {
                    return TimeOfDay(hour: hour, minute: minute);
                  }
                }
                return null;
              }
              return h.reminderTime;
            })(),
          )
          ..isAdvanced = true
          ..frequencyType = freqType
          ..selectedWeekdays = week
          ..selectedMonthDays = month
          ..selectedYearDays = year
          ..periodicDays = periodic;

    await HabitRepository.instance.updateHabit(updated);
  }

  // Map AdvancedHabitWizard result -> VisionHabitTemplate
  VisionHabitTemplate? _visionHabitFromAdvancedMap(Map<String, dynamic> m) {
    // Habit type
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
      if (s.contains('numerical')) {
        type = 'numerical';
      } else if (s.contains('timer'))
        type = 'timer';
      else
        type = 'simple';
    }

    // Targets/units and policy (min/exact/max)
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

    // Frequency
    String? freqType;
    final f = m['frequencyType'];
    if (f != null) {
      final s = f.toString();
      if (s.contains('daily')) {
        freqType = 'daily';
      } else if (s.contains('specificWeekdays'))
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

    // Dates -> offsets
    final startStr = m['startDate']?.toString();
    final endStr = m['endDate']?.toString();
    final DateTime? parsedStart = (startStr != null && startStr.isNotEmpty)
        ? DateTime.tryParse(startStr)
        : null;
    final DateTime? parsedEnd = (endStr != null && endStr.isNotEmpty)
        ? DateTime.tryParse(endStr)
        : null;

    final DateTime? normalizedStart = parsedStart != null
        ? _dateOnly(parsedStart)
        : null;
    final DateTime? normalizedEnd = parsedEnd != null
        ? _dateOnly(parsedEnd)
        : null;

    final DateTime fallbackBase = _startDate != null
        ? _dateOnly(_startDate!)
        : _dateOnly(DateTime.now());
    final DateTime baseBefore = normalizedStart ?? fallbackBase;

    // Automatically adjust vision start date if the new habit starts earlier
    if (normalizedStart != null) {
      _setVisionStartDate(normalizedStart);
    } else if (_startDate == null) {
      _setVisionStartDate(baseBefore);
    }

    // Re-read base after potential update
    final DateTime base = _dateOnly(_startDate ?? baseBefore);

    final DateTime startDate = normalizedStart ?? base;
    int startDay = startDate.difference(base).inDays + 1;
    // If startDay < 1, it means the habit starts before the vision base.
    // _setVisionStartDate should have handled this, but just in case:
    if (startDay < 1) {
      // Force update vision start to habit start
      _setVisionStartDate(startDate, force: true);
      // Recalculate base and startDay
      final newBase = _dateOnly(_startDate!);
      startDay = startDate.difference(newBase).inDays + 1;
    }
    if (startDay < 1) startDay = 1;

    int? endDay;
    if (normalizedEnd != null) {
      endDay = normalizedEnd.difference(base).inDays + 1;
      if (endDay < startDay) endDay = startDay;
    }

    // Active offsets (manual selected days within [startDay..endDay])
    List<int>? activeOffsets;
    final offsetsRaw = m['activeOffsets'] as List?;
    if (offsetsRaw != null && offsetsRaw.isNotEmpty) {
      final adjusted = <int>[];
      for (final value in offsetsRaw.whereType<num>()) {
        final day = baseBefore.add(Duration(days: value.toInt() - 1));
        final newOffset = day.difference(base).inDays + 1;
        if (newOffset >= startDay && (endDay == null || newOffset <= endDay)) {
          adjusted.add(newOffset);
        }
      }
      if (adjusted.isNotEmpty) {
        adjusted.sort();
        activeOffsets = adjusted;
      }
    } else {
      // Handle scheduledDates from AdvancedHabitScreen
      final scheduled = m['scheduledDates'] as List?;
      if (scheduled != null && scheduled.isNotEmpty) {
        final adjusted = <int>[];
        for (final dateStr in scheduled) {
          final date = DateTime.tryParse(dateStr.toString());
          if (date != null) {
            final day = _dateOnly(date);
            final newOffset = day.difference(base).inDays + 1;
            if (newOffset >= startDay &&
                (endDay == null || newOffset <= endDay)) {
              adjusted.add(newOffset);
            }
          }
        }
        if (adjusted.isNotEmpty) {
          adjusted.sort();
          activeOffsets = adjusted;
        }
      }
    }

    int colorValue = _color.value;
    if (m['color'] is Color) {
      colorValue = (m['color'] as Color).value;
    } else if (m['color'] is int) {
      colorValue = m['color'] as int;
    }

    final emoji = (m['emoji'] as String?) ?? _emoji;

    // Reminder settings
    final reminderEnabled = m['reminderEnabled'] as bool? ?? false;
    TimeOfDay? reminderTime;
    final rt = m['reminderTime'];
    if (rt is Map) {
      final hour = rt['hour'] as int?;
      final minute = rt['minute'] as int?;
      if (hour != null && minute != null) {
        reminderTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    return VisionHabitTemplate(
      title: (m['title'] as String?)?.trim().isNotEmpty == true
          ? m['title']
          : (m['name'] as String?)?.trim().isNotEmpty == true
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
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
  }

  DateTime? _tryParseDayString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final parsed = DateTime.parse(value);
      return _dateOnly(parsed);
    } catch (_) {
      return null;
    }
  }

  // Map VisionHabitTemplate -> AdvancedHabitWizard initial map
  Map<String, dynamic> _advancedMapFromVisionHabit(VisionHabitTemplate h) {
    HabitType habitType = HabitType.simple;
    if (h.type == 'numerical') habitType = HabitType.numerical;
    if (h.type == 'timer') habitType = HabitType.timer;

    final baseDate = _startDate ?? DateTime.now();
    final base = DateTime(baseDate.year, baseDate.month, baseDate.day);
    final startDate = base.add(Duration(days: h.startDay - 1));
    final endDate = h.endDay != null
        ? base.add(Duration(days: h.endDay! - 1))
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
      // Reminder settings
      'reminderEnabled': h.reminderEnabled ?? false,
      if (h.reminderTime != null)
        'reminderTime': {
          'hour': h.reminderTime!.hour,
          'minute': h.reminderTime!.minute,
        },
    };
  }

  Future<void> _shareAsLink() async {
    // Sadece yeni alışkanlıklar bir şablon olarak paylaşılır.
    if (_newHabits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).addNewHabit)),
      );
      return;
    }
    final tpl = VisionTemplate(
      id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim().isEmpty
          ? AppLocalizations.of(context).vision
          : _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      emoji: _imagePath == null ? (_emoji ?? '🎯') : (_emoji ?? '🎯'),
      colorValue: _color.toARGB32(),
      autoSeed: false,
      habits: List.unmodifiable(_newHabits),
      endDate: null,
    );
    final link = VisionTemplateRepository.instance.toShareLink(tpl);
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
    final tpl = VisionTemplateRepository.instance.fromShareLink(link);
    if (tpl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).invalidLink)),
      );
      return;
    }
    setState(() {
      _titleCtrl.text = tpl.title;
      _descCtrl.text = tpl.description ?? '';
      _emoji = tpl.emoji ?? '🎯';
      _color = Color(tpl.colorValue);
      _newHabits
        ..clear()
        ..addAll(tpl.habits);
    });
  }

  void _addNewHabit() async {
    // Use the same local theme as VisionCreateScreen for the screen
    final baseTheme = Theme.of(context);
    final bool isDark = baseTheme.brightness == Brightness.dark;
    final ThemeData localTheme = (widget.variant == ThemeVariant.world)
        ? (isDark
              ? ThemeVariations.dark(ThemeVariant.earth)
              : ThemeVariations.light(ThemeVariant.earth))
        : baseTheme;
    final map = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => Theme(
          data: localTheme,
          child: AdvancedHabitScreen(
            useVisionDayOffsets: true,
            visionStartDate: _startDate,
            returnAsMap: true,
          ),
        ),
      ),
    );
    if (map != null) {
      final tpl = _visionHabitFromAdvancedMap(map);
      if (tpl != null) {
        setState(() {
          _newHabits.add(tpl);
        });
      }
    }
  }

  void _editNewHabit(int index) async {
    final initialMap = _advancedMapFromVisionHabit(_newHabits[index]);
    // Decide mode based on whether this vision habit uses explicit activeOffsets
    final wasFinite = _newHabits[index].activeOffsets != null;
    // Use the same local theme as VisionCreateScreen for the screen
    final baseTheme = Theme.of(context);
    final bool isDark = baseTheme.brightness == Brightness.dark;
    final ThemeData localTheme = (widget.variant == ThemeVariant.world)
        ? (isDark
              ? ThemeVariations.dark(ThemeVariant.earth)
              : ThemeVariations.light(ThemeVariant.earth))
        : baseTheme;
    final map = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => Theme(
          data: localTheme,
          child: AdvancedHabitScreen(
            editingHabitMap: initialMap,
            useVisionDayOffsets: wasFinite,
            visionStartDate: _startDate,
            returnAsMap: true,
          ),
        ),
      ),
    );
    if (map != null) {
      final tpl = _visionHabitFromAdvancedMap(map);
      if (tpl != null) {
        setState(() {
          _newHabits[index] = tpl;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.initial == null) {
      // Eğer yeni alışkanlıklar eklendiyse önce onları oluşturup vizyonu onlarla başlatalım
      if (_newHabits.isNotEmpty) {
        // Manuel vizyon bilgileri ile geçici bir şablon oluştur
        final tpl = VisionTemplate(
          id: 'manual_tpl_${DateTime.now().millisecondsSinceEpoch}',
          title: _titleCtrl.text.trim().isEmpty
              ? AppLocalizations.of(context).vision
              : _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          emoji: _imagePath == null ? (_emoji ?? '🎯') : (_emoji ?? '🎯'),
          colorValue: _color.toARGB32(),
          autoSeed: false,
          habits: List.unmodifiable(_newHabits),
          endDate: null,
        );
        // Süreyi, eklenen alışkanlıklardaki en büyük endDay/activeOffset'e göre otomatik belirleyelim
        int? durationDays;
        int maxDay = -1;
        for (final h in _newHabits) {
          if (h.activeOffsets != null && h.activeOffsets!.isNotEmpty) {
            for (final d in h.activeOffsets!) {
              if (d > maxDay) maxDay = d;
            }
          }
          if (h.endDay != null && h.endDay! > maxDay) {
            maxDay = h.endDay!;
          }
        }
        if (maxDay >= 1) durationDays = maxDay;

        final repo = VisionRepository.instance;
        final created = await repo.createFromTemplate(
          tpl,
          durationDays: durationDays,
          startDate: _startDate,
        );
        if (created != null) {
          // Otomatik endDate: bugün + durationDays - 1
          DateTime? autoEnd;
          if (durationDays != null) {
            final today = DateTime.now();
            final today0 = DateTime(today.year, today.month, today.day);
            autoEnd = today0.add(Duration(days: durationDays - 1));
          }
          final updated = created.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim().isEmpty
                ? null
                : _descCtrl.text.trim(),
            emoji: _imagePath == null ? (_emoji ?? '🎯') : null,
            coverImage: _imagePath,
            endDate: autoEnd ?? created.endDate,
            startDate: _startDate ?? created.startDate,
            colorValue: _color.toARGB32(),
            // Bağlama kaldırıldı: sadece bu vizyonda oluşturulan alışkanlıklar
            linkedHabitIds: created.linkedHabitIds,
          );
          await VisionRepository.instance.update(updated);
          if (mounted) Navigator.pop(context, updated);
          return;
        }
        // Aksi halde (oluşturulamadı) düz vizyon yaratıp devam edelim
      }
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      // Otomatik endDate, yeni alışkanlık yoksa null kalsın.
      DateTime? autoEnd;
      if (_newHabits.isNotEmpty) {
        int maxDay = -1;
        for (final h in _newHabits) {
          if (h.activeOffsets != null && h.activeOffsets!.isNotEmpty) {
            for (final d in h.activeOffsets!) {
              if (d > maxDay) maxDay = d;
            }
          }
          if (h.endDay != null && h.endDay! > maxDay) {
            maxDay = h.endDay!;
          }
        }
        if (maxDay >= 1) {
          final today = DateTime.now();
          final today0 = DateTime(today.year, today.month, today.day);
          autoEnd = today0.add(Duration(days: maxDay - 1));
        }
      }
      final vision = Vision(
        id: 'vision_$now',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        emoji: _imagePath == null ? _emoji : null,
        coverImage: _imagePath,
        colorValue: _color.toARGB32(),
        // Yeni vizyonu alışkanlık bağlamadan oluştur
        linkedHabitIds: const [],
        createdAt: DateTime.now(),
        endDate: autoEnd,
        startDate: _startDate,
      );
      await VisionRepository.instance.add(vision);
      if (mounted) Navigator.pop(context, vision);
    } else {
      // Edit mode: Create new habits if any and add to vision
      final newHabitIds = <String>[];

      // Create new habits from _newHabits list
      if (_newHabits.isNotEmpty) {
        final repo = HabitRepository.instance;
        final today = DateTime.now();
        final visionStart = _startDate ?? widget.initial!.startDate ?? today;

        for (final template in _newHabits) {
          final habitId = UniqueKey().toString();

          // Calculate scheduled dates based on vision context
          final List<String> schedule = [];
          if (template.activeOffsets != null &&
              template.activeOffsets!.isNotEmpty) {
            for (final offset in template.activeOffsets!) {
              final date = visionStart.add(Duration(days: offset));
              schedule.add(
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              );
            }
          }

          // Determine start and end dates
          final startDay = template.startDay ?? 1;
          final endDay = template.endDay;
          final startDate = visionStart.add(Duration(days: startDay - 1));
          final endDate = endDay != null
              ? visionStart.add(Duration(days: endDay - 1))
              : null;

          final startKey =
              '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
          final endKey = endDate != null
              ? '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}'
              : null;

          // Parse HabitType from string
          final HabitType habitType = switch (template.type) {
            'numerical' => HabitType.numerical,
            'timer' => HabitType.timer,
            _ => HabitType.simple,
          };

          // Parse target policy types
          NumericalTargetType numType = NumericalTargetType.minimum;
          if (template.numericalTargetType != null) {
            if (template.numericalTargetType!.contains('exact')) {
              numType = NumericalTargetType.exact;
            } else if (template.numericalTargetType!.contains('maximum')) {
              numType = NumericalTargetType.maximum;
            }
          }

          TimerTargetType timType = TimerTargetType.minimum;
          if (template.timerTargetType != null) {
            if (template.timerTargetType!.contains('exact')) {
              timType = TimerTargetType.exact;
            } else if (template.timerTargetType!.contains('maximum')) {
              timType = TimerTargetType.maximum;
            }
          }

          // Use a const material icon directly to preserve tree-shaking
          const IconData habitIcon = Icons.check_circle;

          // Create habit
          final habit = Habit(
            id: habitId,
            title: template.title,
            description: template.description ?? '',
            icon: habitIcon,
            emoji: template.emoji,
            color: Color(template.colorValue),
            targetCount:
                template.target ??
                (habitType == HabitType.simple
                    ? 1
                    : (habitType == HabitType.timer ? 10 : 0)),
            habitType: habitType,
            unit: habitType == HabitType.simple ? null : template.unit,
            currentStreak: 0,
            isCompleted: false,
            progressDate:
                '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
            startDate: startKey,
            endDate: endKey,
            scheduledDates: schedule.isEmpty ? null : schedule,
            numericalTargetType: numType,
            timerTargetType: timType,
            reminderEnabled: template.reminderEnabled ?? false,
            reminderTime: template.reminderTime,
            linkedVisionId: widget.initial!.id, // Link to this vision
          );

          await repo.addHabit(habit);
          newHabitIds.add(habitId);
        }
      }

      // Calculate auto end date
      // Edit: endDate otomatik hesaplanır (yeni alışkanlıklara göre),
      DateTime? autoEnd;
      // 1) Yeni eklenen taslak alışkanlıklardan hesapla
      int maxDay = -1;
      for (final h in _newHabits) {
        if (h.activeOffsets != null && h.activeOffsets!.isNotEmpty) {
          for (final d in h.activeOffsets!) {
            if (d > maxDay) maxDay = d;
          }
        }
        if (h.endDay != null && h.endDay! > maxDay) {
          maxDay = h.endDay!;
        }
      }
      // 2) Eğer yeni alışkanlık yoksa, mevcut bağlı alışkanlıkların bitişini kullan
      if (maxDay < 1 && widget.initial!.linkedHabitIds.isNotEmpty) {
        final repo = HabitRepository.instance;
        final today = DateTime.now();
        final today0 = DateTime(today.year, today.month, today.day);
        for (final id in widget.initial!.linkedHabitIds) {
          final h = repo.findById(id);
          if (h == null) continue;
          // scheduledDates var ise en son tarihe bak
          if (h.scheduledDates != null && h.scheduledDates!.isNotEmpty) {
            final last = h.scheduledDates!.last;
            try {
              final d = DateTime.parse(last);
              final off = d.difference(today0).inDays + 1;
              if (off > maxDay) maxDay = off;
            } catch (_) {}
          }
          // yoksa endDate
          if (h.endDate != null) {
            try {
              final d = DateTime.parse(h.endDate!);
              final off = d.difference(today0).inDays + 1;
              if (off > maxDay) maxDay = off;
            } catch (_) {}
          }
        }
      }
      if (maxDay >= 1) {
        final today = DateTime.now();
        final today0 = DateTime(today.year, today.month, today.day);
        autoEnd = today0.add(Duration(days: maxDay - 1));
      }

      final updated = widget.initial!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        emoji: _imagePath == null ? _emoji : null,
        coverImage: _imagePath,
        colorValue: _color.toARGB32(),
        // Include both existing and newly created habits
        linkedHabitIds: [...widget.initial!.linkedHabitIds, ...newHabitIds],
        endDate: autoEnd ?? widget.initial!.endDate,
        startDate: _startDate ?? widget.initial!.startDate,
      );
      await VisionRepository.instance.update(updated);
      if (mounted) Navigator.pop(context, updated);
    }
  }

  Future<String?> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.selectedEmoji, required this.onSelect});

  final String? selectedEmoji;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const tileSize = 44.0;
        const spacing = 8.0;
        int cols = ((constraints.maxWidth + spacing) / (tileSize + spacing))
            .floor();
        cols = cols.clamp(4, 12);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: cols * tileSize + (cols - 1) * spacing,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: kEmojiPresets.length,
              itemBuilder: (context, i) {
                final e = kEmojiPresets[i];
                final isSel = selectedEmoji == e;
                return InkWell(
                  onTap: () => onSelect(e),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel
                          ? scheme.primaryContainer
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SelectedImage extends StatelessWidget {
  final String path;
  final bool isFile;
  const _SelectedImage({required this.path, this.isFile = false});
  @override
  Widget build(BuildContext context) {
    final image = isFile
        ? Image.file(
            // ignore: prefer_constructors_over_static_methods
            File(path),
            height: 120,
            fit: BoxFit.cover,
          )
        : Image.asset(path, height: 120, fit: BoxFit.cover);
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: image);
  }
}

// Read-only list of current vision habits with edit actions
class _ExistingVisionHabitsList extends StatelessWidget {
  final List<String> habitIds;
  final void Function(String habitId)? onEditHabit;
  const _ExistingVisionHabitsList({required this.habitIds, this.onEditHabit});

  @override
  Widget build(BuildContext context) {
    if (habitIds.isEmpty) {
      return Text(AppLocalizations.of(context).noLinkedHabitsInVision);
    }
    final all = HabitRepository.instance.habits;
    final items = all.where((h) => habitIds.contains(h.id)).toList();
    if (items.isEmpty) {
      return Text(AppLocalizations.of(context).loadingHabits);
    }
    return Column(
      children: items
          .map(
            (h) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: h.color,
                  child: Text(h.emoji ?? '🏷️'),
                ),
                title: Text(h.title),
                subtitle: Text(
                  (h.description.isNotEmpty)
                      ? h.description
                      : AppLocalizations.of(context).habitOfThisVision,
                ),
                trailing: onEditHabit == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: AppLocalizations.of(context).edit,
                        onPressed: () => onEditHabit!(h.id),
                      ),
              ),
            ),
          )
          .toList(),
    );
  }
}
