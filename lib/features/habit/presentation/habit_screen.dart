import 'package:flutter/material.dart';
import '../../../core/icons/icon_mapping.dart';
import 'widgets/fab_menu.dart';
import 'widgets/daily_task_dialog.dart';
import 'widgets/list_creation_dialog.dart';
import 'widgets/habit_card.dart';
import 'simple_habit_screen.dart';
import 'advanced_habit_screen.dart';
import 'habit_analysis_screen.dart';
import 'package:mira/l10n/app_localizations.dart';
import '../domain/habit_types.dart';
import '../domain/habit_repository.dart';
import '../domain/habit_model.dart';
import '../domain/category_repository.dart';
import '../domain/list_repository.dart';
import '../domain/list_model.dart';
import '../domain/daily_task_repository.dart';
import '../domain/daily_task_model.dart';
import '../../vision/data/vision_repository.dart';
import '../../vision/data/vision_model.dart';
// removed unused imports

/// Represents a grouped item for the habit/task list view
sealed class _GroupedItem {}

class _ListHeader extends _GroupedItem {
  final String? listId;
  final String title;
  _ListHeader({required this.listId, required this.title});
}

class _TaskItem extends _GroupedItem {
  final DailyTask task;
  _TaskItem(this.task);
}

class _HabitItem extends _GroupedItem {
  final Habit habit;
  _HabitItem(this.habit);
}

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});
  @override
  State<HabitScreen> createState() => HabitScreenState();
}

class HabitScreenState extends State<HabitScreen> {
  DateTime _selected = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  bool _isFabExpanded = false;
  final ScrollController _dateScrollController = ScrollController();
  DateTime get _monthEnd => DateTime(_selected.year, _selected.month + 1, 0);
  List<DateTime> get _monthDays => List.generate(
    _monthEnd.day,
    (i) => DateTime(_selected.year, _selected.month, i + 1),
  );

  final HabitRepository _repo = HabitRepository.instance;
  final ListRepository _listRepo = ListRepository.instance;
  final DailyTaskRepository _taskRepo = DailyTaskRepository.instance;

  // Filter state
  Set<HabitType> _selectedTypes = {
    HabitType.simple,
    HabitType.numerical,
    HabitType.timer,
  };
  CompletionFilter _completionFilter = CompletionFilter.all;
  String? _selectedListId; // null = all lists

  @override
  void initState() {
    super.initState();
    // Repository'yi başlat ve hazır olunca ekranı yenile
    _repo.initialize().then((_) {
      if (mounted) setState(() {});
    });
    _repo.addListener(_onRepoChange);
    _listRepo.initialize().then((_) {
      if (mounted) setState(() {});
    });
    _listRepo.addListener(_onRepoChange);
    _taskRepo.initialize().then((_) {
      if (mounted) setState(() {});
    });
    _taskRepo.addListener(_onRepoChange);

    // Scroll date row to make today's item visible on first show
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollDateRowToSelected(),
    );
  }

  void _onRepoChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChange);
    _listRepo.removeListener(_onRepoChange);
    _taskRepo.removeListener(_onRepoChange);
    _dateScrollController.dispose();
    super.dispose();
  }

  String _weekdayLabel(BuildContext context, int w) {
    final l10n = AppLocalizations.of(context);
    switch (w) {
      case DateTime.monday:
        return l10n.weekdaysShortMon;
      case DateTime.tuesday:
        return l10n.weekdaysShortTue;
      case DateTime.wednesday:
        return l10n.weekdaysShortWed;
      case DateTime.thursday:
        return l10n.weekdaysShortThu;
      case DateTime.friday:
        return l10n.weekdaysShortFri;
      case DateTime.saturday:
        return l10n.weekdaysShortSat;
      case DateTime.sunday:
        return l10n.weekdaysShortSun;
      default:
        return '';
    }
  }

  void showCalendar() => _pickDate();

  void _scrollDateRowToSelected({bool animate = false}) {
    if (!_dateScrollController.hasClients) return;
    // Each item ~ width 40 + horizontal padding 4 = 44, plus list left padding 4
    final int index = _selected.day - 1;
    final double base = 4 + index * 44.0;
    // Try to place selected near the center of the viewport
    final viewport = _dateScrollController.position.viewportDimension;
    final target = (base - viewport / 2 + 22).clamp(
      0.0,
      _dateScrollController.position.maxScrollExtent,
    );
    if (animate) {
      _dateScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _dateScrollController.jumpTo(target);
    }
  }

  String _dayKeyFromDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isHabitCompletedOnDate(Habit habit, DateTime date) {
    final String dayKey = _dayKeyFromDate(date);
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final bool isToday = _isSameDay(date, todayDate);
    // Before start date: not counted (and not considered missed)
    final String startDateStr = habit.startDate;
    final DateTime startDate = DateTime(
      int.parse(startDateStr.substring(0, 4)),
      int.parse(startDateStr.substring(5, 7)),
      int.parse(startDateStr.substring(8, 10)),
    );
    if (date.isBefore(
      DateTime(startDate.year, startDate.month, startDate.day),
    )) {
      return false;
    }
    // If habit has an explicit schedule, only consider days on that schedule
    if (habit.scheduledDates != null && habit.scheduledDates!.isNotEmpty) {
      if (!habit.scheduledDates!.contains(dayKey)) return false;
    }
    if (isToday) {
      // Live state for today: consider in-memory flag or explicit log entry
      if (habit.isCompleted) return true;
      // If there is an explicit entry today, evaluate it; otherwise not completed yet
      if (habit.dailyLog.containsKey(dayKey)) {
        return HabitRepository.evaluateCompletionFromLog(habit, dayKey);
      }
      return false;
    }
    // For non-today days: only completed if there is an explicit log entry that satisfies policy
    return HabitRepository.evaluateCompletionFromLog(habit, dayKey);
  }

  int _consecutiveMissedDaysBefore(Habit habit, DateTime date, {int cap = 7}) {
    int streak = 0;
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final String startDateStr = habit.startDate;
    final DateTime startDate = DateTime(
      int.parse(startDateStr.substring(0, 4)),
      int.parse(startDateStr.substring(5, 7)),
      int.parse(startDateStr.substring(8, 10)),
    );
    // Count from the day before the given date, back to startDate or until a completed is found
    DateTime cursor = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(const Duration(days: 1));
    while (streak < cap) {
      // Stop if before start
      final dOnly = DateTime(cursor.year, cursor.month, cursor.day);
      if (dOnly.isBefore(
        DateTime(startDate.year, startDate.month, startDate.day),
      ))
        break;
      // For future days relative to 'today', don't count as missed
      if (dOnly.isAfter(todayDate)) break;
      // If scheduledDates present and the day is not scheduled, skip counting it as missed
      final String k = _dayKeyFromDate(dOnly);
      if (habit.scheduledDates != null && habit.scheduledDates!.isNotEmpty) {
        if (!habit.scheduledDates!.contains(k)) {
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
      }
      final completed = _isHabitCompletedOnDate(habit, dOnly);
      if (completed) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // Exposed for AppBar action in main.dart
  Future<void> showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        Set<HabitType> localTypes = {..._selectedTypes};
        CompletionFilter localCompletion = _completionFilter;
        String? localListId = _selectedListId;
        return StatefulBuilder(
          builder: (context, setModalState) {
            void toggleType(HabitType t) {
              setModalState(() {
                if (localTypes.contains(t)) {
                  localTypes.remove(t);
                } else {
                  localTypes.add(t);
                }
              });
            }

            Widget typeChip(HabitType t, String label, IconData icon) =>
                FilterChip(
                  label: Text(label),
                  avatar: Icon(icon, size: 18),
                  selected: localTypes.contains(t),
                  onSelected: (_) => toggleType(t),
                );

            final content = Padding(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).filterTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // close sheet to avoid stacking, then open manager
                          Navigator.of(context).pop();
                          await _openManageListsSheet();
                        },
                        icon: const Icon(Icons.list_alt_outlined),
                        label: Text(AppLocalizations.of(context).manageLists),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).typeLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      typeChip(
                        HabitType.simple,
                        AppLocalizations.of(context).simpleTypeShort,
                        Icons.check_circle,
                      ),
                      typeChip(
                        HabitType.numerical,
                        AppLocalizations.of(context).numericalType,
                        Icons.onetwothree,
                      ),
                      typeChip(
                        HabitType.timer,
                        AppLocalizations.of(context).timerType,
                        Icons.timer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).listLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: localListId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(AppLocalizations.of(context).allLabel),
                      ),
                      ..._listRepo.lists
                          .map(
                            (l) => DropdownMenuItem<String?>(
                              value: l.id,
                              child: Text(l.title),
                            ),
                          )
                          .toList(),
                    ],
                    onChanged: (v) => setModalState(() => localListId = v),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).statusLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  RadioGroup<CompletionFilter>(
                    groupValue: localCompletion,
                    onChanged: (v) {
                      if (v != null) setModalState(() => localCompletion = v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<CompletionFilter>(
                          contentPadding: EdgeInsets.zero,
                          value: CompletionFilter.all,
                          title: Text(AppLocalizations.of(context).allLabel),
                        ),
                        RadioListTile<CompletionFilter>(
                          contentPadding: EdgeInsets.zero,
                          value: CompletionFilter.completed,
                          title: Text(
                            AppLocalizations.of(context).completedSelectedDay,
                          ),
                        ),
                        RadioListTile<CompletionFilter>(
                          contentPadding: EdgeInsets.zero,
                          value: CompletionFilter.incomplete,
                          title: Text(
                            AppLocalizations.of(context).incompleteSelectedDay,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop({'reset': true}),
                        child: Text(AppLocalizations.of(context).clear),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: localTypes.isEmpty
                            ? null
                            : () => Navigator.of(context).pop({
                                'types': localTypes,
                                'completion': localCompletion,
                                'listId': localListId,
                              }),
                        child: Text(AppLocalizations.of(context).apply),
                      ),
                    ],
                  ),
                ],
              ),
            );
            return FractionallySizedBox(
              heightFactor: 0.85,
              child: SingleChildScrollView(child: content),
            );
          },
        );
      },
    );

    if (!mounted) return;
    if (result == null) return;
    if (result['reset'] == true) {
      setState(() {
        _selectedTypes = {
          HabitType.simple,
          HabitType.numerical,
          HabitType.timer,
        };
        _completionFilter = CompletionFilter.all;
        _selectedListId = null;
      });
      return;
    }
    final Set<HabitType>? types = (result['types'] as Set<HabitType>?);
    final CompletionFilter? completion =
        result['completion'] as CompletionFilter?;
    final String? listId = result['listId'] as String?;
    if (types != null && completion != null) {
      setState(() {
        _selectedTypes = types;
        _completionFilter = completion;
        _selectedListId = listId;
      });
    }
  }

  Future<void> _openManageListsSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            final lists = _listRepo.lists;
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).manageLists,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context).close,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).manageListsSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: lists.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final l = lists[i];
                      return ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: Text(l.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: AppLocalizations.of(context).edit,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                final ctrl = TextEditingController(
                                  text: l.title,
                                );
                                final newTitle = await showDialog<String?>(
                                  context: context,
                                  builder: (dCtx) {
                                    return AlertDialog(
                                      title: Text(
                                        AppLocalizations.of(
                                          context,
                                        ).editListTitle,
                                      ),
                                      content: TextField(
                                        controller: ctrl,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          ).listNameLabel,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dCtx, null),
                                          child: Text(
                                            AppLocalizations.of(context).cancel,
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            final t = ctrl.text.trim();
                                            Navigator.pop(
                                              dCtx,
                                              t.isEmpty ? null : t,
                                            );
                                          },
                                          child: Text(
                                            AppLocalizations.of(context).save,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (newTitle != null && newTitle != l.title) {
                                  await _listRepo.updateList(
                                    AppList(id: l.id, title: newTitle),
                                  );
                                  setStateSheet(() {});
                                }
                              },
                            ),
                            IconButton(
                              tooltip: AppLocalizations.of(context).delete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                // Ask cascade option
                                bool cascadeHabits = true;
                                bool cascadeTasks = true;
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dCtx) {
                                    return StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return AlertDialog(
                                          title: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).deleteListTitle,
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).deleteListMessage,
                                              ),
                                              const SizedBox(height: 8),
                                              CheckboxListTile(
                                                contentPadding: EdgeInsets.zero,
                                                value: cascadeHabits,
                                                onChanged: (v) =>
                                                    setStateDialog(
                                                      () => cascadeHabits =
                                                          v ?? true,
                                                    ),
                                                title: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).unassignLinkedHabits,
                                                ),
                                              ),
                                              CheckboxListTile(
                                                contentPadding: EdgeInsets.zero,
                                                value: cascadeTasks,
                                                onChanged: (v) =>
                                                    setStateDialog(
                                                      () => cascadeTasks =
                                                          v ?? true,
                                                    ),
                                                title: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  ).unassignLinkedDailyTasks,
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dCtx, false),
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).cancel,
                                              ),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(dCtx, true),
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).delete,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                                if (confirmed != true) return;
                                // Unassign linked habits/tasks if requested
                                if (cascadeHabits) {
                                  for (final h in _repo.habits.where(
                                    (h) => h.listId == l.id,
                                  )) {
                                    await _repo.assignHabitToList(h.id, null);
                                  }
                                }
                                if (cascadeTasks) {
                                  for (final t in _taskRepo.allTasks.where(
                                    (t) => t.listId == l.id,
                                  )) {
                                    await _taskRepo.assignTaskToList(
                                      t.id,
                                      null,
                                    );
                                  }
                                }
                                await _listRepo.removeList(l.id);
                                if (mounted) setStateSheet(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: Text(AppLocalizations.of(context).close),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            final res = await showDialog<Map<String, dynamic>>(
                              context: context,
                              builder: (context) => const ListCreationDialog(),
                            );
                            if (res != null &&
                                (res['title'] as String).trim().isNotEmpty) {
                              final list = AppList(
                                id: UniqueKey().toString(),
                                title: (res['title'] as String).trim(),
                              );
                              await _listRepo.addList(list);
                              if (mounted) setStateSheet(() {});
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).listCreatedMessage(list.title),
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context).newList),
                        ),
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

  void _resetFilters() {
    setState(() {
      _selectedTypes = {HabitType.simple, HabitType.numerical, HabitType.timer};
      _completionFilter = CompletionFilter.all;
      _selectedListId = null;
    });
  }

  bool _isHabitCompletedOnSelected(Habit habit) {
    final String dayKey =
        '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selected.year,
      _selected.month,
      _selected.day,
    );
    final bool isToday = _isSameDay(selectedDate, todayDate);
    // Başlangıç tarihinden önce ise tamamlanmış sayılmaz
    final String startDateStr = habit.startDate;
    final DateTime startDate = DateTime(
      int.parse(startDateStr.substring(0, 4)),
      int.parse(startDateStr.substring(5, 7)),
      int.parse(startDateStr.substring(8, 10)),
    );
    final bool isBeforeStart = selectedDate.isBefore(
      DateTime(startDate.year, startDate.month, startDate.day),
    );
    if (isBeforeStart) return false;

    // Today: in-memory completion or explicit log; Other days: explicit log only
    final bool dayCompleted = isToday
        ? (habit.isCompleted ||
              HabitRepository.evaluateCompletionFromLog(habit, dayKey))
        : HabitRepository.evaluateCompletionFromLog(habit, dayKey);
    return dayCompleted;
  }

  bool _matchesCompletionFilter(Habit h) => switch (_completionFilter) {
    CompletionFilter.all => true,
    CompletionFilter.completed => _isHabitCompletedOnSelected(h),
    CompletionFilter.incomplete => !_isHabitCompletedOnSelected(h),
  };

  List<Habit> _filteredHabits() {
    // Only include habits that exist on or after their startDate for the selected day
    final DateTime selectedDate = DateTime(
      _selected.year,
      _selected.month,
      _selected.day,
    );
    return _repo.habits
        .where((h) => _selectedTypes.contains(h.habitType))
        .where(_matchesCompletionFilter)
        .where(
          (h) => _selectedListId == null ? true : h.listId == _selectedListId,
        )
        .where((h) {
          // Parse startDate (YYYY-MM-DD) and hide the habit if selected day is before it
          final s = h.startDate;
          if (s.length >= 10) {
            final sd = DateTime(
              int.parse(s.substring(0, 4)),
              int.parse(s.substring(5, 7)),
              int.parse(s.substring(8, 10)),
            );
            final inStart = !selectedDate.isBefore(
              DateTime(sd.year, sd.month, sd.day),
            );
            if (!inStart) return false;
            // If habit has endDate, hide if selected day is after it
            if (h.endDate != null && h.endDate!.length >= 10) {
              final ed = DateTime(
                int.parse(h.endDate!.substring(0, 4)),
                int.parse(h.endDate!.substring(5, 7)),
                int.parse(h.endDate!.substring(8, 10)),
              );
              if (selectedDate.isAfter(DateTime(ed.year, ed.month, ed.day))) {
                return false;
              }
            }
            // Respect explicit schedule: only show on scheduled dates
            if (h.scheduledDates != null && h.scheduledDates!.isNotEmpty) {
              final key = _dayKeyFromDate(selectedDate);
              if (!h.scheduledDates!.contains(key)) return false;
            }
            return true;
          }
          return true;
        })
        .toList();
  }

  List<DailyTask> _filteredTasksForSelectedDay() {
    final String dayKey =
        '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}';
    // Use carry-over aware retrieval so incomplete tasks from previous days
    // continue to appear until completed.
    final tasks = _taskRepo.tasksForDateWithCarryover(dayKey);
    // Apply list filter only (type filter is for habits). Completion filter affects tasks, too.
    List<DailyTask> listFiltered = _selectedListId == null
        ? tasks
        : tasks.where((t) => t.listId == _selectedListId).toList();
    switch (_completionFilter) {
      case CompletionFilter.all:
        return listFiltered;
      case CompletionFilter.completed:
        return listFiltered.where((t) => t.isDone).toList();
      case CompletionFilter.incomplete:
        return listFiltered.where((t) => !t.isDone).toList();
    }
  }

  /// Groups habits and tasks by their listId for grouped display
  List<_GroupedItem> _buildGroupedItems(
    List<Habit> habits,
    List<DailyTask> tasks,
  ) {
    final items = <_GroupedItem>[];
    final l10n = AppLocalizations.of(context);

    // Get all lists and create a map for quick lookup
    final listsMap = <String, AppList>{};
    for (final l in _listRepo.lists) {
      listsMap[l.id] = l;
    }

    // Collect all unique listIds from habits and tasks
    final listIds = <String?>{};
    for (final h in habits) {
      listIds.add(h.listId);
    }
    for (final t in tasks) {
      listIds.add(t.listId);
    }

    // Sort listIds: named lists first (alphabetically), then null (unlisted) at the end
    final sortedListIds = listIds.toList()
      ..sort((a, b) {
        if (a == null && b == null) return 0;
        if (a == null) return 1; // null goes last
        if (b == null) return -1;
        final aTitle = listsMap[a]?.title ?? '';
        final bTitle = listsMap[b]?.title ?? '';
        return aTitle.compareTo(bTitle);
      });

    // Build grouped items
    for (final listId in sortedListIds) {
      final listHabits = habits.where((h) => h.listId == listId).toList();
      final listTasks = tasks.where((t) => t.listId == listId).toList();

      if (listHabits.isEmpty && listTasks.isEmpty) continue;

      // Add list header
      final listTitle = listId == null
          ? l10n.unlistedItems
          : (listsMap[listId]?.title ?? l10n.unknownList);
      items.add(_ListHeader(listId: listId, title: listTitle));

      // Add tasks first, then habits
      for (final task in listTasks) {
        items.add(_TaskItem(task));
      }
      for (final habit in listHabits) {
        items.add(_HabitItem(habit));
      }
    }

    return items;
  }

  Widget _buildListHeaderWidget(_ListHeader header) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnlisted = header.listId == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlisted
                  ? colorScheme.outline.withOpacity(0.1)
                  : colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUnlisted ? Icons.inbox_outlined : Icons.folder_outlined,
              size: 18,
              color: isUnlisted ? colorScheme.outline : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              header.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isUnlisted ? colorScheme.outline : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCardWidget(DailyTask task) {
    return _TaskCard(
      title: task.title,
      description: task.description,
      isDone: task.isDone,
      listName:
          null, // Don't show list name in grouped view since it's under the header
      onToggleDone: (value) {
        setState(() {
          task.isDone = value;
        });
        _taskRepo.updateTask(task);
      },
      onAssignToList: () => _assignTaskToListDialog(task),
      onEdit: () async {
        final res = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (ctx) => DailyTaskDialog(),
        );
        if (res != null) {
          final newTitle = (res['title'] as String?)?.trim() ?? task.title;
          final newDescription =
              (res['description'] as String?)?.trim() ?? task.description;
          task.title = newTitle;
          task.description = newDescription;
          await _taskRepo.updateTask(task);
        }
      },
      onDelete: () async {
        final confirmed = await _confirmDelete(
          title: AppLocalizations.of(context).delete,
          message:
              '${AppLocalizations.of(context).deleteTaskConfirmTitle}\n\n${AppLocalizations.of(context).deleteTaskConfirmMessage}',
          confirmText: AppLocalizations.of(context).delete,
          cancelText: AppLocalizations.of(context).cancel,
        );
        if (confirmed) {
          await _taskRepo.removeTask(task.id);
        }
      },
    );
  }

  Widget _buildHabitCardWidget(Habit habit) {
    final String dayKey =
        '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}';
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selected.year,
      _selected.month,
      _selected.day,
    );
    final bool isToday = _isSameDay(selectedDate, todayDate);
    final bool isFuture = selectedDate.isAfter(todayDate);

    final String startDateStr = habit.startDate;
    final DateTime startDate = DateTime(
      int.parse(startDateStr.substring(0, 4)),
      int.parse(startDateStr.substring(5, 7)),
      int.parse(startDateStr.substring(8, 10)),
    );
    final bool isBeforeStart = selectedDate.isBefore(
      DateTime(startDate.year, startDate.month, startDate.day),
    );

    final int dayProgress = isToday
        ? habit.currentStreak
        : (habit.dailyLog[dayKey] ?? 0);
    final bool dayCompleted = isToday
        ? (habit.isCompleted ||
              HabitRepository.evaluateCompletionFromLog(habit, dayKey))
        : HabitRepository.evaluateCompletionFromLog(habit, dayKey);
    final int missedBefore = _consecutiveMissedDaysBefore(
      habit,
      selectedDate,
      cap: 7,
    );

    return HabitCard(
      title: habit.title,
      description: _buildHabitSubtitle(habit),
      icon: habit.icon,
      emoji: habit.emoji,
      categoryName: habit.categoryName,
      color: habit.color,
      currentStreak: dayProgress,
      streakCount: HabitRepository.instance.consecutiveStreak(
        habit.id,
        upTo: selectedDate,
      ),
      targetCount: habit.targetCount,
      isCompleted: dayCompleted,
      habitType: habit.habitType,
      numericalTargetType: habit.habitType == HabitType.numerical
          ? habit.numericalTargetType
          : null,
      timerTargetType: habit.habitType == HabitType.timer
          ? habit.timerTargetType
          : null,
      unit: habit.unit,
      readOnly: isFuture || isBeforeStart,
      iceEnabled:
          !isFuture && !isBeforeStart && habit.habitType == HabitType.simple,
      requiredBreakTaps: missedBefore,
      onTap: () {
        if (isFuture || isBeforeStart) return;
        if (habit.habitType == HabitType.simple) {
          if (isToday) {
            _repo.toggleSimple(habit.id);
          } else {
            _repo.toggleSimpleForDate(habit.id, _selected);
          }
        }
      },
      onAssignToList: () => _assignHabitToListDialog(habit),
      showStreakIndicator: _repo.getShowStreakIndicatorFor(habit.id),
      onToggleStreakIndicator: (v) async {
        await _repo.setShowStreakIndicatorFor(habit.id, v);
      },
      onValueUpdate: (newValue) {
        if (isFuture || isBeforeStart) return;
        if (habit.habitType == HabitType.numerical ||
            habit.habitType == HabitType.timer) {
          if (isToday) {
            _repo.setManualProgress(habit.id, newValue);
          } else {
            _repo.setManualProgressForDate(habit.id, _selected, newValue);
          }
        }
      },
      onAnalyze: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HabitAnalysisScreen(
              habitTitle: habit.title,
              habitDescription: habit.description,
              habitIcon: habit.icon,
              habitColor: habit.color,
              currentStreak: habit.currentStreak,
              targetCount: habit.targetCount,
              unit: habit.unit,
              habitId: habit.id,
            ),
          ),
        );
      },
      onEdit: () => _editHabit(habit),
      onDelete: () => _deleteHabit(habit),
    );
  }

  Future<void> _editHabit(Habit habit) async {
    // Vision habits: edit with AdvancedHabitScreen (vision context)
    if (habit.linkedVisionId != null) {
      final visionRepo = VisionRepository.instance;
      await visionRepo.initialize();
      final visions = await visionRepo.stream.first;
      final vision = visions.cast<Vision?>().firstWhere(
        (v) => v?.id == habit.linkedVisionId,
        orElse: () => null,
      );
      if (vision != null) {
        final result = await Navigator.of(context).push<Map<String, dynamic>>(
          MaterialPageRoute(
            builder: (context) => AdvancedHabitScreen(
              editingHabitMap: {
                'id': habit.id,
                'title': habit.title,
                'description': habit.description,
                'icon': habit.icon,
                'color': habit.color,
                'targetCount': habit.targetCount,
                'habitType': habit.habitType,
                'unit': habit.unit,
                if (habit.emoji != null) 'emoji': habit.emoji,
                'numericalTargetType': habit.numericalTargetType,
                'timerTargetType': habit.timerTargetType,
                'startDate': habit.startDate,
                'endDate': habit.endDate,
                if (habit.scheduledDates != null)
                  'scheduledDates': habit.scheduledDates,
                'reminderEnabled': habit.reminderEnabled,
                if (habit.reminderTime != null)
                  'reminderTime': {
                    'hour': habit.reminderTime!.hour,
                    'minute': habit.reminderTime!.minute,
                  },
                'visionId': vision.id,
                'visionStartDate': vision.startDate,
                'visionEndDate': vision.endDate,
              },
              useVisionDayOffsets: true,
              returnAsMap: true,
            ),
          ),
        );
        if (result != null) {
          _applyHabitEditResult(habit, result);
        }
      }
      return;
    }

    // Simple habit type
    if (habit.habitType == HabitType.simple && !habit.isAdvanced) {
      final editedHabit = await Navigator.of(context).push<Habit>(
        MaterialPageRoute(
          builder: (context) => SimpleHabitScreen(existingHabit: habit),
        ),
      );
      if (editedHabit != null) {
        habit.title = editedHabit.title;
        habit.description = editedHabit.description;
        habit.emoji = editedHabit.emoji;
        habit.color = editedHabit.color;
        habit.frequency = editedHabit.frequency;
        habit.frequencyType = editedHabit.frequencyType;
        habit.selectedWeekdays = editedHabit.selectedWeekdays;
        habit.selectedMonthDays = editedHabit.selectedMonthDays;
        habit.selectedYearDays = editedHabit.selectedYearDays;
        habit.periodicDays = editedHabit.periodicDays;
        habit.scheduledDates = editedHabit.scheduledDates;
        habit.reminderEnabled = editedHabit.reminderEnabled;
        habit.reminderTime = editedHabit.reminderTime;
        await _repo.updateHabit(habit);
      }
      return;
    }

    // Advanced habit - Habit objesi döndür
    final editedHabit = await Navigator.of(context).push<Habit>(
      MaterialPageRoute(
        builder: (context) => AdvancedHabitScreen(existingHabit: habit),
      ),
    );
    if (editedHabit != null) {
      habit.title = editedHabit.title;
      habit.description = editedHabit.description;
      habit.color = editedHabit.color;
      habit.emoji = editedHabit.emoji;
      habit.habitType = editedHabit.habitType;
      habit.targetCount = editedHabit.targetCount;
      habit.unit = editedHabit.unit;
      habit.numericalTargetType = editedHabit.numericalTargetType;
      habit.timerTargetType = editedHabit.timerTargetType;
      habit.frequency = editedHabit.frequency;
      habit.frequencyType = editedHabit.frequencyType;
      habit.selectedWeekdays = editedHabit.selectedWeekdays;
      habit.selectedMonthDays = editedHabit.selectedMonthDays;
      habit.selectedYearDays = editedHabit.selectedYearDays;
      habit.periodicDays = editedHabit.periodicDays;
      habit.scheduledDates = editedHabit.scheduledDates;
      habit.reminderEnabled = editedHabit.reminderEnabled;
      habit.reminderTime = editedHabit.reminderTime;
      await _repo.updateHabit(habit);
    }
  }

  void _applyHabitEditResult(Habit habit, Map<String, dynamic> result) {
    habit.title = (result['title'] ?? habit.title) as String;
    habit.description = (result['description'] ?? habit.description) as String;
    if (result['color'] is int) {
      habit.color = Color(result['color'] as int);
    } else if (result['color'] is Color) {
      habit.color = result['color'] as Color;
    }
    if (result['emoji'] is String &&
        (result['emoji'] as String).trim().isNotEmpty) {
      habit.emoji = (result['emoji'] as String).trim();
    }
    if (result['frequency'] is String) {
      final f = (result['frequency'] as String).trim();
      habit.frequency = f.isEmpty ? null : f;
    }
    if (result['frequencyType'] != null) {
      habit.frequencyType = result['frequencyType']?.toString();
    }

    if (result['targetCount'] is int) {
      habit.targetCount = result['targetCount'] as int;
    }
    if (result['unit'] is String) {
      habit.unit = result['unit'] as String;
    }
    if (result['habitType'] is HabitType) {
      habit.habitType = result['habitType'] as HabitType;
    }
    if (result['numericalTargetType'] is NumericalTargetType) {
      habit.numericalTargetType =
          result['numericalTargetType'] as NumericalTargetType;
    }
    if (result['timerTargetType'] is TimerTargetType) {
      habit.timerTargetType = result['timerTargetType'] as TimerTargetType;
    }
    if (result['scheduledDates'] is List) {
      habit.scheduledDates = List<String>.from(result['scheduledDates']);
    }
    if (result['startDate'] is String) {
      habit.startDate = result['startDate'] as String;
    }
    if (result['endDate'] is String?) {
      habit.endDate = result['endDate'] as String?;
    }

    _repo.updateHabit(habit);
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await _confirmDelete(
      title: AppLocalizations.of(context).delete,
      message: AppLocalizations.of(context).deleteHabitConfirm(habit.title),
      confirmText: AppLocalizations.of(context).delete,
      cancelText: AppLocalizations.of(context).cancel,
    );
    if (confirmed) {
      _repo.removeHabit(habit.id);
    }
  }

  String _buildHabitSubtitle(Habit habit) {
    // Only show the habit's own description; do not append the list title.
    return habit.description;
  }

  Future<void> _assignHabitToListDialog(Habit habit) async {
    // show dialog with list options + create new
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear_all_outlined),
                title: Text(AppLocalizations.of(context).removeFromList),
                onTap: () => Navigator.pop(context, ''),
              ),
              const Divider(height: 1),
              ..._listRepo.lists.map(
                (l) => ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(l.title),
                  trailing: habit.listId == l.id
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => Navigator.pop(context, l.id),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_outlined),
                title: Text(AppLocalizations.of(context).createNewList),
                onTap: () async {
                  final res = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ListCreationDialog(),
                  );
                  if (res != null &&
                      (res['title'] as String).trim().isNotEmpty) {
                    final list = AppList(
                      id: UniqueKey().toString(),
                      title: (res['title'] as String).trim(),
                    );
                    await _listRepo.addList(list);
                    if (!mounted) return;
                    Navigator.pop(context, list.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    final listId = selected.isEmpty ? null : selected;
    await _repo.assignHabitToList(habit.id, listId);
  }

  Future<void> _assignTaskToListDialog(DailyTask task) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear_all_outlined),
                title: Text(AppLocalizations.of(context).removeFromList),
                onTap: () => Navigator.pop(context, ''),
              ),
              const Divider(height: 1),
              ..._listRepo.lists.map(
                (l) => ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(l.title),
                  trailing: task.listId == l.id
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => Navigator.pop(context, l.id),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add_outlined),
                title: Text(AppLocalizations.of(context).createNewList),
                onTap: () async {
                  final res = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => const ListCreationDialog(),
                  );
                  if (res != null &&
                      (res['title'] as String).trim().isNotEmpty) {
                    final list = AppList(
                      id: UniqueKey().toString(),
                      title: (res['title'] as String).trim(),
                    );
                    await _listRepo.addList(list);
                    if (!mounted) return;
                    Navigator.pop(context, list.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    final listId = selected.isEmpty ? null : selected;
    await _taskRepo.assignTaskToList(task.id, listId);
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
    String confirmText = 'Sil',
    String cancelText = 'İptal',
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(
        () => _selected = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showDailyTaskDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const DailyTaskDialog(),
    );

    if (result != null) {
      final String title = (result['title'] as String?)?.trim() ?? '';
      final String description =
          (result['description'] as String?)?.trim() ?? '';
      if (title.isEmpty) return;
      final String dayKey =
          '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}';
      final task = DailyTask(
        id: UniqueKey().toString(),
        title: title,
        description: description,
        dateKey: dayKey,
      );
      await _taskRepo.addTask(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).dailyTaskCreatedMessage(task.title),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _navigateToCreateHabit() {
    _showHabitTypeSelectionModal();
  }

  void _showHabitTypeSelectionModal() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Alışkanlık Türü Seç',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nasıl bir alışkanlık oluşturmak istiyorsun?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Simple Habit Option
            _HabitTypeOption(
              icon: Icons.check_circle_outline,
              title: 'Basit Alışkanlık',
              description: 'Günlük yapılacaklar için. Tamamla veya tamamlama.',
              color: colorScheme.primary,
              onTap: () {
                Navigator.pop(context);
                _createSimpleHabit();
              },
            ),
            const SizedBox(height: 12),

            // Advanced Habit Option
            _HabitTypeOption(
              icon: Icons.auto_graph,
              title: 'Gelişmiş Alışkanlık',
              description: 'Sayısal hedefler, zamanlayıcı ve detaylı takip.',
              color: colorScheme.secondary,
              onTap: () {
                Navigator.pop(context);
                _createAdvancedHabit();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _createSimpleHabit() async {
    final habit = await Navigator.of(context).push<Habit>(
      MaterialPageRoute(builder: (context) => const SimpleHabitScreen()),
    );

    if (habit != null && mounted) {
      await _repo.addHabit(habit);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).habitCreatedMessage(habit.title),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  void _createAdvancedHabit() async {
    final habit = await Navigator.of(context).push<Habit>(
      MaterialPageRoute(builder: (context) => const AdvancedHabitScreen()),
    );

    if (habit != null && mounted) {
      habit.isAdvanced = true;
      await _repo.addHabit(habit);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).habitCreatedMessage(habit.title),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  void _showListCreationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ListCreationDialog(),
    );

    if (result != null) {
      final title = (result['title'] as String?)?.trim();
      if (title != null && title.isNotEmpty) {
        final list = AppList(id: UniqueKey().toString(), title: title);
        await _listRepo.addList(list);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Liste oluşturuldu: ${list.title}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Date selector row flush to top
              const SizedBox(height: 0),
              SizedBox(
                height: 48, // reduced from 62
                child: ListView.builder(
                  controller: _dateScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: _monthDays.length,
                  itemBuilder: (context, i) {
                    final day = _monthDays[i];
                    final bool selected = _isSameDay(day, _selected);
                    final bool today = _isSameDay(day, DateTime.now());
                    final scheme = Theme.of(context).colorScheme;
                    // Borderless, solid surfaces with subtle tinting
                    final Color baseBg = scheme.surfaceContainerHighest;
                    final Color unselectedBg = (!selected && today)
                        ? Color.alphaBlend(
                            scheme.primary.withValues(alpha: 0.08),
                            baseBg,
                          )
                        : baseBg;
                    final Color selectedBg = scheme.primaryContainer;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() => _selected = day);
                          // keep selection in view
                          _scrollDateRowToSelected(animate: true);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 40, // reduced from 46
                          decoration: BoxDecoration(
                            color: selected ? selectedBg : unselectedBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ), // further reduced vertical padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _weekdayLabel(context, day.weekday),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10, // slightly smaller
                                      color: selected
                                          ? scheme.onPrimaryContainer
                                          : today
                                          ? scheme.primary
                                          : scheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 2), // reduced from 4
                              Text(
                                '${day.day}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12, // smaller number
                                      color: selected
                                          ? scheme.onPrimaryContainer
                                          : scheme.onSurface,
                                    ),
                              ),
                              if (today && !selected)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 0),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final tasks = _filteredTasksForSelectedDay();
                    final habits = _filteredHabits();
                    if (tasks.isEmpty && habits.isEmpty) {
                      // Show a unified empty state when nothing matches
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_list_off,
                              size: 56,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context).noItemsMatchFilters,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _resetFilters,
                              child: Text(
                                AppLocalizations.of(context).clearFilters,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Reserve space at the bottom so the last card is not obscured by the FAB.
                    // Compute a dynamic bottom inset using MediaQuery to include any system
                    // bottom padding (safe area) plus the typical FAB height and extra margin.
                    final mq = MediaQuery.of(context);
                    final double fabHeight = 56.0; // default FAB size
                    final double extraGap = 24.0; // comfortable breathing room
                    final double bottomReserve =
                        mq.viewPadding.bottom + fabHeight + extraGap;

                    // If no list is selected, show grouped view by list
                    if (_selectedListId == null) {
                      final groupedItems = _buildGroupedItems(habits, tasks);
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: bottomReserve),
                        itemCount: groupedItems.length,
                        itemBuilder: (context, index) {
                          final item = groupedItems[index];
                          return switch (item) {
                            _ListHeader() => _buildListHeaderWidget(item),
                            _TaskItem() => _buildTaskCardWidget(item.task),
                            _HabitItem() => _buildHabitCardWidget(item.habit),
                          };
                        },
                      );
                    }

                    // Otherwise show flat list (existing behavior when a list is selected)
                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: bottomReserve),
                      itemCount:
                          (tasks.isNotEmpty ? (1 + tasks.length) : 0) +
                          (habits.isNotEmpty ? (1 + habits.length) : 0),
                      itemBuilder: (context, index) {
                        int cursor = 0;
                        // Tasks section
                        if (tasks.isNotEmpty) {
                          if (index == cursor) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                              child: Text(
                                AppLocalizations.of(context).dailyTasksSection,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            );
                          }
                          cursor += 1;
                          if (index < cursor + tasks.length) {
                            final task = tasks[index - cursor];
                            // Swipe-to-dismiss removed: present task card directly.
                            return _TaskCard(
                              title: task.title,
                              description: task.description,
                              isDone: task.isDone,
                              listName: task.listId == null
                                  ? null
                                  : _listRepo.lists
                                        .firstWhere(
                                          (l) => l.id == task.listId,
                                          orElse: () =>
                                              AppList(id: '', title: ''),
                                        )
                                        .title,
                              onToggleDone: (value) {
                                setState(() {
                                  task.isDone = value;
                                });
                                // Persist in background to avoid UI lag
                                _taskRepo.updateTask(task);
                              },
                              onAssignToList: () =>
                                  _assignTaskToListDialog(task),
                              onEdit: () async {
                                // Prefill edit dialog using same DailyTaskDialog
                                final res =
                                    await showDialog<Map<String, dynamic>>(
                                      context: context,
                                      builder: (ctx) => DailyTaskDialog(),
                                    );
                                if (res != null) {
                                  final newTitle =
                                      (res['title'] as String?)?.trim() ??
                                      task.title;
                                  final newDescription =
                                      (res['description'] as String?)?.trim() ??
                                      task.description;
                                  task.title = newTitle;
                                  task.description = newDescription;
                                  await _taskRepo.updateTask(task);
                                }
                              },
                              onDelete: () async {
                                final confirmed = await _confirmDelete(
                                  title: AppLocalizations.of(context).delete,
                                  // use the message variant from generated localizations;
                                  // interpolate the task title into the message where helpful
                                  message:
                                      '${AppLocalizations.of(context).deleteTaskConfirmTitle}\n\n${AppLocalizations.of(context).deleteTaskConfirmMessage}',
                                  confirmText: AppLocalizations.of(
                                    context,
                                  ).delete,
                                  cancelText: AppLocalizations.of(
                                    context,
                                  ).cancel,
                                );
                                if (confirmed) {
                                  await _taskRepo.removeTask(task.id);
                                }
                              },
                            );
                          }
                          cursor += tasks.length;
                        }

                        // Habits section header
                        if (habits.isNotEmpty) {
                          if (index == cursor) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                              child: Text(
                                AppLocalizations.of(context).habitsSection,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            );
                          }
                          cursor += 1;
                          if (index < cursor + habits.length) {
                            final habit = habits[index - cursor];
                            final String dayKey =
                                '${_selected.year}-${_selected.month.toString().padLeft(2, '0')}-${_selected.day.toString().padLeft(2, '0')}';
                            final now = DateTime.now();
                            final todayDate = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            final selectedDate = DateTime(
                              _selected.year,
                              _selected.month,
                              _selected.day,
                            );
                            final bool isToday = _isSameDay(
                              selectedDate,
                              todayDate,
                            );
                            final bool isFuture = selectedDate.isAfter(
                              todayDate,
                            );
                            // Başlangıç tarihinden önce düzenlemeyi engelle
                            final String startDateStr = habit.startDate;
                            final DateTime startDate = DateTime(
                              int.parse(startDateStr.substring(0, 4)),
                              int.parse(startDateStr.substring(5, 7)),
                              int.parse(startDateStr.substring(8, 10)),
                            );
                            final bool isBeforeStart = selectedDate.isBefore(
                              DateTime(
                                startDate.year,
                                startDate.month,
                                startDate.day,
                              ),
                            );
                            // Progress value to display on the card
                            final int dayProgress = isToday
                                ? habit.currentStreak
                                : (habit.dailyLog[dayKey] ?? 0);
                            final bool dayCompleted = isToday
                                ? (habit.isCompleted ||
                                      HabitRepository.evaluateCompletionFromLog(
                                        habit,
                                        dayKey,
                                      ))
                                : HabitRepository.evaluateCompletionFromLog(
                                    habit,
                                    dayKey,
                                  );
                            // Ice mechanic: number of missed days prior to selected
                            final int missedBefore =
                                _consecutiveMissedDaysBefore(
                                  habit,
                                  selectedDate,
                                  cap: 7,
                                );
                            // Swipe-to-dismiss removed: present HabitCard directly.
                            return HabitCard(
                              title: habit.title,
                              description: _buildHabitSubtitle(habit),
                              icon: habit.icon,
                              emoji: habit.emoji,
                              categoryName: habit.categoryName,
                              color: habit.color,
                              currentStreak: dayProgress,
                              streakCount: HabitRepository.instance
                                  .consecutiveStreak(
                                    habit.id,
                                    upTo: selectedDate,
                                  ),
                              targetCount: habit.targetCount,
                              isCompleted: dayCompleted,
                              habitType: habit.habitType,
                              numericalTargetType:
                                  habit.habitType == HabitType.numerical
                                  ? habit.numericalTargetType
                                  : null,
                              timerTargetType:
                                  habit.habitType == HabitType.timer
                                  ? habit.timerTargetType
                                  : null,
                              unit: habit.unit,
                              readOnly:
                                  isFuture ||
                                  isBeforeStart, // gelecek veya başlangıçtan önce günler kilitli
                              iceEnabled:
                                  !isFuture &&
                                  !isBeforeStart &&
                                  habit.habitType == HabitType.simple,
                              requiredBreakTaps: missedBefore,
                              onTap: () {
                                if (isFuture || isBeforeStart) return;
                                if (habit.habitType == HabitType.simple) {
                                  if (isToday) {
                                    _repo.toggleSimple(habit.id);
                                  } else {
                                    _repo.toggleSimpleForDate(
                                      habit.id,
                                      _selected,
                                    );
                                  }
                                }
                              },
                              onAssignToList: () =>
                                  _assignHabitToListDialog(habit),
                              showStreakIndicator: _repo
                                  .getShowStreakIndicatorFor(habit.id),
                              onToggleStreakIndicator: (v) async {
                                await _repo.setShowStreakIndicatorFor(
                                  habit.id,
                                  v,
                                );
                              },
                              onValueUpdate: (newValue) {
                                if (isFuture || isBeforeStart) return;
                                if (habit.habitType == HabitType.numerical ||
                                    habit.habitType == HabitType.timer) {
                                  if (isToday) {
                                    _repo.setManualProgress(habit.id, newValue);
                                  } else {
                                    _repo.setManualProgressForDate(
                                      habit.id,
                                      _selected,
                                      newValue,
                                    );
                                  }
                                }
                              },
                              onAnalyze: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => HabitAnalysisScreen(
                                      habitTitle: habit.title,
                                      habitDescription: habit.description,
                                      habitIcon: habit.icon,
                                      habitColor: habit.color,
                                      currentStreak: habit.currentStreak,
                                      targetCount: habit.targetCount,
                                      unit: habit.unit,
                                      habitId: habit.id,
                                    ),
                                  ),
                                );
                              },
                              onEdit: () async {
                                print(
                                  '🎯 [HabitScreen] onEdit called for: ${habit.title}',
                                );
                                print('   habitType: ${habit.habitType}');
                                print('   isAdvanced: ${habit.isAdvanced}');
                                print(
                                  '   linkedVisionId: ${habit.linkedVisionId}',
                                );

                                // Vision habits: edit with AdvancedHabitScreen (vision context)
                                if (habit.linkedVisionId != null) {
                                  print(
                                    '🔍 [HabitScreen] Editing vision habit: ${habit.title}',
                                  );
                                  print(
                                    '   linkedVisionId: ${habit.linkedVisionId}',
                                  );

                                  final visionRepo = VisionRepository.instance;
                                  // Ensure repository is initialized
                                  await visionRepo.initialize();

                                  // Find vision from stream
                                  final visions = await visionRepo.stream.first;
                                  print(
                                    '   Available visions: ${visions.length}',
                                  );
                                  for (final v in visions) {
                                    print('     - ${v.title} (${v.id})');
                                  }

                                  final vision = visions
                                      .cast<Vision?>()
                                      .firstWhere(
                                        (v) => v?.id == habit.linkedVisionId,
                                        orElse: () => null,
                                      );

                                  if (vision != null) {
                                    print('   ✅ Vision found: ${vision.title}');
                                    // Prepare editing map for AdvancedHabitScreen
                                    final result = await Navigator.of(context)
                                        .push<Map<String, dynamic>>(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdvancedHabitScreen(
                                                  useVisionDayOffsets: true,
                                                  returnAsMap: true,
                                                  editingHabitMap: {
                                                    'id': habit.id,
                                                    'title': habit.title,
                                                    'description':
                                                        habit.description,
                                                    'icon': habit.icon,
                                                    'color': habit.color,
                                                    'targetCount':
                                                        habit.targetCount,
                                                    'habitType':
                                                        habit.habitType,
                                                    'unit': habit.unit,
                                                    'currentStreak':
                                                        habit.currentStreak,
                                                    'isCompleted':
                                                        habit.isCompleted,
                                                    'startDate':
                                                        habit.startDate,
                                                    'endDate': habit.endDate,
                                                    if (habit.scheduledDates !=
                                                        null)
                                                      'scheduledDates':
                                                          habit.scheduledDates,
                                                    'numericalTargetType': habit
                                                        .numericalTargetType,
                                                    'timerTargetType':
                                                        habit.timerTargetType,
                                                    if (habit.emoji != null)
                                                      'emoji': habit.emoji,
                                                    if (habit.frequency != null)
                                                      'frequency':
                                                          habit.frequency,
                                                    if (habit.frequencyType !=
                                                        null)
                                                      'frequencyType':
                                                          habit.frequencyType,
                                                    if (habit
                                                            .selectedWeekdays !=
                                                        null)
                                                      'selectedWeekdays': habit
                                                          .selectedWeekdays,
                                                    if (habit
                                                            .selectedMonthDays !=
                                                        null)
                                                      'selectedMonthDays': habit
                                                          .selectedMonthDays,
                                                    if (habit
                                                            .selectedYearDays !=
                                                        null)
                                                      'selectedYearDays': habit
                                                          .selectedYearDays,
                                                    if (habit.periodicDays !=
                                                        null)
                                                      'periodicDays':
                                                          habit.periodicDays,
                                                    'reminderEnabled':
                                                        habit.reminderEnabled,
                                                    if (habit.reminderTime !=
                                                        null)
                                                      'reminderTime': {
                                                        'hour': habit
                                                            .reminderTime!
                                                            .hour,
                                                        'minute': habit
                                                            .reminderTime!
                                                            .minute,
                                                      },
                                                    // Vision-specific context
                                                    'visionId': vision.id,
                                                    'visionStartDate':
                                                        vision.startDate,
                                                    'visionEndDate':
                                                        vision.endDate,
                                                  },
                                                ),
                                          ),
                                        );

                                    if (result != null) {
                                      // Apply updates to habit
                                      habit.title =
                                          (result['title'] ?? habit.title)
                                              as String;
                                      habit.description =
                                          (result['description'] ??
                                                  habit.description)
                                              as String;
                                      if (result['color'] is int) {
                                        habit.color = Color(
                                          result['color'] as int,
                                        );
                                      } else if (result['color'] is Color) {
                                        habit.color = result['color'] as Color;
                                      }
                                      if (result['emoji'] is String &&
                                          (result['emoji'] as String)
                                              .trim()
                                              .isNotEmpty) {
                                        habit.emoji =
                                            (result['emoji'] as String).trim();
                                      }
                                      if (result['frequency'] is String) {
                                        final f =
                                            (result['frequency'] as String)
                                                .trim();
                                        habit.frequency = f.isEmpty ? null : f;
                                      }
                                      if (result['frequencyType'] != null) {
                                        habit.frequencyType =
                                            result['frequencyType']?.toString();
                                      }
                                      if (result['selectedWeekdays'] is List) {
                                        habit.selectedWeekdays =
                                            (result['selectedWeekdays'] as List)
                                                .whereType<num>()
                                                .map((e) => e.toInt())
                                                .toList();
                                      }
                                      if (result['selectedMonthDays'] is List) {
                                        habit.selectedMonthDays =
                                            (result['selectedMonthDays']
                                                    as List)
                                                .whereType<num>()
                                                .map((e) => e.toInt())
                                                .toList();
                                      }
                                      if (result['selectedYearDays'] is List) {
                                        habit.selectedYearDays =
                                            (result['selectedYearDays'] as List)
                                                .map(
                                                  (e) => e
                                                      .toString()
                                                      .split('T')
                                                      .first,
                                                )
                                                .toList();
                                      }
                                      if (result['periodicDays'] != null) {
                                        habit.periodicDays =
                                            (result['periodicDays'] as num?)
                                                ?.toInt();
                                      }
                                      if (result['scheduledDates'] is List) {
                                        habit.scheduledDates =
                                            (result['scheduledDates'] as List)
                                                .map(
                                                  (e) => e
                                                      .toString()
                                                      .split('T')
                                                      .first,
                                                )
                                                .toList();
                                      }
                                      // Update reminder settings
                                      if (result.containsKey(
                                        'reminderEnabled',
                                      )) {
                                        habit.reminderEnabled =
                                            (result['reminderEnabled']
                                                as bool?) ??
                                            false;
                                      }
                                      if (result['reminderTime'] is Map) {
                                        final rt =
                                            result['reminderTime'] as Map;
                                        final hour = rt['hour'] as int?;
                                        final minute = rt['minute'] as int?;
                                        if (hour != null && minute != null) {
                                          habit.reminderTime = TimeOfDay(
                                            hour: hour,
                                            minute: minute,
                                          );
                                        }
                                      } else if (result['reminderTime'] ==
                                          null) {
                                        habit.reminderTime = null;
                                      }
                                      await _repo.updateHabit(habit);
                                    }
                                    return;
                                  } else {
                                    print(
                                      '   ❌ Vision not found for ID: ${habit.linkedVisionId}',
                                    );
                                    // Vision bulunamadı, normal düzenlemeye geç
                                  }
                                }

                                // If it's a simple non-advanced habit, edit in basic screen
                                if (habit.habitType == HabitType.simple &&
                                    !habit.isAdvanced) {
                                  final editedHabit =
                                      await Navigator.of(context).push<Habit>(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SimpleHabitScreen(
                                                existingHabit: habit,
                                              ),
                                        ),
                                      );
                                  if (editedHabit != null) {
                                    // SimpleHabitScreen döndürdüğü Habit'ten değerleri kopyala
                                    habit.title = editedHabit.title;
                                    habit.description = editedHabit.description;
                                    habit.emoji = editedHabit.emoji;
                                    habit.color = editedHabit.color;
                                    habit.frequency = editedHabit.frequency;
                                    habit.frequencyType =
                                        editedHabit.frequencyType;
                                    habit.selectedWeekdays =
                                        editedHabit.selectedWeekdays;
                                    habit.selectedMonthDays =
                                        editedHabit.selectedMonthDays;
                                    habit.selectedYearDays =
                                        editedHabit.selectedYearDays;
                                    habit.periodicDays =
                                        editedHabit.periodicDays;
                                    habit.scheduledDates =
                                        editedHabit.scheduledDates;
                                    habit.reminderEnabled =
                                        editedHabit.reminderEnabled;
                                    habit.reminderTime =
                                        editedHabit.reminderTime;
                                    await _repo.updateHabit(habit);
                                  }
                                  return;
                                }
                                // Otherwise use advanced habit screen
                                final editedHabit = await Navigator.of(context)
                                    .push<Habit>(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdvancedHabitScreen(
                                              existingHabit: habit,
                                            ),
                                      ),
                                    );
                                if (editedHabit != null) {
                                  habit.title = editedHabit.title;
                                  habit.description = editedHabit.description;
                                  habit.color = editedHabit.color;
                                  habit.emoji = editedHabit.emoji;
                                  habit.habitType = editedHabit.habitType;
                                  habit.targetCount = editedHabit.targetCount;
                                  habit.unit = editedHabit.unit;
                                  habit.numericalTargetType =
                                      editedHabit.numericalTargetType;
                                  habit.timerTargetType =
                                      editedHabit.timerTargetType;
                                  habit.frequency = editedHabit.frequency;
                                  habit.frequencyType =
                                      editedHabit.frequencyType;
                                  habit.selectedWeekdays =
                                      editedHabit.selectedWeekdays;
                                  habit.selectedMonthDays =
                                      editedHabit.selectedMonthDays;
                                  habit.selectedYearDays =
                                      editedHabit.selectedYearDays;
                                  habit.periodicDays = editedHabit.periodicDays;
                                  habit.scheduledDates =
                                      editedHabit.scheduledDates;
                                  habit.reminderEnabled =
                                      editedHabit.reminderEnabled;
                                  habit.reminderTime = editedHabit.reminderTime;
                                  await _repo.updateHabit(habit);
                                }
                              },
                              onDelete: () {
                                final removed = habit;
                                _repo.removeHabit(habit.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).habitDeletedMessage(habit.title),
                                    ),
                                    action: SnackBarAction(
                                      label: AppLocalizations.of(context).undo,
                                      onPressed: () {
                                        _repo.insertHabit(index, removed);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                        // Fallback (should not hit)
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Repository dinleyicisi setState ile çalıştığı için ek gizli AnimatedBuilder'a gerek yok

          // Dark overlay when FAB is expanded
          if (_isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isFabExpanded = false),
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
        ],
      ),
      floatingActionButton: FabMenu(
        isExpanded: _isFabExpanded,
        onToggle: (expanded) => setState(() => _isFabExpanded = expanded),
        onDailyTaskPressed: _showDailyTaskDialog,
        onHabitPressed: _navigateToCreateHabit,
        onListPressed: _showListCreationDialog,
      ),
    );
  }
}

enum CompletionFilter { all, completed, incomplete }

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.description,
    required this.isDone,
    this.listName,
    required this.onToggleDone,
    this.onEdit,
    this.onAssignToList,
    this.onDelete,
  });

  final String title;
  final String description;
  final bool isDone;
  final String? listName;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback? onEdit;
  final VoidCallback? onAssignToList;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onToggleDone(!isDone),
          onLongPress: () async {
            // show modal menu with Edit / Assign / Delete
            if (onEdit == null && onAssignToList == null && onDelete == null)
              return;
            final l10n = AppLocalizations.of(context);
            final selected = await showModalBottomSheet<String?>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) {
                return SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          ListTile(
                            leading: const Icon(Icons.edit_outlined),
                            title: Text(l10n.edit),
                            onTap: () => Navigator.pop(ctx, 'edit'),
                          ),
                        if (onAssignToList != null)
                          ListTile(
                            leading: const Icon(Icons.playlist_add_outlined),
                            title: Text(l10n.addToList),
                            onTap: () => Navigator.pop(ctx, 'assign'),
                          ),
                        if (onDelete != null)
                          ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.red[600],
                            ),
                            title: Text(
                              l10n.delete,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                            onTap: () => Navigator.pop(ctx, 'delete'),
                          ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                );
              },
            );
            if (selected == 'edit') onEdit?.call();
            if (selected == 'assign') onAssignToList?.call();
            if (selected == 'delete') onDelete?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Symmetric checkbox area
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Checkbox(
                      value: isDone,
                      onChanged: (v) => onToggleDone(v ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + description centered vertically
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                // When there is no description, use a slightly
                                // tighter height so the title sits vertically
                                // centered next to the checkbox.
                                height: description.isEmpty ? 1.02 : null,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Optional list pill
                if (listName != null && listName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      listName!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Alışkanlık türü seçim modalında kullanılan seçenek widget'ı
class _HabitTypeOption extends StatelessWidget {
  const _HabitTypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
