// Model only stores primitive types; UI layers convert color/emoji as needed.

import 'vision_task_model.dart';

class Vision {
  final String id;
  final String title;
  final String? description;
  final String? coverImage; // asset path or file path
  final String? emoji; // fallback for board view
  final int colorValue; // theme color for the card
  final List<String> linkedHabitIds;
  final List<VisionTask> tasks; // one-time checkbox tasks
  final DateTime createdAt;
  final DateTime? endDate; // optional end date
  final DateTime?
  startDate; // optional explicit start date (base for vision-day offsets)
  // Freeform canvas layout (normalized 0..1), and scale factor
  final double posX;
  final double posY;
  final double scale;

  const Vision({
    required this.id,
    required this.title,
    this.description,
    this.coverImage,
    this.emoji,
    required this.colorValue,
    required this.linkedHabitIds,
    this.tasks = const [],
    required this.createdAt,
    this.endDate,
    this.startDate,
    this.posX = 0.1,
    this.posY = 0.1,
    this.scale = 1.0,
  });

  // Sentinel to allow explicit nulls in copyWith for nullable fields
  static const Object _noChange = Object();

  Vision copyWith({
    String? id,
    String? title,
    String? description,
    Object? coverImage = _noChange,
    Object? emoji = _noChange,
    int? colorValue,
    List<String>? linkedHabitIds,
    List<VisionTask>? tasks,
    DateTime? createdAt,
    Object? endDate = _noChange,
    Object? startDate = _noChange,
    double? posX,
    double? posY,
    double? scale,
  }) => Vision(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    coverImage: identical(coverImage, _noChange)
        ? this.coverImage
        : coverImage as String?,
    emoji: identical(emoji, _noChange) ? this.emoji : emoji as String?,
    colorValue: colorValue ?? this.colorValue,
    linkedHabitIds: linkedHabitIds ?? this.linkedHabitIds,
    tasks: tasks ?? this.tasks,
    createdAt: createdAt ?? this.createdAt,
    endDate: identical(endDate, _noChange)
        ? this.endDate
        : endDate as DateTime?,
    startDate: identical(startDate, _noChange)
        ? this.startDate
        : startDate as DateTime?,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
    scale: scale ?? this.scale,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'coverImage': coverImage,
    'emoji': emoji,
    'colorValue': colorValue,
    'linkedHabitIds': linkedHabitIds,
    'tasks': tasks.map((t) => t.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'startDate': startDate?.toIso8601String(),
    'posX': posX,
    'posY': posY,
    'scale': scale,
  };

  static Vision fromJson(Map<String, dynamic> json) => Vision(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    coverImage: json['coverImage'] as String?,
    emoji: json['emoji'] as String?,
    colorValue: json['colorValue'] as int,
    linkedHabitIds: (json['linkedHabitIds'] as List).cast<String>(),
    tasks:
        (json['tasks'] as List?)
            ?.map((t) => VisionTask.fromJson(t as Map<String, dynamic>))
            .toList() ??
        const [],
    createdAt: DateTime.parse(json['createdAt'] as String),
    endDate: (json['endDate'] as String?) != null
        ? DateTime.tryParse(json['endDate'] as String)
        : null,
    startDate: (json['startDate'] as String?) != null
        ? DateTime.tryParse(json['startDate'] as String)
        : null,
    posX: (json['posX'] as num?)?.toDouble() ?? 0.1,
    posY: (json['posY'] as num?)?.toDouble() ?? 0.1,
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  );
}
