import 'dart:convert';

enum TransactionType { income, expense }

class FinanceTransaction {
  final String id; // Unique id; for recurring instances may be derived
  final String title;
  final double amount;
  final DateTime date; // Anchor date for recurring, actual date for one-off
  final TransactionType type;
  final String? categoryId; // optional for backward compatibility

  // Recurrence fields (monthly)
  final bool isRecurring; // true if this belongs to a recurring series
  final bool recurringForever; // if true, ignore recurringMonths
  final int? recurringMonths; // number of months (>=1) if not forever

  // For generated occurrences that are not persisted, points back to base id
  final String? recurrenceId;

  const FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.categoryId,
    this.isRecurring = false,
    this.recurringForever = false,
    this.recurringMonths,
    this.recurrenceId,
  });

  FinanceTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? categoryId,
    bool? isRecurring,
    bool? recurringForever,
    int? recurringMonths,
    String? recurrenceId,
  }) => FinanceTransaction(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringForever: recurringForever ?? this.recurringForever,
    recurringMonths: recurringMonths ?? this.recurringMonths,
    recurrenceId: recurrenceId ?? this.recurrenceId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'type': type.name,
    'categoryId': categoryId,
    // Recurrence
    'isRecurring': isRecurring,
    'recurringForever': recurringForever,
    'recurringMonths': recurringMonths,
  };

  static FinanceTransaction fromJson(Map<String, dynamic> map) =>
      FinanceTransaction(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        type: (map['type'] as String) == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        categoryId: map['categoryId'] as String?,
        isRecurring: (map['isRecurring'] as bool?) ?? false,
        recurringForever: (map['recurringForever'] as bool?) ?? false,
        recurringMonths: (map['recurringMonths'] as num?)?.toInt(),
      );

  static List<FinanceTransaction> listFromJsonString(String jsonStr) {
    final list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => FinanceTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<FinanceTransaction> items) =>
      json.encode(items.map((e) => e.toJson()).toList());
}
