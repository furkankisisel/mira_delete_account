import 'package:flutter/material.dart';
import '../../design_system/theme/theme_variations.dart';
import '../../design_system/tokens/colors.dart';
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
    final l10n = AppLocalizations.of(context);
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
                Expanded(child: DashboardFortuneEggsCard(variant: variant)),
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
          if (variant == ThemeVariant.world)
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.accentPurple,
                  secondary: AppColors.accentPurple,
                ),
              ),
              child: const DashboardVisionCard(),
            )
          else
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
    final bool isWorld = widget.variant == ThemeVariant.world;
    // Purple accent for world panels
    final Color worldPurple = AppColors.accentPurple;
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
      (isWorld ? worldPurple : cs.primary).withValues(alpha: 0.12),
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
                      color: isWorld ? worldPurple : cs.primary,
                    ),
                    const SizedBox(width: 8),
                    _HeaderPill(
                      label: l10n.headerFocusLabel,
                      value: l10n.headerFocusReady,
                      color: isWorld ? worldPurple : cs.tertiary,
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
      height: 145,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.95),
        itemCount: habits.length,
        itemBuilder: (context, i) {
          final h = habits[i];
          return _HabitMiniCard(habit: h);
        },
      ),
    );
  }
}

class _HabitMiniCard extends StatefulWidget {
  const _HabitMiniCard({required this.habit});
  final Habit habit;

  @override
  State<_HabitMiniCard> createState() => _HabitMiniCardState();
}

class _HabitMiniCardState extends State<_HabitMiniCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = _last7Days();
    final status = _last7Statuses(widget.habit, days);
    final doneCount = status.where((v) => v).length;

    final fill = Color.alphaBlend(
      widget.habit.color.withValues(alpha: 0.12),
      theme.colorScheme.surfaceContainerHighest,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HabitAnalysisScreen(
                habitId: widget.habit.id,
                habitTitle: widget.habit.title,
                habitDescription: widget.habit.description,
                habitIcon: widget.habit.icon,
                habitColor: widget.habit.color,
                currentStreak: widget.habit.currentStreak,
                targetCount: widget.habit.targetCount,
                unit: widget.habit.unit,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: fill,
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
                      color: widget.habit.color.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child:
                          (widget.habit.emoji != null &&
                              widget.habit.emoji!.isNotEmpty)
                          ? Text(
                              widget.habit.emoji!,
                              style: const TextStyle(fontSize: 18),
                            )
                          : Icon(
                              widget.habit.icon,
                              color: widget.habit.color,
                              size: 18,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context).streakDays(widget.habit.currentStreak)} • $doneCount/7',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(days.length, (i) {
                  final d = days[i];
                  final done = status[i];
                  final isToday = _isToday(d);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? 0 : 1.5,
                        right: i == days.length - 1 ? 0 : 1.5,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: done
                                  ? widget.habit.color
                                  : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                              border: isToday
                                  ? Border.all(
                                      color: widget.habit.color,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: done
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dayName(d),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: isToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: isToday ? 0.9 : 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
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

  String _dateLabel(DateTime d) => '${d.day}/${d.month}';

  String _dayName(DateTime d) {
    return DateFormat.E(AppLocalizations.of(context).localeName).format(d);
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}
