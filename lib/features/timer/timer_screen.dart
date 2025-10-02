import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';
import '../../core/timer/timer_controller.dart';
import '../../design_system/theme/theme_variations.dart';
import '../../design_system/tokens/colors.dart';
import '../habit/domain/habit_repository.dart';
import '../habit/domain/habit_types.dart';
import 'widgets/landscape_timer_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, this.variant});
  final ThemeVariant? variant;
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  final controller = TimerController.instance;
  late TabController _tabController;
  // Countdown inputs
  final _cdHours = TextEditingController(text: '0');
  final _cdMinutes = TextEditingController(text: '0');
  final _cdSeconds = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller.addListener(_onChange);
  }

  @override
  void dispose() {
    controller.removeListener(_onChange);
    _tabController.dispose();
    _cdHours.dispose();
    _cdMinutes.dispose();
    _cdSeconds.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  // Normalize and apply countdown duration
  void _applyCountdown() {
    int h = int.tryParse(_cdHours.text) ?? 0;
    int m = int.tryParse(_cdMinutes.text) ?? 0;
    int s = int.tryParse(_cdSeconds.text) ?? 0;
    if (h < 0) h = 0;
    if (m < 0) m = 0;
    if (s < 0) s = 0;
    m += s ~/ 60;
    s %= 60;
    h += m ~/ 60;
    m %= 60;
    controller.setCountdown(Duration(hours: h, minutes: m, seconds: s));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bool isWorld = widget.variant == ThemeVariant.world;
    final Color accent = isWorld
        ? AppColors
              .accentPurple // World variant now uses mystic purple
        : theme.colorScheme.primary;
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: accent),
        appBarTheme: theme.appBarTheme.copyWith(foregroundColor: accent),
        iconTheme: theme.iconTheme.copyWith(color: accent),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.timerType,
            style: theme.textTheme.titleLarge?.copyWith(color: accent),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.stay_current_landscape),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        LandscapeTimerScreen(variant: widget.variant),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            onTap: (i) {
              if (i == 0) controller.setMode(TimerMode.stopwatch);
              if (i == 1) controller.setMode(TimerMode.countdown);
              if (i == 2) controller.setMode(TimerMode.pomodoro);
            },
            tabs: [
              Tab(text: l10n.timerTabStopwatch),
              Tab(text: l10n.timerTabCountdown),
              Tab(text: l10n.timerTabPomodoro),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStopwatch(context),
            _buildCountdown(context),
            _buildPomodoro(context),
          ],
        ),
      ),
    );
  }

  Widget _timeDisplay(String value, BuildContext context) => FittedBox(
    child: Text(
      value,
      style: Theme.of(
        context,
      ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildStopwatch(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              _buildHabitSelector(),
              const SizedBox(height: 12),
              _timeDisplay(
                controller.formatDuration(controller.elapsed),
                context,
              ),
              if (controller.hasPending)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.timerPendingLabel(
                      controller.formatDuration(controller.pendingDuration),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      controller.isRunning ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(controller.isRunning ? l10n.pause : l10n.start),
                    onPressed: () => controller.isRunning
                        ? controller.pause()
                        : controller.start(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.flag),
                    label: Text(l10n.finish),
                    onPressed: controller.elapsed.inSeconds > 0
                        ? controller.finish
                        : null,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.reset),
                    onPressed: controller.elapsed.inSeconds > 0
                        ? controller.reset
                        : null,
                  ),
                  if (controller.hasPending)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(l10n.save),
                      onPressed: () => _showSaveDialog(),
                    ),
                  if (controller.hasPending)
                    TextButton(
                      onPressed: controller.discardPending,
                      child: Text(l10n.cancel),
                    ),
                  if (controller.sessions.isNotEmpty)
                    TextButton(
                      onPressed: controller.clearHistory,
                      child: Text(l10n.clearHistory),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildHistoryList()),
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rem = controller.countdownRemaining;
    final total = controller.countdownTotal;
    final hasDuration = controller.hasCountdown;
    final progress = hasDuration && total.inSeconds > 0
        ? 1 - (rem.inSeconds / total.inSeconds)
        : 0.0;
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.countdown;
    // Re-derive accent (was only in build root) to avoid undefined reference
    final theme = Theme.of(context);
    final bool isWorld = widget.variant == ThemeVariant.world;
    final Color accent = isWorld
        ? AppColors.accentPurple
        : theme.colorScheme.primary;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              _buildHabitSelector(),
              const SizedBox(height: 12),
              // Simple centered time display for countdown (removed circular progress ring)
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxSide = math.min(constraints.maxWidth, 360.0);
                  final diameter = math.min(180.0, maxSide * 0.6);
                  return SizedBox(
                    width: diameter,
                    height: diameter,
                    child: Center(
                      child: _timeDisplay(
                        controller.formatDuration(rem),
                        context,
                      ),
                    ),
                  );
                },
              ),
              if (hasDuration)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${l10n.totalDuration}: ${controller.formatDuration(total)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!hasDuration) ...[
                const SizedBox(height: 16),
                Text(l10n.timerSetDurationFirst),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isRunning ? l10n.pause : l10n.start),
                    onPressed: !hasDuration
                        ? null
                        : () => isRunning
                              ? controller.pause()
                              : controller.startCountdown(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.flag),
                    label: Text(l10n.finish),
                    onPressed: hasDuration && (rem != total)
                        ? controller.finish
                        : null,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.reset),
                    onPressed: hasDuration ? controller.reset : null,
                  ),
                  if (controller.hasPending)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(l10n.save),
                      onPressed: () => _showSaveDialog(),
                    ),
                  if (controller.hasPending)
                    TextButton(
                      onPressed: controller.discardPending,
                      child: Text(l10n.cancel),
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.settings),
                    onPressed: _showCountdownConfigDialog,
                  ),
                  if (controller.sessions.isNotEmpty)
                    TextButton(
                      onPressed: controller.clearHistory,
                      child: Text(l10n.clearHistory),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildHistoryList()),
      ],
    );
  }

  Widget _buildPomodoro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.pomodoro;
    final phase = controller.pomodoroWorkPhase
        ? l10n.timerPomodoroWorkPhase
        : l10n.timerPomodoroBreakPhase;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              _buildHabitSelector(),
              const SizedBox(height: 12),
              Text(phase, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _timeDisplay(controller.formattedTime, context),
              const SizedBox(height: 8),
              Text(
                l10n.timerPomodoroCompletedWork(
                  controller.pomodoroCompletedWorkSessions,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(isRunning ? l10n.pause : l10n.start),
                    onPressed: () => isRunning
                        ? controller.pause()
                        : controller.startPomodoro(),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.flag),
                    label: Text(l10n.finish),
                    onPressed: controller.finish,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.skip_next),
                    label: Text(l10n.timerPomodoroSkipPhase),
                    onPressed: controller.activeMode == TimerMode.pomodoro
                        ? controller.skipPomodoroPhase
                        : null,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.reset),
                    onPressed: controller.reset,
                  ),
                  if (controller.hasPending)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(l10n.save),
                      onPressed: () => _showSaveDialog(),
                    ),
                  if (controller.hasPending)
                    TextButton(
                      onPressed: controller.discardPending,
                      child: Text(l10n.cancel),
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.settings),
                    onPressed: _showPomodoroConfigDialog,
                  ),
                  if (controller.sessions.isNotEmpty)
                    TextButton(
                      onPressed: controller.clearHistory,
                      child: Text(l10n.clearHistory),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildHistoryList()),
      ],
    );
  }

  Widget _buildHabitSelector() {
    final l10n = AppLocalizations.of(context);
    final repo = HabitRepository.instance;
    final timerHabits = repo.habits
        .where((h) => h.habitType == HabitType.timer)
        .toList();
    if (timerHabits.isEmpty) return const SizedBox.shrink();
    String? activeId = controller.activeTimerHabitId;
    // Eğer mevcut seçili id yoksa ilkini ata (UI açıldığında otomatik)
    if (activeId == null && timerHabits.isNotEmpty) {
      activeId = timerHabits.first.id;
      // Bildirimleri build sırasında tetiklememek için çerçeve sonrasına ertele
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (controller.activeTimerHabitId != activeId) {
          controller.setActiveTimerHabit(activeId);
        }
      });
    }
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: activeId,
            decoration: InputDecoration(
              labelText: l10n.timerHabitLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            items: timerHabits
                .map(
                  (h) => DropdownMenuItem<String>(
                    value: h.id,
                    child: Text(h.title),
                  ),
                )
                .toList(),
            onChanged: (val) {
              controller.setActiveTimerHabit(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    final l10n = AppLocalizations.of(context);
    final sessions = controller.sessions;
    // Derive accent locally (mirrors build & countdown logic) so we can avoid hardcoded green
    final theme = Theme.of(context);
    final bool isWorld = widget.variant == ThemeVariant.world;
    final Color accent = isWorld
        ? AppColors.accentPurple
        : theme.colorScheme.primary;
    if (sessions.isEmpty) {
      return Center(child: Text(l10n.noEntriesYet));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final s = sessions[index];
        final modeLabel = switch (s.mode) {
          TimerMode.stopwatch => l10n.timerTabStopwatch,
          TimerMode.countdown => l10n.timerTabCountdown,
          TimerMode.pomodoro => s.label ?? l10n.timerTabPomodoro,
        };
        final durStr = controller.formatDuration(s.duration);
        final timeStr = _formatDateTimeRange(s.startedAt, s.endedAt);
        return ListTile(
          leading: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                _iconForMode(s.mode),
                // Use accent for assigned sessions instead of hardcoded green
                color: s.assigned ? accent : null,
              ),
              if (s.assigned)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.check_circle, size: 14, color: accent),
                ),
            ],
          ),
          title: Text('$modeLabel - $durStr'),
          subtitle: Text(s.assigned ? '$timeStr\n(${l10n.saved})' : timeStr),
          isThreeLine: s.assigned,
          onTap: () => _onSessionTap(index),
          onLongPress: () {
            // Confirm deletion
            final theme = Theme.of(context);
            final bool isWorld = widget.variant == ThemeVariant.world;
            final Color accentLocal = isWorld
                ? AppColors.accentPurple
                : theme.colorScheme.primary;
            final themed = theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(primary: accentLocal),
            );
            showDialog<void>(
              context: context,
              builder: (ctx) => Theme(
                data: themed,
                child: AlertDialog(
                  title: Text(l10n.delete ?? 'Delete'),
                  content: Text(
                    l10n.deleteEntryConfirm ?? 'Delete this timer entry?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.removeSessionAt(index);
                      },
                      child: Text(
                        l10n.delete ?? 'Delete',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForMode(TimerMode mode) => switch (mode) {
    TimerMode.stopwatch => Icons.timer,
    TimerMode.countdown => Icons.hourglass_bottom,
    TimerMode.pomodoro => Icons.local_fire_department_outlined,
  };

  String _formatDateTimeRange(DateTime start, DateTime end) {
    final date =
        '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    String two(int v) => v.toString().padLeft(2, '0');
    final from = '${two(start.hour)}:${two(start.minute)}:${two(start.second)}';
    final to = '${two(end.hour)}:${two(end.minute)}:${two(end.second)}';
    return '$date  $from → $to';
  }

  void _showSaveDialog() {
    final l10n = AppLocalizations.of(context);
    final repo = HabitRepository.instance;
    final timerHabits = repo.habits
        .where((h) => h.habitType == HabitType.timer)
        .toList();
    if (timerHabits.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerCreateTimerHabitFirst)));
      return;
    }
    String? selectedId =
        controller.activeTimerHabitId ??
        (timerHabits.isNotEmpty ? timerHabits.first.id : null);
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final bool isWorld = widget.variant == ThemeVariant.world;
        final Color accentLocal = isWorld
            ? AppColors.accentPurple
            : theme.colorScheme.primary;
        final themed = theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(primary: accentLocal),
        );
        return Theme(
          data: themed,
          child: AlertDialog(
            title: Text(l10n.timerSaveDurationTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.timerPendingDurationLabel(
                    controller.formatDuration(controller.pendingDuration),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    labelText: l10n.habit,
                    border: const OutlineInputBorder(),
                  ),
                  items: timerHabits
                      .map(
                        (h) =>
                            DropdownMenuItem(value: h.id, child: Text(h.title)),
                      )
                      .toList(),
                  onChanged: (v) => selectedId = v,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedId != null) {
                    await controller.savePendingToHabit(selectedId!);
                    controller.setActiveTimerHabit(selectedId);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSessionTap(int index) {
    final l10n = AppLocalizations.of(context);
    final sessions = controller.sessions;
    if (index < 0 || index >= sessions.length) return;
    final s = sessions[index];
    if (s.assigned) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerSessionAlreadySaved)));
      return;
    }
    final repo = HabitRepository.instance;
    final timerHabits = repo.habits
        .where((h) => h.habitType == HabitType.timer)
        .toList();
    if (timerHabits.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerCreateTimerHabitFirst)));
      return;
    }
    String? selectedId = controller.activeTimerHabitId ?? timerHabits.first.id;
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final bool isWorld = widget.variant == ThemeVariant.world;
        final Color accentLocal = isWorld
            ? AppColors.accentPurple
            : theme.colorScheme.primary;
        final themed = theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(primary: accentLocal),
        );
        return Theme(
          data: themed,
          child: AlertDialog(
            title: Text(l10n.timerSaveSessionTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.duration}: ${controller.formatDuration(s.duration)}',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    labelText: l10n.habit,
                    border: const OutlineInputBorder(),
                  ),
                  items: timerHabits
                      .map(
                        (h) =>
                            DropdownMenuItem(value: h.id, child: Text(h.title)),
                      )
                      .toList(),
                  onChanged: (v) => selectedId = v,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedId != null) {
                    await controller.assignSessionToHabit(index, selectedId!);
                    controller.setActiveTimerHabit(selectedId);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  // Countdown settings popup
  void _showCountdownConfigDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final bool isWorld = widget.variant == ThemeVariant.world;
        final Color accentLocal = isWorld
            ? AppColors.accentPurple
            : theme.colorScheme.primary;
        final themed = theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(primary: accentLocal),
        );
        return Theme(
          data: themed,
          child: AlertDialog(
            title: Text(l10n.countdownConfigureTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _timeField(
                        controller: _cdHours,
                        label: l10n.hours,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _timeField(
                        controller: _cdMinutes,
                        label: l10n.minutes,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _timeField(
                        controller: _cdSeconds,
                        label: l10n.seconds,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _presetButton('1m', minutes: 1),
                    _presetButton('5m', minutes: 5),
                    _presetButton('10m', minutes: 10),
                    _presetButton('25m', minutes: 25),
                    _presetButton('1h', hours: 1),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyCountdown();
                  Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  // Pomodoro settings popup
  void _showPomodoroConfigDialog() {
    final l10n = AppLocalizations.of(context);
    final workCtrl = TextEditingController(
      text: controller.pomodoroWorkDuration.inMinutes.toString(),
    );
    final shortCtrl = TextEditingController(
      text: controller.pomodoroShortBreakDuration.inMinutes.toString(),
    );
    final longCtrl = TextEditingController(
      text: controller.pomodoroLongBreakDuration.inMinutes.toString(),
    );
    final intervalCtrl = TextEditingController(
      text: controller.pomodoroLongBreakInterval.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final bool isWorld = widget.variant == ThemeVariant.world;
        final Color accentLocal = isWorld
            ? AppColors.accentPurple
            : theme.colorScheme.primary;
        final themed = theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(primary: accentLocal),
        );
        return Theme(
          data: themed,
          child: AlertDialog(
            title: Text(l10n.timerPomodoroSettings),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _numberField(workCtrl, l10n.timerPomodoroWorkMinutesLabel),
                  const SizedBox(height: 12),
                  _numberField(
                    shortCtrl,
                    l10n.timerPomodoroShortBreakMinutesLabel,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    longCtrl,
                    l10n.timerPomodoroLongBreakMinutesLabel,
                  ),
                  const SizedBox(height: 12),
                  _numberField(
                    intervalCtrl,
                    l10n.timerPomodoroLongBreakIntervalLabel,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  final w = int.tryParse(workCtrl.text) ?? 25;
                  final s = int.tryParse(shortCtrl.text) ?? 5;
                  final l = int.tryParse(longCtrl.text) ?? 15;
                  final iv = int.tryParse(intervalCtrl.text) ?? 4;
                  controller.setPomodoroConfig(
                    work: Duration(minutes: w),
                    shortBreak: Duration(minutes: s),
                    longBreak: Duration(minutes: l),
                    longBreakInterval: iv,
                  );
                  Navigator.pop(ctx);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _timeField({
    required TextEditingController controller,
    required String label,
  }) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    ),
    onSubmitted: (_) => _applyCountdown(),
  );

  Widget _presetButton(
    String label, {
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) => OutlinedButton(
    onPressed: () {
      _cdHours.text = hours.toString();
      _cdMinutes.text = minutes.toString();
      _cdSeconds.text = seconds.toString();
      setState(() {});
    },
    child: Text(label),
  );

  Widget _numberField(TextEditingController c, String label) => TextField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
