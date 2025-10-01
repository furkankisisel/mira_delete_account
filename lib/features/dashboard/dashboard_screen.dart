import 'package:flutter/material.dart';
import '../../design_system/theme/theme_variations.dart';
import '../timer/widgets/dashboard_timer_card.dart';
import 'widgets/dashboard_mood_card.dart';
import 'widgets/dashboard_finance_chart_card.dart';
import 'widgets/dashboard_vision_card.dart';
import 'widgets/dashboard_fortune_eggs_card.dart';
import '../habit/presentation/habit_analysis_screen.dart';
import '../habit/domain/habit_repository.dart';
import '../habit/domain/habit_model.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.variant});
  final ThemeVariant variant;
  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DashboardHeader(variant: variant),
          const SizedBox(height: 16),
          // Top row: Mood card and Fortune Egg card side-by-side
          // Top row: give both cards the same vertical size so they line up visually
          SizedBox(
            // Reduced height so the dashboard row is more compact; eggs will be larger inside
            height: 96,
            child: Row(
              children: [
                Expanded(child: DashboardMoodCard(variant: variant)),
                const SizedBox(width: 12),
                // Make fortune eggs card share available width equally with mood card
                Expanded(child: const DashboardFortuneEggsCard()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DashboardFinanceChartCard(variant: variant),
          const SizedBox(height: 16),
          DashboardTimerCard(variant: variant),
          const SizedBox(height: 16),
          _DashboardHabitCarousel(),
          const SizedBox(height: 16),
          const DashboardVisionCard(),
          const SizedBox(height: 16),
          // ... ileride başka panel kartları eklenecek
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatefulWidget {
  const _DashboardHeader({required this.variant});
  final ThemeVariant variant;

  @override
  State<_DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<_DashboardHeader> {
  final _habitRepo = HabitRepository.instance;

  @override
  void initState() {
    super.initState();
    _habitRepo.initialize();
    _habitRepo.addListener(_onChange);
  }

  @override
  void dispose() {
    _habitRepo.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? l10n.greetingMorning
        : (hour < 18 ? l10n.greetingAfternoon : l10n.greetingEvening);
    final dateStr = DateFormat.yMMMd(l10n.localeName).format(now);

    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final habits = _habitRepo.habits;
    final totalHabits = habits.length;
    final doneHabits = habits
        .where((h) => HabitRepository.evaluateCompletionFromLog(h, todayKey))
        .length;

    final headerFill = Color.alphaBlend(
      cs.primary.withValues(alpha: 0.12),
      cs.surfaceContainerHighest,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: headerFill,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: const Center(
              child: Text('🌟', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(dateStr, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _HeaderPill(
                      label: l10n.headerHabitsLabel,
                      value: '$doneHabits/$totalHabits',
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    _HeaderPill(
                      label: l10n.headerFocusLabel,
                      value: l10n.headerFocusReady,
                      color: cs.tertiary,
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
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHabitCarousel extends StatefulWidget {
  @override
  State<_DashboardHabitCarousel> createState() =>
      _DashboardHabitCarouselState();
}

class _DashboardHabitCarouselState extends State<_DashboardHabitCarousel> {
  final _repo = HabitRepository.instance;

  @override
  void initState() {
    super.initState();
    // Ensure habits are loaded for the dashboard
    _repo.initialize();
    _repo.addListener(_onRepo);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final habits = _repo.habits;
    if (habits.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1.0),
        itemCount: habits.length,
        itemBuilder: (context, i) {
          final h = habits[i];
          return _HabitMiniCard(habit: h);
        },
      ),
    );
  }
}

class _HabitMiniCard extends StatelessWidget {
  const _HabitMiniCard({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _last7Days();
    final status = _last7Statuses(habit, days);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HabitAnalysisScreen(
              habitId: habit.id,
              habitTitle: habit.title,
              habitDescription: habit.description,
              habitIcon: habit.icon,
              habitColor: habit.color,
              currentStreak: habit.currentStreak,
              targetCount: habit.targetCount,
              unit: habit.unit,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            habit.color.withValues(alpha: 0.10),
            theme.colorScheme.surfaceContainerHighest,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: habit.color.withValues(alpha: 0.28),
                  ),
                  child: Center(
                    child: (habit.emoji != null && habit.emoji!.isNotEmpty)
                        ? Text(
                            habit.emoji!,
                            style: const TextStyle(fontSize: 20),
                          )
                        : Icon(habit.icon, color: habit.color),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(days.length, (i) {
                final d = days[i];
                final done = status[i];
                return Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: 18,
                      height: 10,
                      decoration: BoxDecoration(
                        color: done
                            ? habit.color
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _weekdayLabel(context, d),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _last7Days() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  List<bool> _last7Statuses(Habit habit, List<DateTime> days) {
    return days.map((d) {
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return HabitRepository.evaluateCompletionFromLog(habit, key);
    }).toList();
  }

  String _weekdayLabel(BuildContext context, DateTime d) {
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
    // DateTime.weekday: Monday=1 ... Sunday=7
    return labels[d.weekday - 1];
  }
}
