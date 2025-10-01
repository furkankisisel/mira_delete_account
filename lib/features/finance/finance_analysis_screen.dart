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
    final titleStr = DateFormat.yMMMM(
      locale,
    ).format(DateTime(widget.month.year, widget.month.month, 1));

    final incomes = _loading
        ? const <FinanceTransaction>[]
        : _repo.incomesForMonth(widget.month);
    final expenses = _loading
        ? const <FinanceTransaction>[]
        : _repo.expensesForMonth(widget.month);
    final allTx = _loading
        ? const <FinanceTransaction>[]
        : _repo.forMonth(widget.month);

    final incomeTotal = incomes.fold<double>(0, (s, e) => s + e.amount);
    final expenseTotal = expenses.fold<double>(0, (s, e) => s + e.amount);
    final net = incomeTotal - expenseTotal;

    // Previous month comparison
    final prevMonth = DateTime(widget.month.year, widget.month.month - 1, 1);
    final prevIncomeTotal = _loading
        ? 0.0
        : _repo
              .incomesForMonth(prevMonth)
              .fold<double>(0, (s, e) => s + e.amount);
    final prevExpenseTotal = _loading
        ? 0.0
        : _repo
              .expensesForMonth(prevMonth)
              .fold<double>(0, (s, e) => s + e.amount);

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
                    month: widget.month,
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
                    label: 'Net',
                    value: _formatCurrency(context, net),
                    color: net >= 0 ? Colors.green : Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  // Removed delta chips (income/expense changes) as requested
                  Text(
                    AppLocalizations.of(context).monthlyTrend,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _MonthlyTrendChart(month: widget.month, transactions: allTx),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).expenseDistributionPie,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ExpensePieChart(
                    month: widget.month,
                    repo: _repo,
                    catRepo: _catRepo,
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
                    month: widget.month,
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
    final txs = _repo
        .expensesForMonth(widget.month)
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
    final l10n = AppLocalizations.of(context);
    final firstDay = DateTime(widget.month.year, widget.month.month, 1);
    final end = DateTime(
      widget.month.year,
      widget.month.month + 1,
      1,
    ).subtract(const Duration(days: 1));
    final daysInMonth = end.day;

    final planned = _parseNumeric(_controller.text);
    final perDay = (planned != null && planned > 0)
        ? planned / daysInMonth
        : null;

    // Month-to-date spend and average per day so far
    final today = DateTime.now();
    final isSameMonth =
        today.year == widget.month.year && today.month == widget.month.month;
    final upToDay = isSameMonth ? today.day : daysInMonth;
    final mtdExpenses = widget.repo
        .expensesForMonth(widget.month)
        .where(
          (e) =>
              e.date.isAfter(firstDay.subtract(const Duration(days: 1))) &&
              e.date.isBefore(
                DateTime(widget.month.year, widget.month.month, upToDay + 1),
              ),
        )
        .fold<double>(0, (s, e) => s + e.amount);
    final mtdAvgPerDay = upToDay > 0 ? (mtdExpenses / upToDay) : 0.0;

    // Today's remaining = perDay - today's expenses (only when current month)
    final todayExpenses = isSameMonth
        ? widget.repo
              .expensesForMonth(widget.month)
              .where(
                (e) =>
                    e.date.year == today.year &&
                    e.date.month == today.month &&
                    e.date.day == today.day,
              )
              .fold<double>(0, (s, e) => s + e.amount)
        : 0.0;
    final todayRemaining = perDay != null && isSameMonth
        ? (perDay - todayExpenses)
        : null;

    // String commentary() {
    //   if (perDay == null) return 'Aylık plan girin, günlük limit hesaplayalım.';
    //   final diff = perDay - mtdAvgPerDay;
    //   if (diff.abs() < 0.01) return 'Günlük limitte ilerliyorsunuz.';
    //   if (diff > 0) {
    //     return 'Harika! Günlük ortalama ${diff.toStringAsFixed(0)} daha az harcıyorsunuz.';
    //   } else {
    //     return 'Dikkat! Günlük ortalama ${(diff.abs()).toStringAsFixed(0)} fazla harcıyorsunuz.';
    //   }
    // }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).savingsBudgetPlan,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 420;
              final field = TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsFormatter(() => _groupFormat),
                ],
                decoration: InputDecoration(
                  labelText: l10n.plannedMonthlySpend,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              );
              final saveBtn = FilledButton.icon(
                onPressed: () async {
                  final v = _parseNumeric(_controller.text);
                  if (v == null || v <= 0) return;
                  await widget.onSave(v);
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.save),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [field, const SizedBox(height: 8), saveBtn],
                );
              }
              return Row(
                children: [
                  Expanded(child: field),
                  const SizedBox(width: 8),
                  saveBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          if (perDay != null)
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_view_day,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppLocalizations.of(context).dailyLimit}: ${perDay.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                Text(
                  '${AppLocalizations.of(context).mtdAverageShort}: ${mtdAvgPerDay.toStringAsFixed(0)}',
                ),
                if (todayRemaining != null)
                  Text(
                    '${AppLocalizations.of(context).remainingToday}: ${todayRemaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: todayRemaining >= 0
                          ? Colors.green
                          : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 6),
          // Use a local promoted variable to avoid unnecessary non-null assertions
          Builder(
            builder: (context) {
              final pd = perDay; // double?
              final color = pd == null
                  ? Theme.of(context).colorScheme.onSurface
                  : (mtdAvgPerDay <= pd ? Colors.green : Colors.redAccent);
              return Text(
                _commentaryLocalized(context, perDay, mtdAvgPerDay),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
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
    required this.repo,
    required this.catRepo,
    this.onSelect,
  });
  final DateTime month;
  final TransactionRepository repo;
  final FinanceCategoryRepository catRepo;
  final void Function(String? categoryId)? onSelect;

  @override
  Widget build(BuildContext context) {
    final cats = {for (final c in catRepo.all()) c.id: c};
    final txs = repo.forMonth(month);

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

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({
    required this.month,
    required this.repo,
    required this.catRepo,
    this.onSelect,
  });
  final DateTime month;
  final TransactionRepository repo;
  final FinanceCategoryRepository catRepo;
  final void Function(String? categoryId)? onSelect;

  @override
  Widget build(BuildContext context) {
    final cats = {for (final c in catRepo.all()) c.id: c};
    final expenses = repo.expensesForMonth(month);
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
    var idx = 0;
    for (final e in entries) {
      final isOther = e.key == '_none';
      final cat = isOther ? null : cats[e.key];
      final color = isOther
          ? Theme.of(context).colorScheme.primary
          : _colorForEmoji(cat?.emoji, cat?.type);
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
                            color: e.key == '_none'
                                ? Theme.of(context).colorScheme.primary
                                : _colorForEmoji(
                                    cats[e.key]?.emoji,
                                    cats[e.key]?.type,
                                  ),
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
