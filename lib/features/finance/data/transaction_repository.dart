import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'transaction_model.dart';
import '../../gamification/gamification_repository.dart';

class TransactionRepository {
  static const _storageKey = 'finance_transactions_v1';

  final _controller = StreamController<List<FinanceTransaction>>.broadcast();
  List<FinanceTransaction> _items = const [];

  Stream<List<FinanceTransaction>> get stream => _controller.stream;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _items = FinanceTransaction.listFromJsonString(raw);
    }
    _emit();
  }

  Future<void> add(FinanceTransaction tx) async {
    _items = [..._items, tx];
    await _persist();
    // Gamification: grant XP for logging a transaction
    // Fire-and-forget; repository is independent.
    // ignore: unawaited_futures
    GamificationRepository.instance.onTransactionAdded(tx);
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> update(FinanceTransaction tx) async {
    _items = _items.map((e) => e.id == tx.id ? tx : e).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    _items = const [];
    await _persist();
  }

  List<FinanceTransaction> all() => List.unmodifiable(_items);

  List<FinanceTransaction> forMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(
      month.year,
      month.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));

    final result = <FinanceTransaction>[];
    for (final tx in _items) {
      if (tx.isRecurring) {
        // Generate a monthly occurrence series starting from anchor date.month/day
        final base = tx.date;
        // Determine months count to expand up to the target month
        // We only need to consider occurrences that may fall into [start, end]
        // Compute the month difference between start month and base month
        final diffMonths = _monthDiff(base, start);
        final beginIndex = diffMonths < 0
            ? 0
            : diffMonths; // first index >= start
        final lastIndex = _monthDiff(base, end);
        final endIndex = lastIndex < 0 ? -1 : lastIndex; // inclusive
        if (endIndex >= 0 && beginIndex <= endIndex) {
          final int limit = tx.recurringForever
              ? endIndex
              : ((tx.recurringMonths ?? 0) <= 0 ? -1 : tx.recurringMonths! - 1);
          if (limit < 0) {
            // No occurrences
            continue;
          }
          final int stop = endIndex <= limit ? endIndex : limit;
          for (int i = beginIndex; i <= stop; i++) {
            final occDate = _addMonthPreserveDay(base, i);
            if (occDate.isAfterOrOn(start) && occDate.isBeforeOrOn(end)) {
              result.add(
                FinanceTransaction(
                  id: '${tx.id}#m$i',
                  title: tx.title,
                  amount: tx.amount,
                  date: occDate,
                  type: tx.type,
                  categoryId: tx.categoryId,
                  isRecurring: true,
                  recurringForever: tx.recurringForever,
                  recurringMonths: tx.recurringMonths,
                  recurrenceId: tx.id,
                ),
              );
            }
          }
        }
      } else {
        if (tx.date.isAfterOrOn(start) && tx.date.isBeforeOrOn(end)) {
          result.add(tx);
        }
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  List<FinanceTransaction> incomesForMonth(DateTime month) =>
      forMonth(month).where((e) => e.type == TransactionType.income).toList();

  List<FinanceTransaction> expensesForMonth(DateTime month) =>
      forMonth(month).where((e) => e.type == TransactionType.expense).toList();

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      FinanceTransaction.listToJsonString(_items),
    );
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_items));

  void dispose() {
    _controller.close();
  }
}

extension _DateX on DateTime {
  bool isAfterOrOn(DateTime other) => isAfter(other) || isAtSameMomentAs(other);
  bool isBeforeOrOn(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);
}

int _monthDiff(DateTime a, DateTime b) {
  // returns how many whole months from a to b (b >= a => non-negative)
  return (b.year - a.year) * 12 + (b.month - a.month);
}

DateTime _addMonthPreserveDay(DateTime base, int monthsToAdd) {
  final y = base.year + ((base.month - 1 + monthsToAdd) ~/ 12);
  final m = (base.month - 1 + monthsToAdd) % 12 + 1;
  final d = base.day;
  // Clamp day to last day of target month
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
