class FreeformText {
  final String id;
  final String text;
  final int colorValue; // ARGB32
  final String fontFamily;
  final double posX; // 0..1 relative
  final double posY; // 0..1 relative
  final double scale; // 0.5..3.0 (used as font size multiplier)
  final DateTime createdAt;
  // Optional background plate and outline
  final bool plateEnabled;
  final int plateColorValue; // ARGB32
  final bool outlineEnabled;
  final int outlineColorValue; // ARGB32

  const FreeformText({
    required this.id,
    required this.text,
    required this.colorValue,
    required this.fontFamily,
    required this.posX,
    required this.posY,
    required this.scale,
    required this.createdAt,
    this.plateEnabled = false,
    this.plateColorValue = 0xFF000000,
    this.outlineEnabled = false,
    this.outlineColorValue = 0xFFFFFFFF,
  });

  FreeformText copyWith({
    String? text,
    int? colorValue,
    String? fontFamily,
    double? posX,
    double? posY,
    double? scale,
    bool? plateEnabled,
    int? plateColorValue,
    bool? outlineEnabled,
    int? outlineColorValue,
  }) => FreeformText(
    id: id,
    text: text ?? this.text,
    colorValue: colorValue ?? this.colorValue,
    fontFamily: fontFamily ?? this.fontFamily,
    posX: posX ?? this.posX,
    posY: posY ?? this.posY,
    scale: scale ?? this.scale,
    createdAt: createdAt,
    plateEnabled: plateEnabled ?? this.plateEnabled,
    plateColorValue: plateColorValue ?? this.plateColorValue,
    outlineEnabled: outlineEnabled ?? this.outlineEnabled,
    outlineColorValue: outlineColorValue ?? this.outlineColorValue,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'colorValue': colorValue,
    'fontFamily': fontFamily,
    'posX': posX,
    'posY': posY,
    'scale': scale,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'plateEnabled': plateEnabled,
    'plateColorValue': plateColorValue,
    'outlineEnabled': outlineEnabled,
    'outlineColorValue': outlineColorValue,
  };

  factory FreeformText.fromJson(Map<String, dynamic> json) => FreeformText(
    id: json['id'] as String,
    text: json['text'] as String,
    colorValue: (json['colorValue'] as num).toInt(),
    fontFamily: json['fontFamily'] as String,
    posX: (json['posX'] as num).toDouble(),
    posY: (json['posY'] as num).toDouble(),
    scale: (json['scale'] as num).toDouble(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num).toInt(),
    ),
    plateEnabled: (json['plateEnabled'] as bool?) ?? false,
    plateColorValue: (json['plateColorValue'] as num?)?.toInt() ?? 0xFF000000,
    outlineEnabled: (json['outlineEnabled'] as bool?) ?? false,
    outlineColorValue:
        (json['outlineColorValue'] as num?)?.toInt() ?? 0xFFFFFFFF,
  );
}
