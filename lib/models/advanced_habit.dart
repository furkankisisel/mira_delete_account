import 'package:uuid/uuid.dart';

/// Gelişmiş alışkanlık modeli
class AdvancedHabit {
  final String id;
  final String userId;
  final Map<String, dynamic> config; // serbest yapılandırma
  final DateTime createdAt;
  final bool isTrialGenerated;

  AdvancedHabit({
    String? id,
    required this.userId,
    required this.config,
    DateTime? createdAt,
    required this.isTrialGenerated,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'config': config,
    'createdAt': createdAt.toIso8601String(),
    'isTrialGenerated': isTrialGenerated,
  };

  factory AdvancedHabit.fromJson(Map<String, dynamic> json) => AdvancedHabit(
    id: json['id'] as String?,
    userId: json['userId'] as String,
    config: Map<String, dynamic>.from(json['config'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isTrialGenerated: json['isTrialGenerated'] as bool? ?? false,
  );
}
