class FreeformImage {
  final String id;
  final String path; // file or asset path
  final double posX; // 0..1
  final double posY; // 0..1
  final double scale; // 0.25..5
  final DateTime createdAt;

  const FreeformImage({
    required this.id,
    required this.path,
    required this.posX,
    required this.posY,
    required this.scale,
    required this.createdAt,
  });

  FreeformImage copyWith({
    String? path,
    double? posX,
    double? posY,
    double? scale,
  }) => FreeformImage(
    id: id,
    path: path ?? this.path,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
    scale: scale ?? this.scale,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'posX': posX,
    'posY': posY,
    'scale': scale,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory FreeformImage.fromJson(Map<String, dynamic> json) => FreeformImage(
    id: json['id'] as String,
    path: json['path'] as String,
    posX: (json['posX'] as num).toDouble(),
    posY: (json['posY'] as num).toDouble(),
    scale: (json['scale'] as num).toDouble(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num).toInt(),
    ),
  );
}
