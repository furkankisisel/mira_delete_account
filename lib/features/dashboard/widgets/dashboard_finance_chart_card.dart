import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../design_system/tokens/colors.dart';

import '../../finance/data/transaction_model.dart';
import '../../finance/data/transaction_repository.dart';
import '../../finance/finance_analysis_screen.dart';
import '../../../ui/premium_gate.dart';
import '../../../design_system/theme/theme_variations.dart';

class DashboardFinanceChartCard extends StatefulWidget {
  const DashboardFinanceChartCard({super.key, required this.variant});
  final ThemeVariant variant;

  @override
  State<DashboardFinanceChartCard> createState() =>
      _DashboardFinanceChartCardState();
}

class _DashboardFinanceChartCardState extends State<DashboardFinanceChartCard> {
  late final TransactionRepository _repo;
  StreamSubscription? _sub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = TransactionRepository();
    _repo.initialize().then((_) {
      if (mounted) setState(() => _loading = false);
    });
    _sub = _repo.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool isWorld = widget.variant == ThemeVariant.world;
    final Color worldPurple = AppColors.accentPurple;
    final l10n = AppLocalizations.of(context);
    final fill = Color.alphaBlend(
      (isWorld ? worldPurple : scheme.primary).withValues(alpha: 0.12),
      scheme.surfaceContainerHighest,
    );
    final days = _last7Days();
    final totals = _loading
        ? List<double>.filled(7, 0)
        : _netTotalsForDays(days);
    final hasAny = totals.any((v) => v != 0);
    final cardRadius = BorderRadius.circular(18);

    final card = InkWell(
      borderRadius: cardRadius,
      onTap: () async {
        final ok = await requirePremium(context);
        if (!ok) return;
        if (!context.mounted) return;

        final now = DateTime.now();
        final firstOfMonth = DateTime(now.year, now.month, 1);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FinanceAnalysisScreen(
              month: firstOfMonth,
              variant: widget.variant,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: cardRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: fill, borderRadius: cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: isWorld ? worldPurple : scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.financeLast7Days,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_loading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: hasAny
                    ? IgnorePointer(
                        ignoring: true, // let taps hit the card InkWell
                        child: _LineChart7(days: days, totals: totals),
                      )
                    : Center(
                        child: Text(
                          l10n.noDataLast7Days,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    return card;
  }

  List<DateTime> _last7Days() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  List<double> _netTotalsForDays(List<DateTime> days) {
    final all = _repo.all();
    final map = {for (var i = 0; i < days.length; i++) _key(days[i]): 0.0};
    for (final tx in all) {
      final k = _key(tx.date);
      if (map.containsKey(k)) {
        map[k] =
            (map[k] ?? 0) +
            (tx.type == TransactionType.expense ? -tx.amount : tx.amount);
      }
    }
    return days.map((d) => map[_key(d)] ?? 0).toList();
  }

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _LineChart7 extends StatelessWidget {
  const _LineChart7({required this.days, required this.totals});
  final List<DateTime> days;
  final List<double> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double maxAbs = 0;
    for (final v in totals) {
      if (v.abs() > maxAbs) maxAbs = v.abs();
    }
    // Ensure the axis range fully contains the data (no clamping that could cause paint overflow)
    final double maxY = maxAbs == 0 ? 10.0 : (maxAbs * 1.2);

    final spots = <FlSpot>[];
    for (var i = 0; i < totals.length; i++) {
      spots.add(FlSpot(i.toDouble(), totals[i]));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (totals.length - 1).toDouble(),
        minY: -maxY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        clipData: const FlClipData.all(),
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
              bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 18,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                final locale = Localizations.localeOf(context).toString();
                final label = DateFormat.E(locale).format(days[idx]);
                return Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: theme.colorScheme.outline,
              strokeWidth: 1.25,
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  // old date label helper removed; bottom axis now shows localized weekday names
}
