// Decision Egg - Fortune Telling Feature Models

/// Represents a question asked by the user
class FortuneQuestion {
  final String id;
  final String text;
  final DateTime createdAt;

  const FortuneQuestion({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FortuneQuestion.fromJson(Map<String, dynamic> json) =>
      FortuneQuestion(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Represents a mystical answer that can be found inside an egg
class FortuneAnswer {
  final String id;
  final String text;
  final AnswerType type;
  final String? emoji;

  const FortuneAnswer({
    required this.id,
    required this.text,
    required this.type,
    this.emoji,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'type': type.name,
    'emoji': emoji,
  };

  factory FortuneAnswer.fromJson(Map<String, dynamic> json) => FortuneAnswer(
    id: json['id'] as String,
    text: json['text'] as String,
    type: AnswerType.values.firstWhere((e) => e.name == json['type']),
    emoji: json['emoji'] as String?,
  );
}

/// Types of answers to categorize responses
enum AnswerType {
  positive, // Olumlu cevaplar
  negative, // Olumsuz cevaplar
  neutral, // Nötr cevaplar
  mysterious, // Gizemli/belirsiz cevaplar
  funny, // Komik cevaplar
  wise, // Bilge/öğretici cevaplar
}

/// Represents a mystical egg containing a fortune answer
class FortuneEgg {
  final String id;
  final EggColor color;
  final EggPattern pattern;
  final FortuneAnswer? answer; // null until cracked
  final bool isCracked;

  const FortuneEgg({
    required this.id,
    required this.color,
    required this.pattern,
    this.answer,
    this.isCracked = false,
  });

  FortuneEgg copyWith({
    String? id,
    EggColor? color,
    EggPattern? pattern,
    FortuneAnswer? answer,
    bool? isCracked,
  }) => FortuneEgg(
    id: id ?? this.id,
    color: color ?? this.color,
    pattern: pattern ?? this.pattern,
    answer: answer ?? this.answer,
    isCracked: isCracked ?? this.isCracked,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.name,
    'pattern': pattern.name,
    'answer': answer?.toJson(),
    'isCracked': isCracked,
  };

  factory FortuneEgg.fromJson(Map<String, dynamic> json) => FortuneEgg(
    id: json['id'] as String,
    color: EggColor.values.firstWhere((e) => e.name == json['color']),
    pattern: EggPattern.values.firstWhere((e) => e.name == json['pattern']),
    answer: json['answer'] != null
        ? FortuneAnswer.fromJson(json['answer'])
        : null,
    isCracked: json['isCracked'] as bool? ?? false,
  );
}

/// Available egg colors for visual variety
enum EggColor {
  chicken, // Tavuk yumurtası - krem/beyaz
  duck, // Ördek yumurtası - açık mavi/yeşil
  quail, // Bıldırcın yumurtası - benekli kahverengi
  robin, // Kızılgerdan yumurtası - turkuaz mavi
  sparrow, // Serçe yumurtası - gri benekli
  finch, // Ispinoz yumurtası - pembe benekli
  ostrich, // Devekuşu yumurtası - krem sarısı
  turtle, // Kaplumbağa yumurtası - beyaz
}

/// Available egg patterns for visual variety
enum EggPattern {
  smooth, // Düz pürüzsüz
  spotted, // Benekli
  speckled, // Ufak noktalı
  streaked, // Çizgili
  marbled, // Mermer desenli
  mottled, // Lekeli/karışık
  banded, // Şeritli
  textured, // Dokulu yüzey
}

/// Represents a complete fortune telling session
class FortuneSession {
  final String id;
  final FortuneQuestion question;
  final List<FortuneEgg> eggs;
  final FortuneEgg? selectedEgg;
  final DateTime createdAt;
  final SessionStatus status;

  const FortuneSession({
    required this.id,
    required this.question,
    required this.eggs,
    this.selectedEgg,
    required this.createdAt,
    required this.status,
  });

  FortuneSession copyWith({
    String? id,
    FortuneQuestion? question,
    List<FortuneEgg>? eggs,
    FortuneEgg? selectedEgg,
    DateTime? createdAt,
    SessionStatus? status,
  }) => FortuneSession(
    id: id ?? this.id,
    question: question ?? this.question,
    eggs: eggs ?? this.eggs,
    selectedEgg: selectedEgg ?? this.selectedEgg,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question.toJson(),
    'eggs': eggs.map((e) => e.toJson()).toList(),
    'selectedEgg': selectedEgg?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };

  factory FortuneSession.fromJson(Map<String, dynamic> json) => FortuneSession(
    id: json['id'] as String,
    question: FortuneQuestion.fromJson(json['question']),
    eggs: (json['eggs'] as List).map((e) => FortuneEgg.fromJson(e)).toList(),
    selectedEgg: json['selectedEgg'] != null
        ? FortuneEgg.fromJson(json['selectedEgg'])
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
  );
}

/// Status of a fortune telling session
enum SessionStatus {
  questionAsked, // Soru soruldu
  eggsPresented, // Yumurtalar sunuldu
  eggSelected, // Yumurta seçildi
  answerRevealed, // Cevap açıklandı
  completed, // Tamamlandı
}
