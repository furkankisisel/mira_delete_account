/// Model for one-time tasks within a vision.
/// These are simple checkbox items that contribute to vision progress.
class VisionTask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  const VisionTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  VisionTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) => VisionTask(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VisionTask.fromJson(Map<String, dynamic> json) => VisionTask(
    id: json['id'] as String,
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
