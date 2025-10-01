class AppList {
  AppList({required this.id, required this.title});

  final String id;
  String title;

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  static AppList fromJson(Map<String, dynamic> json) =>
      AppList(id: json['id'] as String, title: json['title'] as String? ?? '');
}
