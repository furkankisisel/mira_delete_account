class Subtask {
  Subtask({required this.id, required this.title, this.isCompleted = false});

  final String id;
  String title;
  bool isCompleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };

  static Subtask fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
