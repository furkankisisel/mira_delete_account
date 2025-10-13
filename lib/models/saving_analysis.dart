import 'package:uuid/uuid.dart';

/// Finans analizde tasarruf kısmı verisi
class SavingAnalysis {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final bool isTrialGenerated;

  SavingAnalysis({
    String? id,
    required this.userId,
    required this.content,
    DateTime? createdAt,
    required this.isTrialGenerated,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isTrialGenerated': isTrialGenerated,
  };

  factory SavingAnalysis.fromJson(Map<String, dynamic> json) => SavingAnalysis(
    id: json['id'] as String?,
    userId: json['userId'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isTrialGenerated: json['isTrialGenerated'] as bool? ?? false,
  );
}
