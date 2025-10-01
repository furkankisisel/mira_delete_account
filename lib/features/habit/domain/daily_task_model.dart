class DailyTask {
  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dateKey, // YYYY-MM-DD
    this.isDone = false,
    this.listId,
  });

  final String id;
  String title;
  String description;
  String dateKey;
  bool isDone;
  String? listId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dateKey': dateKey,
    'isDone': isDone,
    'listId': listId,
  };

  static DailyTask fromJson(Map<String, dynamic> json) => DailyTask(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    dateKey: json['dateKey'] as String,
    isDone: json['isDone'] as bool? ?? false,
    listId: json['listId'] as String?,
  );
}
