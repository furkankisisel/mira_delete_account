import 'package:uuid/uuid.dart';

/// Örnek amaçlı yedek kayıt modeli (gerekebilir diye)
class BackupRecord {
  final String id;
  final String userId;
  final String data;
  final DateTime createdAt;
  final bool isTrialGenerated;

  BackupRecord({
    String? id,
    required this.userId,
    required this.data,
    DateTime? createdAt,
    required this.isTrialGenerated,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'isTrialGenerated': isTrialGenerated,
  };

  factory BackupRecord.fromJson(Map<String, dynamic> json) => BackupRecord(
    id: json['id'] as String?,
    userId: json['userId'] as String,
    data: json['data'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isTrialGenerated: json['isTrialGenerated'] as bool? ?? false,
  );
}
