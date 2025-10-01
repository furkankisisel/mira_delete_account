import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'finance_category.dart';
import 'transaction_model.dart';

class FinanceCategoryRepository {
  static const _storageKey = 'finance_categories_v1';

  final _controller = StreamController<List<FinanceCategory>>.broadcast();
  List<FinanceCategory> _items = const [];

  Stream<List<FinanceCategory>> get stream => _controller.stream;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      _items = list.map(FinanceCategory.fromJson).toList();
      bool mutated = false;
      // Migration A: rename legacy 'Faiz' income category to 'Burs' and update icon
      _items = _items.map((c) {
        final isLegacyInterest =
            c.type == TransactionType.income &&
            (c.id == 'inc_interest' || c.name == 'Faiz');
        if (isLegacyInterest) {
          mutated = true;
          return FinanceCategory(
            id: c.id, // keep id to preserve existing transaction references
            name: 'Burs',
            iconCodePoint: Icons.school_outlined.codePoint,
            type: c.type,
            colorValue: c.colorValue,
          );
        }
        return c;
      }).toList();
      // Migration B: assign colors to categories that were created before color support (grey default)
      final needsColor = _items.any((c) => c.colorValue == Colors.grey.value);
      if (needsColor) {
        _assignColorsIfMissing();
        mutated = true;
      }
      // Migration C: add default emojis if missing
      final withMissingEmoji = _items.any(
        (c) => !(c.emoji != null && c.emoji!.isNotEmpty),
      );
      if (withMissingEmoji) {
        _items = _items.map((c) {
          if (c.emoji != null && c.emoji!.isNotEmpty) return c;
          // simple heuristic mapping by common names
          String? e;
          final n = c.name.toLowerCase();
          if (n.contains('yemek') ||
              n.contains('restoran') ||
              n.contains('fast')) {
            e = '🍽️';
          } else if (n.contains('kahve') || n.contains('çay'))
            e = '☕';
          else if (n.contains('alış') ||
              n.contains('market') ||
              n.contains('mağaza'))
            e = '🛍️';
          else if (n.contains('ulaş') ||
              n.contains('otobüs') ||
              n.contains('minibüs') ||
              n.contains('metro'))
            e = '🚌';
          else if (n.contains('taksi'))
            e = '🚕';
          else if (n.contains('oyun'))
            e = '🎮';
          else if (n.contains('ev') || n.contains('kira'))
            e = '🏠';
          else if (n.contains('sağlık') || n.contains('ilaç'))
            e = '💊';
          else if (n.contains('okul') || n.contains('burs'))
            e = '🎓';
          else if (n.contains('maaş') || n.contains('gelir'))
            e = '💼';
          else if (n.contains('para') || n.contains('nakit'))
            e = '💵';
          else if (n.contains('fatura') ||
              n.contains('fiş') ||
              n.contains('makbuz'))
            e = '🧾';
          return FinanceCategory(
            id: c.id,
            name: c.name,
            iconCodePoint: c.iconCodePoint,
            emoji: e,
            type: c.type,
            colorValue: c.colorValue,
          );
        }).toList();
        mutated = true;
      }
      if (mutated) {
        await _persist();
      }
    } else {
      // Seed defaults for both types with randomized colors (first run only)
      final palette = <Color>[
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.blue,
        Colors.lightBlue,
        Colors.cyan,
        Colors.teal,
        Colors.green,
        Colors.lightGreen,
        Colors.lime,
        Colors.amber,
        Colors.orange,
        Colors.deepOrange,
        Colors.brown,
        Colors.blueGrey,
        Colors.grey,
      ];
      final rng = Random();
      final shuffled = [...palette]..shuffle(rng);
      var idx = 0;
      Color nextColor() {
        if (idx >= shuffled.length) {
          shuffled.shuffle(rng);
          idx = 0;
        }
        return shuffled[idx++];
      }

      _items = [
        FinanceCategory(
          id: 'exp_food',
          name: 'Yemek',
          iconCodePoint: Icons.restaurant.codePoint,
          emoji: '🍽️',
          type: TransactionType.expense,
          colorValue: nextColor().value,
        ),
        FinanceCategory(
          id: 'exp_transport',
          name: 'Ulaşım',
          iconCodePoint: Icons.directions_bus.codePoint,
          emoji: '🚌',
          type: TransactionType.expense,
          colorValue: nextColor().value,
        ),
        FinanceCategory(
          id: 'exp_coffee',
          name: 'Kahve',
          iconCodePoint: Icons.coffee.codePoint,
          emoji: '☕',
          type: TransactionType.expense,
          colorValue: nextColor().value,
        ),
        FinanceCategory(
          id: 'exp_shopping',
          name: 'Alışveriş',
          iconCodePoint: Icons.shopping_bag.codePoint,
          emoji: '🛍️',
          type: TransactionType.expense,
          colorValue: nextColor().value,
        ),
        FinanceCategory(
          id: 'inc_salary',
          name: 'Maaş',
          iconCodePoint: Icons.payments.codePoint,
          emoji: '💼',
          type: TransactionType.income,
          colorValue: nextColor().value,
        ),
        FinanceCategory(
          id: 'inc_freelance',
          name: 'Serbest',
          iconCodePoint: Icons.work_outline.codePoint,
          emoji: '💵',
          type: TransactionType.income,
          colorValue: nextColor().value,
        ),
        FinanceCategory(
          id: 'inc_scholarship',
          name: 'Burs',
          iconCodePoint: Icons.school_outlined.codePoint,
          emoji: '🎓',
          type: TransactionType.income,
          colorValue: nextColor().value,
        ),
      ];
      await _persist();
    }
    _emit();
  }

  void _assignColorsIfMissing() {
    final rng = Random();
    Color pick(List<Color> palette, Set<int> used) {
      final candidates = palette.where((c) => !used.contains(c.value)).toList();
      if (candidates.isEmpty) return palette[rng.nextInt(palette.length)];
      return candidates[rng.nextInt(candidates.length)];
    }

    final expensePalette = <Color>[
      Colors.red,
      Colors.deepOrange,
      Colors.orange,
      Colors.amber,
      Colors.pink,
      Colors.purple,
      Colors.brown,
      Colors.blueGrey,
    ];
    final incomePalette = <Color>[
      Colors.green,
      Colors.lightGreen,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.indigo,
      Colors.lime,
    ];

    final expenseUsed = _items
        .where(
          (c) =>
              c.type == TransactionType.expense &&
              c.colorValue != Colors.grey.value,
        )
        .map((c) => c.colorValue)
        .toSet();
    final incomeUsed = _items
        .where(
          (c) =>
              c.type == TransactionType.income &&
              c.colorValue != Colors.grey.value,
        )
        .map((c) => c.colorValue)
        .toSet();

    _items = _items.map((c) {
      if (c.colorValue != Colors.grey.value) return c;
      if (c.type == TransactionType.expense) {
        final color = pick(expensePalette, expenseUsed);
        expenseUsed.add(color.value);
        return FinanceCategory(
          id: c.id,
          name: c.name,
          iconCodePoint: c.iconCodePoint,
          type: c.type,
          colorValue: color.value,
        );
      } else {
        final color = pick(incomePalette, incomeUsed);
        incomeUsed.add(color.value);
        return FinanceCategory(
          id: c.id,
          name: c.name,
          iconCodePoint: c.iconCodePoint,
          type: c.type,
          colorValue: color.value,
        );
      }
    }).toList();
  }

  List<FinanceCategory> all() => List.unmodifiable(_items);
  List<FinanceCategory> byType(TransactionType type) =>
      _items.where((e) => e.type == type).toList();

  Future<void> add(FinanceCategory c) async {
    _items = [..._items, c];
    await _persist();
  }

  Future<void> update(FinanceCategory updated) async {
    _items = _items.map((e) => e.id == updated.id ? updated : e).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode(_items.map((e) => e.toJson()).toList()),
    );
    _emit();
  }

  void _emit() => _controller.add(List.unmodifiable(_items));

  void dispose() => _controller.close();
}
