import 'package:uuid/uuid.dart';

/// Yinelenen gelir/gider kaydı
class RecurringEntry {
  final String id;
  final String userId;
  final double amount;
  final String schedule; // örn: monthly, weekly, cron ifadesi
  final DateTime createdAt;
  final bool isTrialGenerated;

  RecurringEntry({
    String? id,
    required this.userId,
    required this.amount,
    required this.schedule,
    DateTime? createdAt,
    required this.isTrialGenerated,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'amount': amount,
    'schedule': schedule,
    'createdAt': createdAt.toIso8601String(),
    'isTrialGenerated': isTrialGenerated,
  };

  factory RecurringEntry.fromJson(Map<String, dynamic> json) => RecurringEntry(
    id: json['id'] as String?,
    userId: json['userId'] as String,
    amount: (json['amount'] as num).toDouble(),
    schedule: json['schedule'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isTrialGenerated: json['isTrialGenerated'] as bool? ?? false,
  );
}
