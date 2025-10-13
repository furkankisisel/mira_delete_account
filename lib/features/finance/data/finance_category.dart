import 'package:flutter/material.dart';
import 'transaction_model.dart';
import '../../../core/icons/icon_mapping.dart';

class FinanceCategory {
  final String id;
  final String name;
  final int iconCodePoint; // legacy Material icon codepoint (back-compat)
  final String? emoji; // preferred visual mark
  final TransactionType type; // income or expense
  final int colorValue; // ARGB Color value

  const FinanceCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.emoji,
    required this.type,
    required this.colorValue,
  });

  IconData get icon => materialIconFromCodePoint(iconCodePoint);
  bool get hasEmoji => (emoji != null && emoji!.isNotEmpty);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': iconCodePoint,
    'emoji': emoji,
    'type': type.name,
    'color': colorValue,
  };

  static FinanceCategory fromJson(Map<String, dynamic> map) => FinanceCategory(
    id: map['id'] as String,
    name: map['name'] as String,
    iconCodePoint: map['icon'] as int,
    emoji: map['emoji'] as String?,
    type: (map['type'] as String) == 'income'
        ? TransactionType.income
        : TransactionType.expense,
    colorValue: (map['color'] as num?)?.toInt() ?? Colors.grey.value,
  );
}
