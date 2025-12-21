import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../design_system/theme/theme_variations.dart';
import '../../design_system/tokens/colors.dart';
import 'data/transaction_model.dart';
import 'data/transaction_repository.dart';
import 'data/finance_category_repository.dart';
import 'data/finance_category.dart';

import 'data/budget_repository.dart';
import 'add_transaction_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key, this.variant});

  final ThemeVariant? variant;

  @override
  State<FinanceScreen> createState() => FinanceScreenState();
}

class FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late final TransactionRepository _repo;
  late final FinanceCategoryRepository _catRepo;
  late final BudgetRepository _budgetRepo;
  DateTime _currentMonth = DateTime.now();
  bool _loading = true;
  double? _plannedMonthlySpend;

  // Expose the currently selected month for global navigation actions
  DateTime get currentMonth => _currentMonth;

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
        DateTime(_currentMonth.year, _currentMonth.month, 1),
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
    // Build UI under a Builder so Theme override applies inside
    final ui = Builder(
      builder: (innerCtx) {
        final theme = Theme.of(innerCtx);
        final scheme = theme.colorScheme;
        // Compute monthly totals for each tab
        final monthIncomes = _loading
            ? const <FinanceTransaction>[]
            : _repo.incomesForMonth(_currentMonth);
        final monthExpenses = _loading
            ? const <FinanceTransaction>[]
            : _repo.expensesForMonth(_currentMonth);
        final incomeTotal = monthIncomes.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );
        final expenseTotal = monthExpenses.fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );
        final netTotal = incomeTotal - expenseTotal;
        final genelTotalStr = _loading
            ? ''
            : _formatAmount(netTotal.abs(), netTotal >= 0, context);
        final giderTotalStr = _loading
            ? ''
            : _formatAmount(expenseTotal, false, context);
        final gelirTotalStr = _loading
            ? ''
            : _formatAmount(incomeTotal, true, context);
        final genelColor = _loading
            ? scheme.onSurfaceVariant
            : netTotal > 0
            ? Colors.green
            : netTotal < 0
            ? Colors.redAccent
            : scheme.onSurfaceVariant;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openAddPageDefault,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).add),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
            body: Column(
              children: [
                // Floating-style tabbar similar to ProfileScreen's appearance.
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        // Use theme surface so TabBar adapts to selected theme and brightness
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // Slightly stronger shadow on light themes, subtler on dark
                            color: theme.brightness == Brightness.light
                                ? Colors.black.withOpacity(0.06)
                                : Colors.black.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2),
                      child: TabBar(
                        isScrollable: false,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(2),
                        overlayColor: WidgetStatePropertyAll(
                          scheme.primary.withValues(alpha: 0.06),
                        ),
                        labelColor: theme.brightness == Brightness.light
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                        unselectedLabelColor:
                            theme.brightness == Brightness.light
                            ? scheme.onSurfaceVariant
                            : scheme.onSurfaceVariant.withOpacity(0.8),
                        indicator: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tabs: [
                          Tab(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(context).general),
                                const SizedBox(height: 2),
                                Text(
                                  genelTotalStr,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: genelColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(context).expenseLabel),
                                const SizedBox(height: 2),
                                Text(
                                  giderTotalStr,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(context).incomeLabel),
                                const SizedBox(height: 2),
                                Text(
                                  gelirTotalStr,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_loading) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SpendingAdvisorCard(
                      month: _currentMonth,
                      budget: _plannedMonthlySpend,
                      spent: expenseTotal,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: TabBarView(
                    children: [
                      _loading
                          ? const _LoadingSection()
                          : _GeneralSection(
                              items: _repo.forMonth(_currentMonth),
                              catMap: {for (final c in _catRepo.all()) c.id: c},
                              onEdit: (tx) async {
                                // If this is a generated recurring instance, edit the base series
                                final baseId = tx.recurrenceId ?? tx.id;
                                final base = _repo.all().firstWhere(
                                  (e) => e.id == baseId,
                                  orElse: () => tx,
                                );
                                final res = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionScreen(
                                          type: base.type,
                                          repo: _repo,
                                          catRepo: _catRepo,
                                          variant: widget.variant,
                                          existing: base,
                                        ),
                                      ),
                                    );
                                if (res == true && mounted) setState(() {});
                              },
                              onDelete: (tx) async {
                                final ok = await _confirmDelete(context, tx);
                                if (ok) {
                                  final baseId = tx.recurrenceId ?? tx.id;
                                  await _repo.remove(baseId);
                                  if (mounted) setState(() {});
                                }
                              },
                            ),
                      _loading
                          ? const _LoadingSection()
                          : _ExpensesSection(
                              items: _repo.expensesForMonth(_currentMonth),
                              catMap: {for (final c in _catRepo.all()) c.id: c},
                              onEdit: (tx) async {
                                final baseId = tx.recurrenceId ?? tx.id;
                                final base = _repo.all().firstWhere(
                                  (e) => e.id == baseId,
                                  orElse: () => tx,
                                );
                                final res = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionScreen(
                                          type: base.type,
                                          repo: _repo,
                                          catRepo: _catRepo,
                                          variant: widget.variant,
                                          existing: base,
                                        ),
                                      ),
                                    );
                                if (res == true && mounted) setState(() {});
                              },
                              onDelete: (tx) async {
                                final ok = await _confirmDelete(context, tx);
                                if (ok) {
                                  final baseId = tx.recurrenceId ?? tx.id;
                                  await _repo.remove(baseId);
                                  if (mounted) setState(() {});
                                }
                              },
                            ),
                      _loading
                          ? const _LoadingSection()
                          : _IncomeSection(
                              items: _repo.incomesForMonth(_currentMonth),
                              catMap: {for (final c in _catRepo.all()) c.id: c},
                              onEdit: (tx) async {
                                final baseId = tx.recurrenceId ?? tx.id;
                                final base = _repo.all().firstWhere(
                                  (e) => e.id == baseId,
                                  orElse: () => tx,
                                );
                                final res = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionScreen(
                                          type: base.type,
                                          repo: _repo,
                                          catRepo: _catRepo,
                                          variant: widget.variant,
                                          existing: base,
                                        ),
                                      ),
                                    );
                                if (res == true && mounted) setState(() {});
                              },
                              onDelete: (tx) async {
                                final ok = await _confirmDelete(context, tx);
                                if (ok) {
                                  final baseId = tx.recurrenceId ?? tx.id;
                                  await _repo.remove(baseId);
                                  if (mounted) setState(() {});
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (isWorld) {
      final brightness = Theme.of(context).brightness;
      final themed = brightness == Brightness.dark
          ? ThemeVariations.dark(ThemeVariant.ocean)
          : ThemeVariations.light(ThemeVariant.ocean);
      return Theme(data: themed, child: ui);
    }
    return ui;
  }

  Future<void> _openAddPageDefault() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          type: TransactionType
              .expense, // default; kullanıcı sayfada değiştirebilir
          repo: _repo,
          catRepo: _catRepo,
          variant: widget.variant,
        ),
      ),
    );
    if (result == true && mounted) setState(() {});
  }

  // Exposed control for global AppBar action
  void selectCurrentMonth() {
    setState(() {
      final now = DateTime.now();
      _currentMonth = DateTime(now.year, now.month, 1);
      _plannedMonthlySpend = _budgetRepo.getBudgetForMonth(_currentMonth);
    });
  }

  // Popup month picker for global AppBar
  Future<void> showMonthPicker() async {
    final locale = Localizations.localeOf(context).toString();
    int pickerYear = _currentMonth.year;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final bool isWorld = widget.variant == ThemeVariant.world;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: AppLocalizations.of(context).previousYear,
                            onPressed: () =>
                                setSheetState(() => pickerYear -= 1),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            '$pickerYear',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            tooltip: AppLocalizations.of(context).nextYear,
                            onPressed: () =>
                                setSheetState(() => pickerYear += 1),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 2.2,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final selected =
                              pickerYear == _currentMonth.year &&
                              month == _currentMonth.month;
                          final label = DateFormat(
                            'MMMM',
                            locale,
                          ).format(DateTime(2000, month, 1));
                          return FilledButton.tonal(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                selected
                                    ? (isWorld
                                          ? AppColors.accentBlue.withValues(
                                              alpha: 0.18,
                                            )
                                          : scheme.primaryContainer)
                                    : scheme.surfaceContainerHighest,
                              ),
                              foregroundColor: WidgetStatePropertyAll(
                                selected
                                    ? (isWorld
                                          ? AppColors.accentBlue
                                          : scheme.onPrimaryContainer)
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            onPressed: () {
                              setState(
                                () => _currentMonth = DateTime(
                                  pickerYear,
                                  month,
                                  1,
                                ),
                              );
                              setState(() {
                                _plannedMonthlySpend = _budgetRepo
                                    .getBudgetForMonth(_currentMonth);
                              });
                              Navigator.pop(context);
                            },
                            child: Text(_capitalize(label)),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: isWorld
                              ? TextButton.styleFrom(
                                  foregroundColor: AppColors.accentBlue,
                                )
                              : null,
                          onPressed: () {
                            final now = DateTime.now();
                            setState(
                              () => _currentMonth = DateTime(
                                now.year,
                                now.month,
                                1,
                              ),
                            );
                            setState(() {
                              _plannedMonthlySpend = _budgetRepo
                                  .getBudgetForMonth(_currentMonth);
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.today_outlined),
                          label: Text(AppLocalizations.of(context).thisMonth),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

class _DayDivider extends StatelessWidget {
  final DateTime day;
  final String totalText;
  const _DayDivider({required this.day, required this.totalText});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localeName = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.E(localeName).format(day);
    final isPositive = totalText.trim().startsWith('+');
    final isNegative = totalText.trim().startsWith('-');
    // Slightly smaller and more subdued styles
    final baseStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500);
    final dateStyle = baseStyle?.copyWith(
      color: scheme.onSurfaceVariant.withValues(alpha: 0.80),
    );
    final totalColor = isPositive
        ? Colors.green.withValues(alpha: 0.85)
        : isNegative
        ? Colors.redAccent.withValues(alpha: 0.85)
        : scheme.onSurfaceVariant.withValues(alpha: 0.80);
    final totalStyle = baseStyle?.copyWith(color: totalColor);
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateLabel, style: dateStyle),
              Text(totalText, style: totalStyle),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(),
        ],
      ),
    );
  }
}

class _GeneralSection extends StatelessWidget {
  final List<FinanceTransaction> items;
  final Map<String, FinanceCategory> catMap;
  final ValueChanged<FinanceTransaction>? onEdit;
  final ValueChanged<FinanceTransaction>? onDelete;

  const _GeneralSection({
    required this.items,
    required this.catMap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptySection(
        message: AppLocalizations.of(context).noRecordsThisMonth,
      );
    }
    // Group by day and add a divider with the day's net total
    final dailyTotals = <String, double>{};
    for (final tx in items) {
      final key = _dateKey(tx.date);
      final sign = tx.type == TransactionType.income ? 1 : -1;
      dailyTotals.update(
        key,
        (v) => v + sign * tx.amount,
        ifAbsent: () => sign * tx.amount,
      );
    }
    final seen = <String>{};
    final children = <Widget>[];
    for (final tx in items) {
      final key = _dateKey(tx.date);
      if (!seen.contains(key)) {
        seen.add(key);
        final total = dailyTotals[key] ?? 0;
        final totalText = _formatAmount(total.abs(), total >= 0, context);
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        children.add(_DayDivider(day: day, totalText: totalText));
      }
      final isIncome = tx.type == TransactionType.income;
      final cat = tx.categoryId != null ? catMap[tx.categoryId!] : null;
      final icon =
          cat?.icon ?? (isIncome ? Icons.arrow_downward : Icons.arrow_upward);
      final color = cat != null
          ? Color(cat.colorValue)
          : (isIncome ? Colors.green : Colors.redAccent);
      final amountStr = _formatAmount(tx.amount, isIncome, context);
      children.add(
        _FinanceTile(
          leadingIcon: icon,
          leadingEmoji: cat?.emoji,
          leadingColor: color,
          title: tx.title,
          subtitle: null,
          trailing: amountStr,
          trailingColor: isIncome ? Colors.green : Colors.redAccent,
          onLongPress: () => _showTxMenu(context, tx),
        ),
      );
    }
    return ListView(padding: const EdgeInsets.all(16), children: children);
  }

  void _showTxMenu(BuildContext context, FinanceTransaction tx) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(AppLocalizations.of(context).edit),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call(tx);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call(tx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String _formatAmount(double amount, bool isIncome, [BuildContext? context]) {
  final sign = isIncome ? '+' : '-';
  final localeName = context != null
      ? Localizations.localeOf(context).toString()
      : Intl.getCurrentLocale();
  final currency = NumberFormat.simpleCurrency(locale: localeName);
  final symbol = currency.currencySymbol;
  // Build a number-only string in the current locale, then append the symbol.
  final numberOnly = NumberFormat.currency(
    locale: localeName,
    symbol: '',
  ).format(amount).trim().replaceAll('-', '');
  return '$sign$numberOnly $symbol';
}

class _FinanceTile extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingColor;
  final String? leadingEmoji; // If provided, show emoji instead of icon
  final String? title;
  final String? subtitle;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback? onLongPress;

  const _FinanceTile({
    required this.leadingIcon,
    required this.leadingColor,
    this.leadingEmoji,
    this.title,
    this.subtitle,
    this.trailing,
    this.trailingColor,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          // Removed onLongPress from ListTile so InkWell controls the splash
          leading: (leadingEmoji != null && leadingEmoji!.isNotEmpty)
              ? Text(leadingEmoji!, style: const TextStyle(fontSize: 20))
              : Icon(leadingIcon, color: leadingColor),
          title: Text(title ?? ''),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: Text(
            trailing ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: trailingColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}

class _ExpensesSection extends StatelessWidget {
  final List<FinanceTransaction> items;
  final Map<String, FinanceCategory> catMap;
  final ValueChanged<FinanceTransaction>? onEdit;
  final ValueChanged<FinanceTransaction>? onDelete;

  const _ExpensesSection({
    required this.items,
    required this.catMap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptySection(
        message: AppLocalizations.of(context).noExpensesThisMonth,
      );
    }
    // Group by day and add daily expense totals
    final dailyTotals = <String, double>{};
    for (final tx in items) {
      final key = _dateKey(tx.date);
      dailyTotals.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    final seen = <String>{};
    final children = <Widget>[];
    for (final tx in items) {
      final key = _dateKey(tx.date);
      if (!seen.contains(key)) {
        seen.add(key);
        final total = dailyTotals[key] ?? 0;
        children.add(
          _DayDivider(
            day: DateTime(tx.date.year, tx.date.month, tx.date.day),
            totalText: _formatAmount(total, false, context),
          ),
        );
      }
      final cat = tx.categoryId != null ? catMap[tx.categoryId!] : null;
      children.add(
        _FinanceTile(
          leadingIcon: cat?.icon ?? Icons.arrow_upward,
          leadingEmoji: cat?.emoji,
          leadingColor: cat != null ? Color(cat.colorValue) : Colors.redAccent,
          title: tx.title,
          subtitle: null,
          trailing: _formatAmount(tx.amount, false, context),
          trailingColor: Colors.redAccent,
          onLongPress: () => _showTxMenu(context, tx),
        ),
      );
    }
    return ListView(padding: const EdgeInsets.all(16), children: children);
  }

  void _showTxMenu(BuildContext context, FinanceTransaction tx) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(AppLocalizations.of(context).edit),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call(tx);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call(tx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SpendingAdvisorCard extends StatelessWidget {
  const _SpendingAdvisorCard({
    required this.month,
    required this.budget,
    required this.spent,
  });
  final DateTime month;
  final double? budget;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final nf = NumberFormat.simpleCurrency(
      locale: localeName,
      decimalDigits: 0,
    );

    // Calculate days remaining
    final now = DateTime.now();
    final isCurrentMonth = now.year == month.year && now.month == month.month;

    if (!isCurrentMonth) {
      return const SizedBox.shrink();
    }

    Color iconColor;
    Color bgColor;
    IconData icon;
    String message;

    if (budget == null || budget! <= 0) {
      iconColor = Theme.of(context).colorScheme.primary;
      bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      icon = Icons.help_outline_rounded;
      message = l10n.spendingAdvisorNoBudget;
    } else {
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final daysLeft = endOfMonth.day - now.day + 1; // Include today
      final remaining = budget! - spent;

      if (remaining < 0) {
        // Already over budget
        iconColor = Theme.of(context).colorScheme.error;
        bgColor = Theme.of(context).colorScheme.errorContainer;
        icon = Icons.warning_amber_rounded;
        message = l10n.spendingAdvisorOverBudget;
      } else {
        final dailySafe = remaining / daysLeft;

        iconColor = const Color(0xFF2E7D32); // Success Green
        bgColor = const Color(0xFFE8F5E9); // Light Green
        icon = Icons.tips_and_updates_outlined;

        message = l10n.spendingAdvisorSafe(nf.format(dailySafe));
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.spendingAdvisorTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
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

class _IncomeSection extends StatelessWidget {
  final List<FinanceTransaction> items;
  final Map<String, FinanceCategory> catMap;
  final ValueChanged<FinanceTransaction>? onEdit;
  final ValueChanged<FinanceTransaction>? onDelete;

  const _IncomeSection({
    required this.items,
    required this.catMap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptySection(
        message: AppLocalizations.of(context).noIncomeThisMonth,
      );
    }
    // Group by day and add daily income totals
    final dailyTotals = <String, double>{};
    for (final tx in items) {
      final key = _dateKey(tx.date);
      dailyTotals.update(key, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    final seen = <String>{};
    final children = <Widget>[];
    for (final tx in items) {
      final key = _dateKey(tx.date);
      if (!seen.contains(key)) {
        seen.add(key);
        final total = dailyTotals[key] ?? 0;
        children.add(
          _DayDivider(
            day: DateTime(tx.date.year, tx.date.month, tx.date.day),
            totalText: _formatAmount(total, true, context),
          ),
        );
      }
      final cat = tx.categoryId != null ? catMap[tx.categoryId!] : null;
      children.add(
        _FinanceTile(
          leadingIcon: cat?.icon ?? Icons.arrow_downward,
          leadingEmoji: cat?.emoji,
          leadingColor: cat != null ? Color(cat.colorValue) : Colors.green,
          title: tx.title,
          subtitle: null,
          trailing: _formatAmount(tx.amount, true, context),
          trailingColor: Colors.green,
          onLongPress: () => _showTxMenu(context, tx),
        ),
      );
    }
    return ListView(padding: const EdgeInsets.all(16), children: children);
  }

  void _showTxMenu(BuildContext context, FinanceTransaction tx) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(AppLocalizations.of(context).edit),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call(tx);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(context).delete,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call(tx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    ),
  );
}

Future<bool> _confirmDelete(BuildContext context, FinanceTransaction tx) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context).delete),
          content: Text(
            AppLocalizations.of(context).deleteTransactionConfirm(tx.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red[600]),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context).delete),
            ),
          ],
        ),
      ) ??
      false;
}
