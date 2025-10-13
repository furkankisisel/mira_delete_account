import 'package:uuid/uuid.dart';

/// Kişilik testi sonucu (kalıcı)
class PersonalityTestResult {
  final String id;
  final String userId;
  final Map<String, dynamic> scores; // puanlar
  final DateTime createdAt;

  PersonalityTestResult({
    String? id,
    required this.userId,
    required this.scores,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'scores': scores,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PersonalityTestResult.fromJson(Map<String, dynamic> json) =>
      PersonalityTestResult(
        id: json['id'] as String?,
        userId: json['userId'] as String,
        scores: Map<String, dynamic>.from(json['scores'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
