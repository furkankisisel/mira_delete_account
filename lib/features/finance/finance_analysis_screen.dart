import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../design_system/theme/theme_variations.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'data/transaction_repository.dart';
import 'data/transaction_model.dart';
import 'data/finance_category_repository.dart';
import 'data/budget_repository.dart';

// Mode for the analysis period selector
enum PeriodMode { month, year }

// Deterministic color mapping per emoji to keep chart colors consistent and distinct.
Color _colorForEmoji(String? emoji, TransactionType? type) {
  if (emoji == null || emoji.isEmpty) {
    // Fallback to type-based color if no emoji
    return type == TransactionType.income ? Colors.green : Colors.redAccent;
  }
  // A stable palette of distinct hues
  const palette = <Color>[
    Color(0xFFE53935), // red
    Color(0xFFD81B60), // pink
    Color(0xFF8E24AA), // purple
    Color(0xFF5E35B1), // deepPurple
    Color(0xFF3949AB), // indigo
    Color(0xFF1E88E5), // blue
    Color(0xFF039BE5), // lightBlue
    Color(0xFF00ACC1), // cyan
    Color(0xFF00897B), // teal
    Color(0xFF43A047), // green
    Color(0xFF7CB342), // lightGreen
    Color(0xFFC0CA33), // lime
    Color(0xFFFDD835), // yellow/amber
    Color(0xFFFB8C00), // orange
    Color(0xFFF4511E), // deepOrange
    Color(0xFF6D4C41), // brown
    Color(0xFF546E7A), // blueGrey
  ];
  // Simple hash over code points
  int hash = 0;
  for (final r in emoji.runes) {
    hash = 0x1fffffff & (hash * 31 + r);
  }
  return palette[hash % palette.length];
}

// Choose a readable text color for labels over a given background color.
Color _onColor(Color background) =>
    background.computeLuminance() > 0.5 ? Colors.black : Colors.white;

class FinanceAnalysisScreen extends StatefulWidget {
  const FinanceAnalysisScreen({super.key, required this.month, this.variant});

  final DateTime month; // year + month used
  final ThemeVariant? variant;

  @override
  State<FinanceAnalysisScreen> createState() => _FinanceAnalysisScreenState();
}

class _FinanceAnalysisScreenState extends State<FinanceAnalysisScreen> {
  // Controls whether the analysis shows a single month or a whole year.
  // We keep the original constructor param `month` as the initial selected period.
  late PeriodMode _mode;
  late DateTime
  _selectedPeriod; // if month -> year+month used; if year -> year used (month=1)
  late final TransactionRepository _repo;
  late final FinanceCategoryRepository _catRepo;
  late final BudgetRepository _budgetRepo;
  bool _loading = true;
  double? _plannedMonthlySpend;

  @override
  void initState() {
    super.initState();
    _repo = TransactionRepository();
    _catRepo = FinanceCategoryRepository();
    _budgetRepo = BudgetRepository();
    _mode = PeriodMode.month;
    _selectedPeriod = DateTime(widget.month.year, widget.month.month, 1);
    Future.wait([
      _repo.initialize(),
      _catRepo.initialize(),
      _budgetRepo.initialize(),
    ]).then((_) {
      _plannedMonthlySpend = _budgetRepo.getBudgetForMonth(
        DateTime(widget.month.year, widget.month.month, 1),
      );
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _repo.dispose();
    _catRepo.dispose();
    _budgetRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWorld = widget.variant == ThemeVariant.world;
    final locale = Localizations.localeOf(context).toString();
    final titleStr = _mode == PeriodMode.month
        ? DateFormat.yMMMM(locale).format(_selectedPeriod)
        : DateFormat.y(locale).format(DateTime(_selectedPeriod.year));

    // Compute transactions according to selected mode (month vs year)
    final incomes = _loading
        ? const <FinanceTransaction>[]
        : (_mode == PeriodMode.month
              ? _repo.incomesForMonth(_selectedPeriod)
              : _aggregateIncomesForYear(_selectedPeriod.year));
    final expenses = _loading
        ? const <FinanceTransaction>[]
        : (_mode == PeriodMode.month
              ? _repo.expensesForMonth(_selectedPeriod)
              : _aggregateExpensesForYear(_selectedPeriod.year));
    final allTx = _loading
        ? const <FinanceTransaction>[]
        : (_mode == PeriodMode.month
              ? _repo.forMonth(_selectedPeriod)
              : _aggregateForYear(_selectedPeriod.year));

    final incomeTotal = incomes.fold<double>(0, (s, e) => s + e.amount);
    final expenseTotal = expenses.fold<double>(0, (s, e) => s + e.amount);
    final net = incomeTotal - expenseTotal;

    // Previous month comparison
    // previous month comparison omitted (not used currently)

    final content = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context).financeAnalysisTitle(titleStr),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Theme.of(context).colorScheme.surface,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _BudgetPlanner(
                    month: _selectedPeriod,
                    plannedMonthlySpend: _plannedMonthlySpend,
                    onSave: (v) async {
                      await _budgetRepo.setBudgetForMonth(
                        DateTime(widget.month.year, widget.month.month, 1),
                        v,
                      );
                      if (mounted) setState(() => _plannedMonthlySpend = v);
                    },
                    repo: _repo,
                  ),
                  const SizedBox(height: 12),
                  // Mode selector + period chooser
                  _ModeAndPeriodSelector(
                    mode: _mode,
                    selected: _selectedPeriod,
                    onModeChanged: (m) => setState(() => _mode = m),
                    onPeriodChanged: (d) => setState(() => _selectedPeriod = d),
                  ),
                  const SizedBox(height: 12),
                  // Top KPIs
                  _StatTile(
                    label: AppLocalizations.of(context).incomeLabel,
                    value: _formatCurrency(context, incomeTotal),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _StatTile(
                    label: AppLocalizations.of(context).expenseLabel,
                    value: _formatCurrency(context, expenseTotal),
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  _StatTile(
                    label: AppLocalizations.of(context).financeNet,
                    value: _formatCurrency(context, net),
                    color: net >= 0 ? Colors.green : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  // Removed delta chips (income/expense changes) as requested
                  Text(
                    _mode == PeriodMode.month
                        ? AppLocalizations.of(context).monthlyTrend
                        : AppLocalizations.of(context).yearlyProgress,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_mode == PeriodMode.month)
                    _MonthlyTrendChart(
                      month: _selectedPeriod,
                      transactions: allTx,
                    )
                  else
                    _YearlyTrendChart(
                      year: _selectedPeriod.year,
                      transactions: allTx,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).expenseDistributionPie,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ExpensePieChart(
                    month: _selectedPeriod,
                    repo: _repo,
                    catRepo: _catRepo,
                    transactions: expenses,
                    // Grafik dilimlerine tıklayınca açılmasın
                    onSelect: null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).breakdownByCategory,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _CategoryBreakdown(
                    month: _selectedPeriod,
                    transactions: allTx,
                    repo: _repo,
                    catRepo: _catRepo,
                    onSelect: (catId) => _showCategoryDetails(context, catId),
                  ),
                ],
              ),
            ),
    );

    if (isWorld) {
      final brightness = Theme.of(context).brightness;
      final themed = brightness == Brightness.dark
          ? ThemeVariations.dark(ThemeVariant.ocean)
          : ThemeVariations.light(ThemeVariant.ocean);
      return Theme(data: themed, child: content);
    }
    return content;
  }

  void _showCategoryDetails(BuildContext context, String? categoryId) {
    final nf = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
    );
    final cats = {for (final c in _catRepo.all()) c.id: c};
    final l10n = AppLocalizations.of(context);
    final name = categoryId == null
        ? l10n.other
        : (cats[categoryId]?.name ?? l10n.other);
    final scheme = Theme.of(context).colorScheme;
    final color = categoryId == null
        ? scheme.primary
        : _colorForEmoji(cats[categoryId]?.emoji, cats[categoryId]?.type);
    // Respect currently selected period
    final txs =
        (_mode == PeriodMode.month
                ? _repo.expensesForMonth(_selectedPeriod)
                : _aggregateExpensesForYear(_selectedPeriod.year))
            .where((e) => (e.categoryId ?? '_none') == (categoryId ?? '_none'))
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(name, style: Theme.of(ctx).textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        '${txs.length}',
                        style: Theme.of(ctx).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: txs.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noExpenseInThisCategory,
                              style: Theme.of(ctx).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: txs.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final t = txs[i];
                              return ListTile(
                                title: Text(t.title),
                                subtitle: Text(
                                  DateFormat(
                                    'dd MMM',
                                    Localizations.localeOf(ctx).toString(),
                                  ).format(t.date),
                                ),
                                trailing: Text(
                                  nf.format(t.amount),
                                  style: Theme.of(ctx).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatCurrency(BuildContext context, double amount) {
    final localeName = Localizations.localeOf(context).toString();
    final nf = NumberFormat.simpleCurrency(locale: localeName);
    return nf.format(amount);
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetPlanner extends StatefulWidget {
  const _BudgetPlanner({
    required this.month,
    required this.plannedMonthlySpend,
    required this.onSave,
    required this.repo,
  });
  final DateTime month;
  final double? plannedMonthlySpend;
  final Future<void> Function(double) onSave;
  final TransactionRepository repo;

  @override
  State<_BudgetPlanner> createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<_BudgetPlanner> {
  late final TextEditingController _controller;
  late NumberFormat _groupFormat;

  @override
  void initState() {
    super.initState();
    // Avoid accessing inherited widgets in initState; set up controller only.
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to access Localizations/Theme.
    _groupFormat = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    );
    // Initialize or update text based on current locale and planned value.
    _controller.text = widget.plannedMonthlySpend != null
        ? _groupFormat.format(widget.plannedMonthlySpend!.round())
        : '';
  }

  @override
  void didUpdateWidget(covariant _BudgetPlanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plannedMonthlySpend != widget.plannedMonthlySpend) {
      // Reuse existing _groupFormat; it's updated in didChangeDependencies on locale change.
      _controller.text = widget.plannedMonthlySpend != null
          ? _groupFormat.format(widget.plannedMonthlySpend!.round())
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compact savings card: show only current target and an Edit button which opens a dialog
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final nf = NumberFormat.simpleCurrency(locale: localeName);
    final target = widget.plannedMonthlySpend;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.savingsBudgetPlan,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  target == null ? l10n.noDataThisMonth : nf.format(target),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              final newTarget = await _showEditBudgetDialog(
                context,
                widget.plannedMonthlySpend,
                nf,
                l10n,
              );
              if (newTarget != null && newTarget > 0) {
                await widget.onSave(newTarget);
                if (mounted) setState(() {});
              }
            },
            child: Text(l10n.edit),
          ),
        ],
      ),
    );
  }

  Future<double?> _showEditBudgetDialog(
    BuildContext context,
    double? initial,
    NumberFormat nf,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController(
      text: initial != null ? initial.round().toString() : '',
    );
    final result = await showDialog<double?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(l10n.edit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.plannedMonthlySpend,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 8),
              if (initial != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nf.format(initial),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final digits = controller.text.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                if (digits.isEmpty) return;
                final v = double.tryParse(digits);
                Navigator.of(ctx).pop(v);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    return result;
  }
}

String _commentaryLocalized(
  BuildContext context,
  double? perDay,
  double mtdAvgPerDay,
) {
  final l10n = AppLocalizations.of(context);
  if (perDay == null) return l10n.enterMonthlyPlanToComputeDailyLimit;
  final diff = perDay - mtdAvgPerDay;
  if (diff.abs() < 0.01) return l10n.onDailyLimit;
  if (diff > 0) {
    return l10n.spendingLessThanDailyAvg(diff.toStringAsFixed(0));
  } else {
    return l10n.spendingMoreThanDailyAvg((diff.abs()).toStringAsFixed(0));
  }
}

double? _parseNumeric(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return double.tryParse(digits);
}

class _ThousandsFormatter extends TextInputFormatter {
  _ThousandsFormatter(this._formatProvider);
  final NumberFormat Function() _formatProvider;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final nf = _formatProvider();
    final number = int.parse(digits);
    final formatted = nf.format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({
    required this.month,
    required this.transactions,
    required this.repo,
    required this.catRepo,
    this.onSelect,
  });
  final DateTime month;
  final List<FinanceTransaction> transactions;
  final TransactionRepository repo;
  final FinanceCategoryRepository catRepo;
  final void Function(String? categoryId)? onSelect;

  @override
  Widget build(BuildContext context) {
    final cats = {for (final c in catRepo.all()) c.id: c};
    final txs = transactions;

    final byCat = <String, double>{};
    for (final tx in txs) {
      final weight = tx.type == TransactionType.income ? tx.amount : -tx.amount;
      final id = tx.categoryId ?? '_none';
      byCat.update(id, (v) => v + weight, ifAbsent: () => weight);
    }

    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)
                : Colors.transparent,
          ),
        ),
        child: Text(AppLocalizations.of(context).noDataThisMonth),
      );
    }

    return Column(
      children: [
        for (final e in entries)
          _CategoryRow(
            categoryId: e.key == '_none' ? null : e.key,
            name: e.key == '_none'
                ? AppLocalizations.of(context).other
                : (cats[e.key]?.name ?? AppLocalizations.of(context).other),
            color: e.key == '_none'
                ? Theme.of(context).colorScheme.primary
                : _colorForEmoji(cats[e.key]?.emoji, cats[e.key]?.type),
            value: e.value,
            onTap: onSelect,
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    this.categoryId,
    required this.name,
    required this.color,
    required this.value,
    this.onTap,
  });
  final String? categoryId;
  final String name;
  final Color color;
  final double value;
  final void Function(String? categoryId)? onTap;

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();
    final nf = NumberFormat.simpleCurrency(locale: localeName);
    return InkWell(
      onTap: () => onTap?.call(categoryId),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(name)),
            Text(
              nf.format(value),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value >= 0 ? Colors.green : Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _DeltaRow removed as per request

class _MonthlyTrendChart extends StatelessWidget {
  const _MonthlyTrendChart({required this.month, required this.transactions});
  final DateTime month;
  final List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final end = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(days: 1));
    final days = end.day;

    // Daily net totals (income - expense)
    final totals = List<double>.generate(days, (_) => 0.0);
    for (final tx in transactions) {
      final dayIdx = tx.date.day - 1;
      totals[dayIdx] += tx.type == TransactionType.expense
          ? -tx.amount
          : tx.amount;
    }

    // Build bar groups and determine symmetric y-bounds
    final groups = <BarChartGroupData>[];
    double maxAbs = 0;
    for (var i = 0; i < days; i++) {
      final v = totals[i];
      final isPos = v >= 0;
      groups.add(
        BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: v,
              color: isPos ? Colors.green : Colors.redAccent,
              width: 6,
              borderRadius: isPos
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    )
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
            ),
          ],
        ),
      );
      if (v.abs() > maxAbs) maxAbs = v.abs();
    }
    final maxY = ((maxAbs * 1.4).clamp(100.0, double.infinity)).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        // Borders removed
      ),
      height: 220,
      child: BarChart(
        BarChartData(
          minY: -maxY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceBetween,
          barGroups: groups,
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
                getTitlesWidget: (v, meta) {
                  final d = v.toInt();
                  if (d == 1 || d == 15 || d == days) {
                    return Text(
                      '$d',
                      style: Theme.of(context).textTheme.labelSmall,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                color: Theme.of(context).colorScheme.outlineVariant,
                strokeWidth: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YearlyTrendChart extends StatelessWidget {
  const _YearlyTrendChart({required this.year, required this.transactions});
  final int year;
  final List<FinanceTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    // Aggregate monthly totals for the year
    final months = List<double>.generate(12, (_) => 0.0);
    for (final tx in transactions) {
      if (tx.date.year != year) continue;
      final idx = tx.date.month - 1;
      months[idx] += tx.type == TransactionType.expense
          ? -tx.amount
          : tx.amount;
    }

    // Build bar groups
    final groups = <BarChartGroupData>[];
    double maxAbs = 0;
    for (var i = 0; i < 12; i++) {
      final v = months[i];
      final isPos = v >= 0;
      groups.add(
        BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: v,
              color: isPos ? Colors.green : Colors.redAccent,
              width: 10,
              borderRadius: isPos
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    )
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
            ),
          ],
        ),
      );
      if (v.abs() > maxAbs) maxAbs = v.abs();
    }
    final maxY = ((maxAbs * 1.4).clamp(100.0, double.infinity)).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      height: 220,
      child: BarChart(
        BarChartData(
          minY: -maxY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceBetween,
          barGroups: groups,
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
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  final m = v.toInt();
                  final label = DateFormat.MMM(
                    Localizations.localeOf(context).toString(),
                  ).format(DateTime(year, m, 1));
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
                color: Theme.of(context).colorScheme.outlineVariant,
                strokeWidth: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({
    required this.month,
    required this.repo,
    required this.catRepo,
    required this.transactions,
    this.onSelect,
  });
  final DateTime month;
  final TransactionRepository repo;
  final FinanceCategoryRepository catRepo;
  final List<FinanceTransaction> transactions;
  final void Function(String? categoryId)? onSelect;

  @override
  Widget build(BuildContext context) {
    final cats = {for (final c in catRepo.all()) c.id: c};
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          // Borders removed
        ),
        child: Text(AppLocalizations.of(context).noExpenses),
      );
    }
    final byCat = <String, double>{};
    for (final tx in expenses) {
      final id = tx.categoryId ?? '_none';
      byCat.update(id, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    final total = byCat.values.fold<double>(0, (s, e) => s + e);
    final sections = <PieChartSectionData>[];
    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Deterministic fallback palette (reuse same hues as emoji mapper)
    const fallbackPalette = <Color>[
      Color(0xFFE53935), // red
      Color(0xFFD81B60), // pink
      Color(0xFF8E24AA), // purple
      Color(0xFF5E35B1), // deepPurple
      Color(0xFF3949AB), // indigo
      Color(0xFF1E88E5), // blue
      Color(0xFF039BE5), // lightBlue
      Color(0xFF00ACC1), // cyan
      Color(0xFF00897B), // teal
      Color(0xFF43A047), // green
      Color(0xFF7CB342), // lightGreen
      Color(0xFFC0CA33), // lime
      Color(0xFFFDD835), // yellow/amber
      Color(0xFFFB8C00), // orange
      Color(0xFFF4511E), // deepOrange
      Color(0xFF6D4C41), // brown
      Color(0xFF546E7A), // blueGrey
    ];

    // Build a distinct color for each category id deterministically,
    // preferring explicit category colors when available and falling back
    // to emoji-based color or the palette while avoiding duplicates.
    final used = <int>{};
    final colorMap = <String, Color>{};
    var palIdx = 0;
    for (final entry in entries) {
      final id = entry.key;
      if (id == '_none') {
        colorMap[id] = Theme.of(context).colorScheme.primary;
        used.add(colorMap[id]!.value);
        continue;
      }
      final cat = cats[id];
      Color chosen;
      if (cat != null) {
        // If category has an explicit color and it's not already used, prefer it
        chosen = Color(cat.colorValue);
        if (used.contains(chosen.value)) {
          // try emoji-derived color next
          chosen = _colorForEmoji(cat.emoji, cat.type);
        }
      } else {
        chosen = _colorForEmoji(null, null);
      }

      // If still duplicate, pick next from fallback palette
      if (used.contains(chosen.value)) {
        // find next unused palette color
        Color next;
        var attempts = 0;
        do {
          next = fallbackPalette[palIdx % fallbackPalette.length];
          palIdx++;
          attempts++;
        } while (used.contains(next.value) &&
            attempts < fallbackPalette.length * 2);
        chosen = next;
      }

      colorMap[id] = chosen;
      used.add(chosen.value);
    }

    var idx = 0;
    for (final e in entries) {
      final color = colorMap[e.key] ?? Theme.of(context).colorScheme.primary;
      final percent = total == 0 ? 0 : (e.value / total) * 100;
      sections.add(
        PieChartSectionData(
          color: color,
          value: e.value,
          radius: 46 + (idx == 0 ? 6 : 0),
          title: '${percent.toStringAsFixed(0)}%',
          titleStyle: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: _onColor(color)),
        ),
      );
      idx++;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        // Borders removed
      ),
      height: 240,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 34,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (evt, resp) {
                    if (onSelect == null) return;
                    final idx = resp?.touchedSection?.touchedSectionIndex;
                    if (idx == null || idx < 0 || idx >= entries.length) return;
                    final entry = entries[idx];
                    final isOther = entry.key == '_none';
                    onSelect!(isOther ? null : entry.key);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in entries.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color:
                                colorMap[e.key] ??
                                Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key == '_none'
                                ? AppLocalizations.of(context).other
                                : (cats[e.key]?.name ??
                                      AppLocalizations.of(context).other),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('${(e.value / total * 100).toStringAsFixed(0)}%'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper aggregation functions (client-side yearly aggregation)
extension on _FinanceAnalysisScreenState {
  List<FinanceTransaction> _aggregateForYear(int year) {
    // Collect transactions for each month and merge
    final all = <FinanceTransaction>[];
    for (var m = 1; m <= 12; m++) {
      all.addAll(_repo.forMonth(DateTime(year, m, 1)));
    }
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  List<FinanceTransaction> _aggregateIncomesForYear(int year) =>
      _aggregateForYear(
        year,
      ).where((e) => e.type == TransactionType.income).toList();

  List<FinanceTransaction> _aggregateExpensesForYear(int year) =>
      _aggregateForYear(
        year,
      ).where((e) => e.type == TransactionType.expense).toList();
}

// Mode and period selector widget
class _ModeAndPeriodSelector extends StatelessWidget {
  const _ModeAndPeriodSelector({
    required this.mode,
    required this.selected,
    required this.onModeChanged,
    required this.onPeriodChanged,
  });
  final PeriodMode mode;
  final DateTime selected;
  final void Function(PeriodMode) onModeChanged;
  final void Function(DateTime) onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        ToggleButtons(
          isSelected: [mode == PeriodMode.month, mode == PeriodMode.year],
          onPressed: (i) {
            final m = i == 0 ? PeriodMode.month : PeriodMode.year;
            onModeChanged(m);
          },
          borderRadius: BorderRadius.circular(24),
          selectedBorderColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.12),
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          selectedColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          constraints: const BoxConstraints(minHeight: 36),
          textStyle: Theme.of(context).textTheme.bodyMedium,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(l10n.monthly),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(l10n.yearly),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PeriodPickerButton(
            selected: selected,
            mode: mode,
            onChanged: onPeriodChanged,
          ),
        ),
      ],
    );
  }
}

class _PeriodPickerButton extends StatelessWidget {
  const _PeriodPickerButton({
    required this.selected,
    required this.mode,
    required this.onChanged,
  });
  final DateTime selected;
  final PeriodMode mode;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final label = mode == PeriodMode.month
        ? DateFormat.yMMMM(locale).format(selected)
        : DateFormat.y(locale).format(DateTime(selected.year));
    return FilledButton.icon(
      onPressed: () async {
        if (mode == PeriodMode.month) {
          final picked = await showCustomMonthPicker(
            context: context,
            initial: selected,
          );
          if (picked != null) onChanged(DateTime(picked.year, picked.month, 1));
        } else {
          final pickedYear = await showCustomYearPicker(
            context: context,
            initialYear: selected.year,
          );
          if (pickedYear != null) onChanged(DateTime(pickedYear, 1, 1));
        }
      },
      icon: const Icon(Icons.calendar_month),
      label: Text(label),
    );
  }
}

// Minimal month picker helper using showDatePicker but limited to months.
// This is a small convenience to pick a month (year+month) without day precision.
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
}) async {
  final first = DateTime(2000);
  final last = DateTime.now().add(const Duration(days: 365 * 5));
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: first,
    lastDate: last,
    helpText: 'Select month',
    fieldHintText: 'Month/Year',
    selectableDayPredicate: (d) => true,
  );
  if (picked == null) return null;
  return DateTime(picked.year, picked.month, 1);
}

// Custom month picker dialog: shows year selector and a grid of months
Future<DateTime?> showCustomMonthPicker({
  required BuildContext context,
  required DateTime initial,
}) async {
  int year = initial.year;
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => year = year - 1,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          year.toString(),
                          style: Theme.of(ctx).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(ctx).select,
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => year = year + 1,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.6,
                children: List.generate(12, (i) {
                  final m = i + 1;
                  final label = DateFormat.MMM(
                    Localizations.localeOf(ctx).toString(),
                  ).format(DateTime(year, m, 1));
                  final selected = (year == initial.year && m == initial.month);
                  return GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(DateTime(year, m, 1)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(ctx).colorScheme.primary
                            : Theme.of(ctx).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? Theme.of(ctx).colorScheme.primary
                              : Theme.of(ctx).dividerColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? Theme.of(ctx).colorScheme.onPrimary
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: Text(AppLocalizations.of(ctx).cancel),
                  ),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () => year = DateTime.now().year,
                        child: Text(AppLocalizations.of(ctx).select),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(DateTime.now()),
                        child: Text(AppLocalizations.of(ctx).select),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Custom year picker: simple dialog with a scrollable list of years
Future<int?> showCustomYearPicker({
  required BuildContext context,
  required int initialYear,
}) async {
  final minYear = 2000;
  final maxYear = 2053;
  final controller = ScrollController(
    initialScrollOffset: (initialYear - minYear) * 50.0,
  );
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppLocalizations.of(ctx).select,
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(maxYear - minYear + 1, (idx) {
                      final y = minYear + idx;
                      final selected = y == initialYear;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(ctx).pop(y),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(ctx).colorScheme.primary
                                : Theme.of(ctx).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(ctx).colorScheme.primary
                                  : Theme.of(ctx).dividerColor,
                            ),
                          ),
                          child: Text(
                            y.toString(),
                            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              color: selected
                                  ? Theme.of(ctx).colorScheme.onPrimary
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: Text(AppLocalizations.of(ctx).cancel),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
