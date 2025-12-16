import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mira/l10n/app_localizations.dart';
import '../domain/habit_repository.dart';
import '../domain/habit_types.dart';
import '../domain/habit_model.dart';

class HabitAnalysisScreen extends StatefulWidget {
  final String habitTitle;
  final String habitDescription;
  final IconData habitIcon;
  final Color habitColor;
  final int currentStreak;
  final int targetCount;
  final String? unit;
  final String? habitId; // repository id (opsiyonel)

  const HabitAnalysisScreen({
    super.key,
    required this.habitTitle,
    required this.habitDescription,
    required this.habitIcon,
    required this.habitColor,
    required this.currentStreak,
    required this.targetCount,
    this.unit,
    this.habitId,
  });

  @override
  State<HabitAnalysisScreen> createState() => _HabitAnalysisScreenState();
}

class _HabitAnalysisScreenState extends State<HabitAnalysisScreen> {
  int _selectedPeriod = 0; // 0: weekly, 1: monthly, 2: yearly, 3: overall
  Habit? _liveHabit;
  final HabitRepository _repo = HabitRepository.instance;
  List<double> _computedWeekly = [];
  List<double> _computedMonthly = []; // last 30 days (%)
  List<double> _computedYearly = []; // last 12 months avg (%)
  List<double> _computedGeneral = []; // monthly avg from start to now
  DateTime _calendarMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  late List<String> weekDays;

  @override
  void initState() {
    super.initState();
    _refreshHabit();
  }

  void _refreshHabit() {
    if (widget.habitId == null) {
      _liveHabit = null;
    } else {
      _liveHabit = _repo.findById(widget.habitId!);
    }
  }

  @override
  void didUpdateWidget(covariant HabitAnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habitId != widget.habitId) {
      _refreshHabit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Canlı veriyi repository'den çek
    if (widget.habitId != null) {
      _liveHabit = _repo.findById(widget.habitId!);
    }
    final HabitType? type = _liveHabit?.habitType;
    final bool isTimer = type == HabitType.timer;

    _buildWeeklyFromDailyLog(isTimer);
    _buildMonthlyFromDailyLog(isTimer);
    _buildYearlyFromDailyLog(isTimer);
    _buildGeneralFromDailyLog(isTimer);

    final l10n = AppLocalizations.of(context);
    weekDays = [
      l10n.weekdaysShortMon,
      l10n.weekdaysShortTue,
      l10n.weekdaysShortWed,
      l10n.weekdaysShortThu,
      l10n.weekdaysShortFri,
      l10n.weekdaysShortSat,
      l10n.weekdaysShortSun,
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.habitTitle} • ${l10n.analysis}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Use a stronger surfaceVariant in dark mode so the card separates
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorScheme.surfaceVariant.withValues(alpha: 0.18)
                    : widget.habitColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? widget.habitColor.withValues(alpha: 0.40)
                      : widget.habitColor.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? widget.habitColor.withValues(alpha: 0.30)
                          : widget.habitColor.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.habitIcon,
                      color: widget.habitColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.habitTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.habitColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.habitDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Genel takvim ve seri widget'ları (üst bölüm)
            _buildGeneralCalendar(withNav: true),
            const SizedBox(height: 12),
            _buildStreakRow(),

            const SizedBox(height: 16),

            // Zaman aralığı seçici (seri altı)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? colorScheme.outlineVariant.withValues(alpha: 0.60)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildPeriodButton(l10n.weekly, 0)),
                  Expanded(child: _buildPeriodButton(l10n.monthly, 1)),
                  Expanded(child: _buildPeriodButton(l10n.yearly, 2)),
                  Expanded(child: _buildPeriodButton(l10n.overall, 3)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Başarı dağılımı donut ve aşağıdaki analizler
            _buildSuccessDonut(),
            const SizedBox(height: 16),

            // İstatistik kartları (donut altında, seri kartları çıkarıldı)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                // 1) Toplam Başarılı Gün
                _buildStatCard(
                  l10n.totalSuccessfulDays,
                  l10n.daysCount(_successfulDaysSelected()),
                  '',
                  Icons.check_circle_outline,
                  Theme.of(context).colorScheme.primary,
                ),
                // 2) Toplam Başarısız Gün
                _buildStatCard(
                  l10n.totalUnsuccessfulDays,
                  l10n.daysCount(_unsuccessfulDaysSelected()),
                  '',
                  Icons.cancel_outlined,
                  Theme.of(context).colorScheme.error,
                ),
                // Seri kartları yukarı taşındı
                // 5) Toplam Süre (zamanlayıcı) / Toplam İlerleme (diğer)
                if (isTimer)
                  _buildStatCard(
                    l10n.totalDuration,
                    '${_totalMinutesSelected()} ${widget.unit ?? 'min'}',
                    '',
                    Icons.access_time,
                    Colors.green,
                  )
                else
                  _buildStatCard(
                    l10n.totalProgress,
                    _totalRawSelectedWithUnit(),
                    '',
                    Icons.data_usage_outlined,
                    Colors.green,
                  ),
              ],
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 8),

            // Grafik
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorScheme.surfaceVariant.withValues(alpha: 0.06)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                      : colorScheme.outline.withValues(alpha: 0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPeriod == 0
                        ? l10n.weeklyProgress
                        : _selectedPeriod == 1
                        ? l10n.monthlyProgress
                        : _selectedPeriod == 2
                        ? l10n.yearlyProgress
                        : l10n.overallProgress,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildChart()),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rozetler (alışkanlık özel başarımlar)
            _buildBadgesSection(),

            const SizedBox(height: 24),

            // Motivasyon bölümü
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? LinearGradient(
                        colors: [
                          colorScheme.surfaceVariant.withValues(alpha: 0.12),
                          colorScheme.surface.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          widget.habitColor.withValues(alpha: 0.10),
                          widget.habitColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 ${AppLocalizations.of(context).motivation}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).motivationBody(
                      _selectedAvgPercent().round(),
                      _motivationPeriodTextLocalized(
                        AppLocalizations.of(context),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Trend bilgisi test verisi kaldırıldı
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.10)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.50)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_selectedPeriod == 0) {
      // Haftalık çubuk grafik
      final bars = _computedWeekly;
      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < weekDays.length) {
                    return Text(
                      weekDays[value.toInt()],
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  if (value % 25 == 0) {
                    return Text(
                      '${value.toInt()}%',
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: bars.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.clamp(0, 100),
                  color: widget.habitColor,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    } else {
      // Aylık / Yıllık / Genel -> sütun (bar) grafik
      final bars =
          (_selectedPeriod == 1
                  ? _computedMonthly
                  : _selectedPeriod == 2
                  ? _computedYearly
                  : _computedGeneral)
              .asMap()
              .entries
              .toList();

      final count = bars.length;
      // adapt bar width: many bars -> narrow, few bars -> thicker
      final barWidth = count > 20 ? 8.0 : (count > 12 ? 12.0 : 20.0);

      String locale = Localizations.localeOf(context).languageCode;

      Widget bottomTitleWidget(double value, TitleMeta meta) {
        final idx = value.toInt();
        if (idx < 0 || idx >= count) return const Text('');
        if (_selectedPeriod == 0) {
          // weekly handled earlier — shouldn't reach here
          return Text(
            weekDays[idx],
            style: Theme.of(context).textTheme.labelSmall,
          );
        } else if (_selectedPeriod == 1) {
          // monthly: show day numbers (1, 5, 10, 15, 20, 25, 30)
          final day = idx + 1;
          if (day == 1 || day % 5 == 0) {
            return Text('$day', style: Theme.of(context).textTheme.labelSmall);
          }
          return const Text('');
        } else if (_selectedPeriod == 2) {
          // yearly: show month short names
          final monthDate = DateTime(DateTime.now().year, idx + 1, 1);
          final label = DateFormat.MMM(locale).format(monthDate);
          return Text(label, style: Theme.of(context).textTheme.labelSmall);
        } else {
          // overall: show every Nth label to avoid crowding
          final step = (count / 6).ceil();
          if (step <= 0) return const Text('');
          if (idx % step == 0)
            return Text(
              '${idx + 1}',
              style: Theme.of(context).textTheme.labelSmall,
            );
          return const Text('');
        }
      }

      // Make the chart horizontally scrollable when there are many bars.
      const double minGroupSpacing = 12.0;
      return LayoutBuilder(
        builder: (context, constraints) {
          final double desiredWidth = math.max(
            constraints.maxWidth,
            (count * (barWidth + minGroupSpacing)) + 24.0,
          );
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: desiredWidth,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitleWidget,
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          if (value % 25 == 0) {
                            return Text(
                              '${value.toInt()}%',
                              style: Theme.of(context).textTheme.labelSmall,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.36)
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.20),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: bars.map((entry) {
                    final x = entry.key;
                    final y = entry.value.clamp(0, 100).toDouble();
                    return BarChartGroupData(
                      x: x,
                      barRods: [
                        BarChartRodData(
                          toY: y,
                          color: widget.habitColor,
                          width: barWidth,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildGeneralCalendar({bool withNav = false}) {
    if (_liveHabit == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final habit = _liveHabit!;
    final bool canEdit = widget.habitId != null;
    final now = DateTime.now();
    final int year = _calendarMonth.year;
    final int month = _calendarMonth.month;
    final int daysInMonth = _daysInMonth(year, month);
    final DateTime firstOfMonth = DateTime(year, month, 1);
    final int firstWeekday = firstOfMonth.weekday; // 1=Mon..7=Sun
    final DateTime startDate = _parseIsoDate(habit.startDate);
    final DateTime? endDate = habit.endDate != null
        ? _parseIsoDate(habit.endDate!)
        : null;
    final DateTime today = DateTime(now.year, now.month, now.day);

    Color dayBg({
      required bool success,
      required bool disabled,
      required bool partial,
    }) {
      if (disabled) return colorScheme.surfaceContainerHighest;
      if (success) return widget.habitColor.withValues(alpha: 0.90);
      if (partial) return widget.habitColor.withValues(alpha: 0.12);
      return colorScheme.surface;
    }

    Color dayFg({
      required bool success,
      required bool disabled,
      required bool partial,
    }) {
      if (disabled) return colorScheme.onSurfaceVariant;
      if (success) return colorScheme.onPrimary;
      if (partial) return widget.habitColor;
      return colorScheme.onSurface;
    }

    Widget buildDayCell(int dayNumber) {
      final DateTime date = DateTime(year, month, dayNumber);
      final String dateKey = _dateKey(date);
      final bool isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final bool beforeStart = date.isBefore(startDate);
      final bool afterEnd = endDate != null && date.isAfter(endDate!);
      final bool inFuture = date.isAfter(today);
      final bool disabled = beforeStart || inFuture || afterEnd;
      bool hasEntry = habit.dailyLog.containsKey(dateKey);
      int progress = hasEntry ? (habit.dailyLog[dateKey] ?? 0) : 0;
      if (!hasEntry && isToday) {
        progress = habit.currentStreak;
      }
      final bool considered = hasEntry || (isToday && habit.isCompleted);
      final bool success =
          !disabled &&
          considered &&
          HabitRepository.evaluateCompletionForProgress(habit, progress);
      final bool partial = !success && considered && progress > 0;
      final Color background = dayBg(
        success: success,
        disabled: disabled,
        partial: partial,
      );
      final Color textColor = dayFg(
        success: success,
        disabled: disabled,
        partial: partial,
      );
      final Color borderColor = disabled
          ? colorScheme.outline.withValues(alpha: 0.12)
          : success
          ? widget.habitColor
          : partial
          ? widget.habitColor.withValues(alpha: 0.40)
          : colorScheme.outline.withValues(alpha: 0.20);

      Widget cell = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          '$dayNumber',
          style: theme.textTheme.labelMedium?.copyWith(
            color: textColor,
            fontWeight: success ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      );

      if (!disabled && canEdit) {
        cell = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onCalendarDayTap(date),
          child: cell,
        );
      }

      return cell;
    }

    List<Widget> buildGridCells() {
      final cells = <Widget>[];
      final headers = [
        l10n.weekdaysShortMon,
        l10n.weekdaysShortTue,
        l10n.weekdaysShortWed,
        l10n.weekdaysShortThu,
        l10n.weekdaysShortFri,
        l10n.weekdaysShortSat,
        l10n.weekdaysShortSun,
      ];
      for (final h in headers) {
        cells.add(
          Center(
            child: Text(
              h,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      for (int i = 1; i < firstWeekday; i++) {
        cells.add(const SizedBox());
      }

      for (int d = 1; d <= daysInMonth; d++) {
        cells.add(buildDayCell(d));
      }

      while (cells.length % 7 != 0) {
        cells.add(const SizedBox());
      }
      return cells;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? colorScheme.outlineVariant.withValues(alpha: 0.50)
              : colorScheme.outline.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (withNav)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _calendarMonth = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month - 1,
                        1,
                      );
                    });
                  },
                ),
              Expanded(
                child: Text(
                  '${DateFormat.MMMM(Localizations.localeOf(context).languageCode).format(DateTime(year, month))} $year',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (withNav)
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _calendarMonth = DateTime(
                        _calendarMonth.year,
                        _calendarMonth.month + 1,
                        1,
                      );
                    });
                  },
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.habitColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: widget.habitColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.successfulDayLegend,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.2,
            children: buildGridCells(),
          ),
        ],
      ),
    );
  }

  // Removed unused hardcoded month name helper in favor of intl DateFormat.

  Future<void> _onCalendarDayTap(DateTime date) async {
    if (!mounted || _liveHabit == null || widget.habitId == null) return;
    final habit = _repo.findById(widget.habitId!);
    if (habit == null) return;
    final DateTime startDate = _parseIsoDate(habit.startDate);
    if (date.isBefore(startDate)) return;
    if (habit.endDate != null) {
      final DateTime endDate = _parseIsoDate(habit.endDate!);
      if (date.isAfter(endDate)) return;
    }
    final DateTime now = DateTime.now();
    final DateTime todayDate = DateTime(now.year, now.month, now.day);
    final bool isToday =
        date.year == todayDate.year &&
        date.month == todayDate.month &&
        date.day == todayDate.day;

    if (habit.habitType == HabitType.simple) {
      _repo.toggleSimpleForDate(habit.id, date);
      if (!mounted) return;
      setState(() {
        _liveHabit = _repo.findById(habit.id);
      });
      return;
    }

    final String dateKey = _dateKey(date);
    final int currentValue =
        habit.dailyLog[dateKey] ?? (isToday ? habit.currentStreak : 0);
    final int? newValue = await _showManualValueDialogForDate(
      habit,
      date,
      currentValue,
    );
    if (!mounted) return;
    if (newValue == null) return;
    // context ile yapılacak işlemlerden önce tekrar kontrol
    if (!mounted) return;
    _repo.setManualProgressForDate(habit.id, date, newValue);
    if (!mounted) return;
    setState(() {
      _liveHabit = _repo.findById(habit.id);
    });
  }

  Future<int?> _showManualValueDialogForDate(
    Habit habit,
    DateTime date,
    int initialValue,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat.yMMMMd(localeName).format(date);
    final String effectiveUnitLabel =
        habit.unit != null && habit.unit!.trim().isNotEmpty
        ? habit.unit!.trim()
        : (habit.habitType == HabitType.timer
              ? l10n.minutes.toLowerCase()
              : '');
    final String targetText = effectiveUnitLabel.isNotEmpty
        ? '${habit.targetCount} $effectiveUnitLabel'
        : '${habit.targetCount}';

    String? ruleHint;
    if (habit.habitType == HabitType.numerical) {
      switch (habit.numericalTargetType) {
        case NumericalTargetType.minimum:
          ruleHint = l10n.ruleEnteredValueAtLeast(targetText);
          break;
        case NumericalTargetType.exact:
          ruleHint = l10n.ruleEnteredValueExactly(targetText);
          break;
        case NumericalTargetType.maximum:
          ruleHint = l10n.ruleEnteredValueAtMost(targetText);
          break;
      }
    } else if (habit.habitType == HabitType.timer) {
      switch (habit.timerTargetType) {
        case TimerTargetType.minimum:
          ruleHint = l10n.ruleEnteredDurationAtLeast(targetText);
          break;
        case TimerTargetType.exact:
          ruleHint = l10n.ruleEnteredDurationExactly(targetText);
          break;
        case TimerTargetType.maximum:
          ruleHint = l10n.ruleEnteredDurationAtMost(targetText);
          break;
      }
    }

    int? result;
    result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return _ManualValueDialog(
          habit: habit,
          date: date,
          initialValue: initialValue,
          formattedDate: formattedDate,
          effectiveUnitLabel: effectiveUnitLabel,
          targetText: targetText,
          ruleHint: ruleHint,
          habitColor: widget.habitColor,
          l10n: l10n,
          theme: theme,
        );
      },
    );
    return result;
  }

  Widget _buildBadgesSection() {
    if (_liveHabit == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final habit = _liveHabit!;

    // Stats for badges
    final longest = _longestStreakAllHistory();
    final totalSuccess = _completedDaysInAllHistory();
    int totalRaw = 0;
    habit.dailyLog.forEach((_, v) => totalRaw += v);

    // Define badges based on habit type
    final List<_Badge> badges = [];
    // Streak badges
    final l10n = AppLocalizations.of(context);
    badges.addAll([
      _Badge(l10n.streakDays(3), Icons.local_fire_department, 3, longest >= 3),
      _Badge(l10n.streakDays(7), Icons.local_fire_department, 7, longest >= 7),
      _Badge(
        l10n.streakDays(30),
        Icons.local_fire_department,
        30,
        longest >= 30,
      ),
    ]);

    if (habit.habitType == HabitType.timer) {
      // Minute milestones
      badges.addAll([
        _Badge('100 ${l10n.minutes}', Icons.timer, 100, totalRaw >= 100),
        _Badge('500 ${l10n.minutes}', Icons.timer, 500, totalRaw >= 500),
        _Badge('1000 ${l10n.minutes}', Icons.timer, 1000, totalRaw >= 1000),
      ]);
    } else if (habit.habitType == HabitType.numerical) {
      // Total units milestones
      badges.addAll([
        _Badge(
          '100 ${habit.unit ?? ''}'.trim(),
          Icons.auto_graph,
          100,
          totalRaw >= 100,
        ),
        _Badge(
          '500 ${habit.unit ?? ''}'.trim(),
          Icons.auto_graph,
          500,
          totalRaw >= 500,
        ),
        _Badge(
          '1000 ${habit.unit ?? ''}'.trim(),
          Icons.auto_graph,
          1000,
          totalRaw >= 1000,
        ),
      ]);
    } else {
      // Simple habit: total successful days
      badges.addAll([
        _Badge(
          l10n.successfulDaysCount(10),
          Icons.verified,
          10,
          totalSuccess >= 10,
        ),
        _Badge(
          l10n.successfulDaysCount(25),
          Icons.verified,
          25,
          totalSuccess >= 25,
        ),
        _Badge(
          l10n.successfulDaysCount(50),
          Icons.verified,
          50,
          totalSuccess >= 50,
        ),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? colorScheme.surfaceVariant.withValues(alpha: 0.06)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? colorScheme.outline.withValues(alpha: 0.10)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).badges,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: badges.map((b) => _buildBadgeChip(b, theme)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(_Badge b, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final bg = b.achieved
        ? widget.habitColor.withValues(alpha: 0.15)
        : colorScheme.surfaceContainerHighest;
    final border = b.achieved ? widget.habitColor : colorScheme.outline;
    final fg = b.achieved ? widget.habitColor : colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(b.icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Text(
            b.title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: b.achieved ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (b.achieved) ...[
            const SizedBox(width: 6),
            Icon(Icons.check_circle, color: fg, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessDonut() {
    final colorScheme = Theme.of(context).colorScheme;
    final success = _successfulDaysSelected();
    final fail = _unsuccessfulDaysSelected();
    final total = (success + fail);
    final pct = total > 0 ? (success * 100.0 / total) : 0.0;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: 60,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  value: success.toDouble(),
                  color: colorScheme.primary,
                  showTitle: false,
                  radius: 28,
                ),
                PieChartSectionData(
                  value: fail.toDouble(),
                  color: colorScheme.error.withValues(alpha: 0.85),
                  showTitle: false,
                  radius: 28,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '%${pct.round()}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).success,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakRow() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? colorScheme.surfaceVariant.withValues(alpha: 0.08)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorScheme.outline.withValues(alpha: 0.10)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.whatshot_outlined,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).longestStreak,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).daysCount(_longestStreakAllHistory()),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.blue, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context).currentStreak,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).daysCount(_currentStreakSelected()),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DateTimeRange _getDateRange(int period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (period == 0) {
      // Weekly
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return DateTimeRange(start: monday, end: sunday);
    } else if (period == 1) {
      // Monthly
      final startOfMonth = DateTime(today.year, today.month, 1);
      final endOfMonth = DateTime(today.year, today.month + 1, 0);
      return DateTimeRange(start: startOfMonth, end: endOfMonth);
    } else if (period == 2) {
      // Yearly
      final startOfYear = DateTime(today.year, 1, 1);
      final endOfYear = DateTime(today.year, 12, 31);
      return DateTimeRange(start: startOfYear, end: endOfYear);
    } else {
      // Overall
      final start = _liveHabit != null
          ? _parseIsoDate(_liveHabit!.startDate)
          : today;
      return DateTimeRange(start: start, end: today);
    }
  }

  void _buildWeeklyFromDailyLog(bool isTimer) {
    if (_liveHabit == null) return;
    final habit = _liveHabit!;
    final range = _getDateRange(0);
    final List<double> values = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final d = range.start.add(Duration(days: i));
      final key = _dateKey(d);
      if (!_isEffectiveDay(d, habit)) {
        values[i] = 0;
        continue;
      }
      final raw = habit.dailyLog[key] ?? 0;
      values[i] = _percentFor(habit, key, raw);
    }
    _computedWeekly = values;
  }

  void _buildMonthlyFromDailyLog(bool isTimer) {
    if (_liveHabit == null) return;
    final habit = _liveHabit!;
    final range = _getDateRange(1);
    final daysInMonth = range.duration.inDays + 1;

    final List<double> values = List.filled(daysInMonth, 0);
    for (int i = 0; i < daysInMonth; i++) {
      final d = range.start.add(Duration(days: i));
      final key = _dateKey(d);
      if (!_isEffectiveDay(d, habit)) {
        values[i] = 0;
        continue;
      }
      final raw = habit.dailyLog[key] ?? 0;
      values[i] = _percentFor(habit, key, raw);
    }
    _computedMonthly = values;
  }

  void _buildYearlyFromDailyLog(bool isTimer) {
    if (_liveHabit == null) return;
    final habit = _liveHabit!;
    final now = DateTime.now();
    final List<double> months = [];

    for (int m = 1; m <= 12; m++) {
      final monthDate = DateTime(now.year, m, 1);
      final daysIn = _daysInMonth(monthDate.year, monthDate.month);
      double sum = 0;
      int eff = 0;
      for (int d = 0; d < daysIn; d++) {
        final day = DateTime(monthDate.year, monthDate.month, 1 + d);
        if (!_isEffectiveDay(day, habit)) continue;
        final key = _dateKey(day);
        final raw = habit.dailyLog[key] ?? 0;
        sum += _percentFor(habit, key, raw);
        eff++;
      }
      final double avg = eff > 0 ? (sum / eff) : 0.0;
      months.add(avg);
    }
    _computedYearly = months;
  }

  void _buildGeneralFromDailyLog(bool isTimer) {
    if (_liveHabit == null) return;
    if (_liveHabit!.dailyLog.isEmpty) {
      _computedGeneral = [];
      return;
    }
    final habit = _liveHabit!;
    // Determine first effective date
    DateTime parseKey(String k) {
      final parts = k.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    DateTime start = parseKey(habit.startDate);
    if (habit.dailyLog.isNotEmpty) {
      final firstLogKey = (habit.dailyLog.keys.toList()..sort()).first;
      final firstLogDate = parseKey(firstLogKey);
      if (firstLogDate.isAfter(start)) start = firstLogDate;
    }
    final now = DateTime.now();
    final List<double> series = [];
    DateTime cursor = DateTime(start.year, start.month, 1);
    while (!DateTime(cursor.year, cursor.month + 1, 1).isAfter(now)) {
      final daysIn = _daysInMonth(cursor.year, cursor.month);
      double sumPct = 0;
      int eff = 0;
      for (int d = 1; d <= daysIn; d++) {
        final day = DateTime(cursor.year, cursor.month, d);
        if (!_isEffectiveDay(day, habit)) continue;
        final key =
            '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
        final raw = habit.dailyLog[key] ?? 0;
        sumPct += _percentFor(habit, key, raw);
        eff++;
      }
      final avg = eff > 0 ? (sumPct / eff) : 0.0;
      series.add(avg);
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    _computedGeneral = series;
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime _parseIsoDate(String iso) {
    final parts = iso.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  int _safeTarget() =>
      (_liveHabit?.targetCount ?? widget.targetCount).clamp(1, 1000000);
  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
  double _avg(List<double> xs) =>
      xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

  // A day is effective if it is within start/end, not in the future, and if scheduledDates is set, the date is scheduled
  bool _isEffectiveDay(DateTime date, Habit habit) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = _parseIsoDate(habit.startDate);
    final end = habit.endDate != null ? _parseIsoDate(habit.endDate!) : null;
    if (dateOnly.isBefore(start)) return false;
    if (end != null && dateOnly.isAfter(end)) return false;
    if (dateOnly.isAfter(DateTime(today.year, today.month, today.day))) {
      return false; // future day
    }
    if (habit.scheduledDates != null && habit.scheduledDates!.isNotEmpty) {
      final key = _dateKey(dateOnly);
      return habit.scheduledDates!.contains(key);
    }
    return true;
  }

  // Compute percent contribution for a given raw value according to habit policy.
  // - minimum: raw/target * 100 capped at 100
  // - exact: 100 if raw == target else 0
  // - maximum: 100 if raw <= target and there is an entry; values above target score 0 to reflect overage against a maximum policy
  double _percentFor(Habit habit, String dateKey, int raw) {
    switch (habit.habitType) {
      case HabitType.simple:
      case HabitType.checkbox:
        return HabitRepository.evaluateCompletionForProgress(habit, raw)
            ? 100
            : 0;
      case HabitType.subtasks:
        return HabitRepository.evaluateCompletionForProgress(habit, raw)
            ? 100
            : 0;
      case HabitType.numerical:
        switch (habit.numericalTargetType) {
          case NumericalTargetType.minimum:
            final target = habit.targetCount <= 0 ? 1 : habit.targetCount;
            return (raw / target * 100).clamp(0, 100).toDouble();
          case NumericalTargetType.exact:
            return raw == habit.targetCount ? 100 : 0;
          case NumericalTargetType.maximum:
            // Only count if there is an explicit entry for the day
            if (!habit.dailyLog.containsKey(dateKey)) return 0;
            return raw <= habit.targetCount ? 100 : 0;
        }
      case HabitType.timer:
        switch (habit.timerTargetType) {
          case TimerTargetType.minimum:
            final target = habit.targetCount <= 0 ? 1 : habit.targetCount;
            return (raw / target * 100).clamp(0, 100).toDouble();
          case TimerTargetType.exact:
            return raw == habit.targetCount ? 100 : 0;
          case TimerTargetType.maximum:
            if (!habit.dailyLog.containsKey(dateKey)) return 0;
            return raw <= habit.targetCount ? 100 : 0;
        }
    }
  }

  // --- Yeni metrik yardımcıları ---
  int _successfulDaysSelected() {
    if (_liveHabit == null) return 0;
    final range = _getDateRange(_selectedPeriod);
    int count = 0;
    final habit = _liveHabit!;

    for (
      var d = range.start;
      !d.isAfter(range.end);
      d = d.add(const Duration(days: 1))
    ) {
      if (!_isEffectiveDay(d, habit)) continue;
      final key = _dateKey(d);
      if (HabitRepository.evaluateCompletionFromLog(habit, key)) count++;
    }
    return count;
  }

  int _unsuccessfulDaysSelected() {
    if (_liveHabit == null) return 0;
    final range = _getDateRange(_selectedPeriod);
    int count = 0;
    final habit = _liveHabit!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (
      var d = range.start;
      !d.isAfter(range.end);
      d = d.add(const Duration(days: 1))
    ) {
      if (!_isEffectiveDay(d, habit)) continue;
      // Don't count future days as unsuccessful
      if (d.isAfter(today)) continue;

      final key = _dateKey(d);
      if (!HabitRepository.evaluateCompletionFromLog(habit, key)) count++;
    }
    return count;
  }

  int _currentStreakSelected() {
    if (_liveHabit == null) return 0;
    final habit = _liveHabit!;
    return _repo.consecutiveStreakFor(habit, upTo: DateTime.now());
  }

  String _totalRawSelectedWithUnit() {
    if (_liveHabit == null) return '0';
    final range = _getDateRange(_selectedPeriod);
    int sum = 0;
    final habit = _liveHabit!;

    for (
      var d = range.start;
      !d.isAfter(range.end);
      d = d.add(const Duration(days: 1))
    ) {
      final key = _dateKey(d);
      sum += habit.dailyLog[key] ?? 0;
    }
    final unit = widget.unit;
    return unit == null || unit.isEmpty ? '$sum' : '$sum $unit';
  }

  int _totalMinutesSelected() {
    if (_liveHabit == null) return 0;
    final range = _getDateRange(_selectedPeriod);
    int sum = 0;
    final habit = _liveHabit!;

    for (
      var d = range.start;
      !d.isAfter(range.end);
      d = d.add(const Duration(days: 1))
    ) {
      final key = _dateKey(d);
      sum += habit.dailyLog[key] ?? 0;
    }
    return sum;
  }

  int _completedDaysInAllHistory() {
    if (_liveHabit == null) return 0;
    int count = 0;
    _liveHabit!.dailyLog.forEach((_, raw) {
      if (HabitRepository.evaluateCompletionForProgress(_liveHabit!, raw))
        count++;
    });
    return count;
  }

  int _sumMinutesAllHistory() {
    if (_liveHabit == null) return 0;
    int sum = 0;
    _liveHabit!.dailyLog.forEach((_, raw) => sum += raw);
    return sum;
  }

  double _selectedAvgPercent() {
    if (_liveHabit == null) return 0;
    final habit = _liveHabit!;
    // For weekly/monthly, compute average only over effective days (exclude non-scheduled/future days)
    if (_selectedPeriod == 0) {
      final range = _getDateRange(0);
      double sum = 0;
      int eff = 0;
      for (
        var d = range.start;
        !d.isAfter(range.end);
        d = d.add(const Duration(days: 1))
      ) {
        if (!_isEffectiveDay(d, habit)) continue;
        final key = _dateKey(d);
        final raw = habit.dailyLog[key] ?? 0;
        sum += _percentFor(habit, key, raw);
        eff++;
      }
      return eff > 0 ? (sum / eff) : 0;
    } else if (_selectedPeriod == 1) {
      final range = _getDateRange(1);
      double sum = 0;
      int eff = 0;
      for (
        var d = range.start;
        !d.isAfter(range.end);
        d = d.add(const Duration(days: 1))
      ) {
        if (!_isEffectiveDay(d, habit)) continue;
        final key = _dateKey(d);
        final raw = habit.dailyLog[key] ?? 0;
        sum += _percentFor(habit, key, raw);
        eff++;
      }
      return eff > 0 ? (sum / eff) : 0;
    } else if (_selectedPeriod == 2) {
      return _computedYearly.isEmpty ? 0 : _avg(_computedYearly);
    } else {
      return _computedGeneral.isEmpty ? 0 : _avg(_computedGeneral);
    }
  }

  String _motivationPeriodTextLocalized(AppLocalizations l10n) {
    switch (_selectedPeriod) {
      case 1:
        return l10n.thisMonth;
      case 2:
        return l10n.thisYear;
      case 3:
        return l10n.overall;
      case 0:
      default:
        return l10n.thisWeek;
    }
  }

  int _totalDaysInAllHistory() {
    if (_liveHabit == null) return 0;
    final habit = _liveHabit!;
    // Count only scheduled/effective days from start to today (or endDate)
    final DateTime start = _parseIsoDate(habit.startDate);
    final DateTime end = DateTime.now();
    int count = 0;
    DateTime cursor = DateTime(start.year, start.month, start.day);
    while (!cursor.isAfter(end)) {
      if (_isEffectiveDay(cursor, habit)) count++;
      cursor = cursor.add(const Duration(days: 1));
    }
    return count;
  }

  int _longestStreakAllHistory() {
    if (_liveHabit == null) return 0;
    final habit = _liveHabit!;
    // Scan from start to today; skip non-effective days; use log-based completion
    final DateTime start = _parseIsoDate(habit.startDate);
    final DateTime end = DateTime.now();
    int longest = 0;
    int current = 0;
    DateTime cursor = DateTime(start.year, start.month, start.day);
    while (!cursor.isAfter(end)) {
      if (_isEffectiveDay(cursor, habit)) {
        final completed = HabitRepository.evaluateCompletionFromLog(
          habit,
          _dateKey(cursor),
        );
        if (completed) {
          current++;
          if (current > longest) longest = current;
        } else {
          current = 0;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return longest;
  }
}

class _ManualValueDialog extends StatefulWidget {
  final Habit habit;
  final DateTime date;
  final int initialValue;
  final String formattedDate;
  final String effectiveUnitLabel;
  final String targetText;
  final String? ruleHint;
  final Color habitColor;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _ManualValueDialog({
    required this.habit,
    required this.date,
    required this.initialValue,
    required this.formattedDate,
    required this.effectiveUnitLabel,
    required this.targetText,
    required this.ruleHint,
    required this.habitColor,
    required this.l10n,
    required this.theme,
  });

  @override
  State<_ManualValueDialog> createState() => _ManualValueDialogState();
}

class _ManualValueDialogState extends State<_ManualValueDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.theme.colorScheme;
    final int? parsed = int.tryParse(_controller.text.trim());
    final double progress = widget.habit.targetCount > 0 && parsed != null
        ? (parsed / widget.habit.targetCount).clamp(0.0, 1.0)
        : 0.0;

    return AlertDialog(
      title: Text(widget.l10n.enterValueTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.formattedDate,
            style: widget.theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.habit.unit ?? widget.l10n.valueLabel,
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
            onChanged: (_) {
              setState(() {
                _errorText = null;
              });
            },
            onSubmitted: (_) {
              final int? submitted = int.tryParse(_controller.text.trim());
              if (submitted == null) {
                setState(() {
                  _errorText = widget.l10n.invalidValue;
                });
                return;
              }
              Navigator.of(context).pop(submitted);
            },
          ),
          if (widget.ruleHint != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.ruleHint!,
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress <= 0 ? 0 : progress,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(widget.habitColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: widget.theme.textTheme.labelSmall?.copyWith(
                  color: widget.habitColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                parsed != null
                    ? '${parsed}${widget.effectiveUnitLabel.isNotEmpty ? " ${widget.effectiveUnitLabel}" : ""}'
                    : '0',
                style: widget.theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(widget.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final int? value = int.tryParse(_controller.text.trim());
            if (value == null) {
              setState(() {
                _errorText = widget.l10n.invalidValue;
              });
              return;
            }
            Navigator.of(context).pop(value);
          },
          child: Text(widget.l10n.save),
        ),
      ],
    );
  }
}

class _Badge {
  final String title;
  final IconData icon;
  final int threshold;
  final bool achieved;
  const _Badge(this.title, this.icon, this.threshold, this.achieved);
}
