import '../../core/utils/emoji_presets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/finance_category.dart';
import 'data/finance_category_repository.dart';
import 'data/transaction_model.dart';
import 'data/transaction_repository.dart';
import '../../design_system/theme/theme_variations.dart';
import '../../l10n/app_localizations.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    required this.type,
    required this.repo,
    required this.catRepo,
    this.variant,
    this.existing,
  });

  final TransactionType type;
  final TransactionRepository repo;
  final FinanceCategoryRepository catRepo;
  final ThemeVariant? variant;
  // If provided, screen works in edit mode
  final FinanceTransaction? existing;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type;
  FinanceCategory? _selectedCategory;
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  // Recurring controls
  bool _isRecurring = false;
  bool _recurringForever = true;
  int _recurringMonths = 12; // default 12 months when not forever

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final tx = widget.existing!;
      _type = tx.type;
      _selectedDate = tx.date;
      _titleCtrl.text = tx.title;
      _isRecurring = tx.isRecurring;
      _recurringForever = tx.recurringForever;
      _recurringMonths = tx.recurringMonths ?? _recurringMonths;
    } else {
      _type = widget.type;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _selectedCategory != null && _parsedAmount() > 0;

  double _parsedAmount() {
    final localeName = Localizations.localeOf(context).toString();
    final raw = _amountCtrl.text.trim();
    try {
      final num parsed = NumberFormat.decimalPattern(localeName).parse(raw);
      return parsed.toDouble();
    } catch (_) {
      // Fallback: permissive parse by normalizing non-digit separators
      final normalized = raw
          .replaceAll(RegExp('[^0-9.,-]'), '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == TransactionType.income;
    final isEdit = widget.existing != null;
    final l10n = AppLocalizations.of(context);
    final title = isEdit
        ? (isIncome ? l10n.incomeEditTitle : l10n.expenseEditTitle)
        : (isIncome ? l10n.incomeNewTitle : l10n.expenseNewTitle);
    final localeName = Localizations.localeOf(context).toString();
    final currencyFmt = NumberFormat.simpleCurrency(locale: localeName);
    final currencySymbol = currencyFmt.currencySymbol;
    final dateLabel = DateFormat.yMMMd(localeName).format(_selectedDate);
    final isWorld = widget.variant == ThemeVariant.world;
    final scaffold = Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type toggle (optional)
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.expense,
                icon: Icon(Icons.remove_circle_outline),
                label: Text(l10n.expenseLabel),
              ),
              ButtonSegment(
                value: TransactionType.income,
                icon: Icon(Icons.add_circle_outline),
                label: Text(l10n.incomeLabel),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() {
              _type = s.first;
              // Reset category if type changes
              _selectedCategory = null;
            }),
          ),
          const SizedBox(height: 16),
          Text(l10n.category, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<FinanceCategory>>(
            future: Future.value(widget.catRepo.byType(_type)),
            builder: (context, snapshot) {
              final cats = snapshot.data ?? widget.catRepo.byType(_type);
              // Initialize selected category and amount for edit once
              if (widget.existing != null && _selectedCategory == null) {
                if (cats.isNotEmpty) {
                  _selectedCategory = cats.firstWhere(
                    (c) => c.id == widget.existing!.categoryId,
                    orElse: () => cats.first,
                  );
                }
                if (_amountCtrl.text.isEmpty) {
                  _amountCtrl.text = NumberFormat.decimalPattern(
                    Localizations.localeOf(context).toString(),
                  ).format(widget.existing!.amount);
                }
              }
              return _CategoryGrid(
                categories: cats,
                selected: _selectedCategory,
                onSelect: (c) => setState(() => _selectedCategory = c),
                onLongPress: (c) => _showCategoryActions(context, c),
                onCreateNew: () async {
                  final newCat = await _createNewCategory(context, _type);
                  if (newCat != null) {
                    setState(() => _selectedCategory = newCat);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l10n.titleOptional,
              hintText: l10n.titleHint,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(l10n.date),
            subtitle: Text(dateLabel),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                helpText: l10n.selectDate,
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.amountLabel,
              prefixText: '$currencySymbol ',
              helperText: _amountCtrl.text.isEmpty
                  ? null
                  : currencyFmt.format(_parsedAmount()),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          // Minimal recurring section card
          Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              final locale = Localizations.localeOf(context).toString();
              final nextDates = [
                _addMonthPreserveDay(_selectedDate, 1),
                _addMonthPreserveDay(_selectedDate, 2),
                _addMonthPreserveDay(_selectedDate, 3),
              ];
              String fmt(DateTime d) => DateFormat('d MMM', locale).format(d);
              final preview = nextDates.map(fmt).join(', ');
              final durationSummary = _recurringForever
                  ? 'Süresiz'
                  : '${_recurringMonths} ay';
              return Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.repeat,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.recurringMonthlyTitle,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.recurringMonthlyDesc,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isRecurring,
                          onChanged: (v) => setState(() => _isRecurring = v),
                        ),
                      ],
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final res = await _pickDuration(
                            context,
                            _recurringForever,
                            _recurringMonths,
                          );
                          if (res != null) {
                            setState(() {
                              _recurringForever = res['forever'] as bool;
                              _recurringMonths = (res['months'] as int).clamp(
                                1,
                                360,
                              );
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                l10n.duration,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Text(
                                durationSummary,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.nextLabel}: $preview',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: Text(isEdit ? l10n.update : l10n.save),
          ),
        ],
      ),
    );
    if (isWorld) {
      final brightness = Theme.of(context).brightness;
      final themed = brightness == Brightness.dark
          ? ThemeVariations.dark(ThemeVariant.ocean)
          : ThemeVariations.light(ThemeVariant.ocean);
      return Theme(data: themed, child: scaffold);
    }
    return scaffold;
  }

  Future<FinanceCategory?> _createNewCategory(
    BuildContext context,
    TransactionType type,
  ) async {
    final nameCtrl = TextEditingController();
    String? selectedEmoji;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Localize with bottom sheet context
                  Text(
                    AppLocalizations.of(ctx).newCategory,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).categoryName,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(ctx).chooseEmoji.replaceAll(':', ''),
                  ),
                  const SizedBox(height: 8),
                  _EmojiGrid(
                    selectedEmoji: selectedEmoji,
                    onSelect: (e) => setSheetState(() => selectedEmoji = e),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).customEmojiOptional,
                      hintText: '🍔',
                    ),
                    onChanged: (v) => setSheetState(() {
                      selectedEmoji = v.trim().isEmpty
                          ? selectedEmoji
                          : v.trim();
                    }),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty ||
                            (selectedEmoji == null || selectedEmoji!.isEmpty)) {
                          Navigator.pop(ctx, false);
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      child: Text(AppLocalizations.of(ctx).create),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (created == true) {
      final cat = FinanceCategory(
        id: 'user_${DateTime.now().microsecondsSinceEpoch}',
        name: nameCtrl.text.trim(),
        iconCodePoint: Icons.category.codePoint,
        emoji: selectedEmoji,
        type: type,
        colorValue:
            (type == TransactionType.income ? Colors.green : Colors.red).value,
      );
      await widget.catRepo.add(cat);
      return cat;
    }
    return null;
  }

  Future<void> _showCategoryActions(
    BuildContext context,
    FinanceCategory cat,
  ) async {
    await showModalBottomSheet(
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
              title: Text(AppLocalizations.of(ctx).editCategory),
              onTap: () {
                Navigator.pop(ctx);
                _editCategory(context, cat);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[600]),
              title: Text(
                AppLocalizations.of(ctx).deleteCategoryTitle,
                style: TextStyle(color: Colors.red[600]),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed =
                    await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: Text(AppLocalizations.of(dctx).delete),
                        content: Text(
                          AppLocalizations.of(
                            dctx,
                          ).deleteCategoryConfirmNamed(cat.name),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dctx, false),
                            child: Text(AppLocalizations.of(dctx).cancel),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red[600],
                            ),
                            onPressed: () => Navigator.pop(dctx, true),
                            child: Text(AppLocalizations.of(dctx).delete),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmed) {
                  await widget.catRepo.remove(cat.id);
                  if (_selectedCategory?.id == cat.id) {
                    setState(() => _selectedCategory = null);
                  } else {
                    setState(() {});
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editCategory(BuildContext context, FinanceCategory cat) async {
    final nameCtrl = TextEditingController(text: cat.name);
    String? selectedEmoji = cat.emoji;
    int selectedIcon = cat.iconCodePoint;
    Color selectedColor = Color(cat.colorValue);

    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(ctx).editCategory,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).categoryName,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(ctx).chooseEmoji.replaceAll(':', ''),
                  ),
                  const SizedBox(height: 8),
                  _EmojiGrid(
                    selectedEmoji: selectedEmoji,
                    onSelect: (e) => setSheetState(() {
                      selectedEmoji = e;
                      selectedIcon = Icons.category.codePoint;
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).customEmojiOptional,
                      hintText: '🍔',
                    ),
                    controller: TextEditingController(
                      text: selectedEmoji ?? '',
                    ),
                    onChanged: (v) => setSheetState(() {
                      selectedEmoji = v.trim();
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(ctx).chooseColor.replaceAll(':', ''),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in [
                        Colors.red,
                        Colors.orange,
                        Colors.amber,
                        Colors.yellow,
                        Colors.green,
                        Colors.teal,
                        Colors.blue,
                        Colors.indigo,
                        Colors.purple,
                        Colors.brown,
                        Colors.blueGrey,
                        Colors.grey,
                      ])
                        GestureDetector(
                          onTap: () => setSheetState(() => selectedColor = c),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == c
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) {
                          Navigator.pop(ctx, false);
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      child: Text(AppLocalizations.of(ctx).update),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (updated == true) {
      final newCat = FinanceCategory(
        id: cat.id,
        name: nameCtrl.text.trim(),
        iconCodePoint: selectedIcon,
        emoji: selectedEmoji,
        type: cat.type,
        colorValue: selectedColor.value,
      );
      await widget.catRepo.update(newCat);
      if (_selectedCategory?.id == cat.id) {
        setState(() => _selectedCategory = newCat);
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final baseTitle = (_titleCtrl.text.trim().isEmpty)
        ? _selectedCategory!.name
        : _titleCtrl.text.trim();
    if (widget.existing != null) {
      final updated = widget.existing!.copyWith(
        title: baseTitle,
        amount: _parsedAmount(),
        date: _selectedDate,
        type: _type,
        categoryId: _selectedCategory!.id,
        isRecurring: _isRecurring,
        recurringForever: _recurringForever,
        recurringMonths: _recurringForever ? null : _recurringMonths,
      );
      await widget.repo.update(updated);
    } else {
      final tx = FinanceTransaction(
        id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
        title: baseTitle,
        amount: _parsedAmount(),
        date: _selectedDate,
        type: _type,
        categoryId: _selectedCategory!.id,
        isRecurring: _isRecurring,
        recurringForever: _recurringForever,
        recurringMonths: _recurringForever ? null : _recurringMonths,
      );
      await widget.repo.add(tx);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<Map<String, dynamic>?> _pickDuration(
    BuildContext context,
    bool currentForever,
    int currentMonths,
  ) async {
    bool tempForever = currentForever;
    int tempMonths = currentMonths.clamp(1, 360);
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).durationSelection,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Center(
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment<bool>(
                        value: true,
                        icon: const Icon(Icons.all_inclusive),
                        label: Text(AppLocalizations.of(context).forever),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(AppLocalizations.of(context).fixedDuration),
                      ),
                    ],
                    selected: {tempForever},
                    onSelectionChanged: (s) => setSheetState(() {
                      tempForever = s.first;
                    }),
                  ),
                ),
                if (!tempForever) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context).monthCount,
                            hintText: AppLocalizations.of(
                              context,
                            ).monthCountHint,
                            suffixText: AppLocalizations.of(
                              context,
                            ).monthSuffixShort,
                            helperText: AppLocalizations.of(
                              context,
                            ).between1And360,
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: '$tempMonths',
                          ),
                          onChanged: (v) {
                            final p = int.tryParse(v) ?? tempMonths;
                            setSheetState(() => tempMonths = p.clamp(1, 360));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, null),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, {
                        'forever': tempForever,
                        'months': tempForever
                            ? currentMonths.clamp(1, 360)
                            : tempMonths,
                      }),
                      child: Text(AppLocalizations.of(context).save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper: add months, clamp to month end while preserving time components
  DateTime _addMonthPreserveDay(DateTime base, int monthsToAdd) {
    final y = base.year + ((base.month - 1 + monthsToAdd) ~/ 12);
    final m = (base.month - 1 + monthsToAdd) % 12 + 1;
    final d = base.day;
    final lastDay = DateTime(y, m + 1, 0).day;
    final targetDay = d.clamp(1, lastDay);
    return DateTime(
      y,
      m,
      targetDay,
      base.hour,
      base.minute,
      base.second,
      base.millisecond,
      base.microsecond,
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.onLongPress,
    required this.onCreateNew,
  });

  final List<FinanceCategory> categories;
  final FinanceCategory? selected;
  final ValueChanged<FinanceCategory> onSelect;
  final ValueChanged<FinanceCategory>? onLongPress;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in categories)
          GestureDetector(
            onLongPress: () => onLongPress?.call(c),
            child: ChoiceChip(
              selected: selected?.id == c.id,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (c.hasEmoji)
                    Text(c.emoji!, style: const TextStyle(fontSize: 16))
                  else
                    Icon(c.icon, size: 16, color: Color(c.colorValue)),
                  const SizedBox(width: 6),
                  Text(c.name),
                ],
              ),
              onSelected: (_) => onSelect(c),
            ),
          ),
        ActionChip(
          label: Text(AppLocalizations.of(context).newCategory),
          avatar: const Icon(Icons.add),
          onPressed: onCreateNew,
        ),
      ],
    );
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
        // Target tile width incl. spacing
        const tileSize = 44.0;
        const spacing = 8.0;
        // Compute max columns that fit, ensure at least 4
        int cols = ((constraints.maxWidth + spacing) / (tileSize + spacing))
            .floor();
        cols = cols.clamp(4, 12);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Keep grid centered by constraining width to an integer number of columns
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
