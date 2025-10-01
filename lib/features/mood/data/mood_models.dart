import 'package:flutter/foundation.dart';

enum MoodLevel {
  terrible, // Berbat
  bad, // Kötü
  neutral, // Normal
  good, // İyi
  excellent, // Mükemmel
}

enum SubEmotion {
  // Terrible (Berbat)
  exhausted, // bitkin
  helpless, // çaresiz
  hopeless, // umutsuz
  hurt, // kırgın
  drained, // tükenmiş
  // Bad (Kötü)
  angry, // kızgın
  sad, // üzgün
  anxious, // endişeli
  stressed, // stresli
  demoralized, // moralsiz
  // Neutral (Normal)
  indecisive, // kararsız
  tired, // yorgun
  ordinary, // sıradan
  calm, // sakin
  empty, // boş
  // Good (İyi)
  happy, // mutlu
  cheerful, // neşeli
  excited, // heyecanlı
  enthusiastic, // hevesli
  determined, // azimli
  motivated, // motive
  // Excellent (Mükemmel)
  amazing, // harika
  energetic, // enerjik
  peaceful, // huzurlu
  grateful, // minnettar
  loving, // aşk dolu
}

enum ReasonCategory {
  academic, // Akademik
  work, // İş
  relationship, // İlişki
  finance, // Finans
  health, // Sağlık
  social, // Sosyal
  personalGrowth, // Kişisel Gelişim
  weather, // Hava Durumu
  other, // Diğer
}

class MoodEntry {
  final String id;
  final DateTime timestamp;
  final MoodLevel mood;
  final SubEmotion subEmotion;
  final ReasonCategory reason;
  final String journalText;

  MoodEntry({
    required this.id,
    required this.timestamp,
    required this.mood,
    required this.subEmotion,
    required this.reason,
    required this.journalText,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'mood': mood.index,
    'subEmotion': subEmotion.index,
    'reason': reason.index,
    'journalText': journalText,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    mood: MoodLevel.values[json['mood']],
    subEmotion: SubEmotion.values[json['subEmotion']],
    reason: ReasonCategory.values[json['reason']],
    journalText: json['journalText'],
  );
}

class MoodFlowState extends ChangeNotifier {
  MoodLevel? selectedMood;
  SubEmotion? selectedSubEmotion;
  ReasonCategory? selectedReason;
  String journalText = '';

  void setMood(MoodLevel mood) {
    selectedMood = mood;
    selectedSubEmotion = null; // Reset subsequent selections
    selectedReason = null;
    journalText = '';
    notifyListeners();
  }

  void setSubEmotion(SubEmotion subEmotion) {
    selectedSubEmotion = subEmotion;
    selectedReason = null; // Reset subsequent selections
    journalText = '';
    notifyListeners();
  }

  void setReason(ReasonCategory reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void setJournalText(String text) {
    journalText = text;
    notifyListeners();
  }

  void reset() {
    selectedMood = null;
    selectedSubEmotion = null;
    selectedReason = null;
    journalText = '';
    notifyListeners();
  }

  bool get canProceedToSubEmotion => selectedMood != null;
  bool get canProceedToReason => selectedSubEmotion != null;
  bool get canProceedToJournal => selectedReason != null;
  bool get canSave => journalText.trim().isNotEmpty;

  List<SubEmotion> getSubEmotionsForMood(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.terrible:
        return [
          SubEmotion.exhausted,
          SubEmotion.helpless,
          SubEmotion.hopeless,
          SubEmotion.hurt,
          SubEmotion.drained,
        ];
      case MoodLevel.bad:
        return [
          SubEmotion.angry,
          SubEmotion.sad,
          SubEmotion.anxious,
          SubEmotion.stressed,
          SubEmotion.demoralized,
        ];
      case MoodLevel.neutral:
        return [
          SubEmotion.indecisive,
          SubEmotion.tired,
          SubEmotion.ordinary,
          SubEmotion.calm,
          SubEmotion.empty,
        ];
      case MoodLevel.good:
        return [
          SubEmotion.happy,
          SubEmotion.cheerful,
          SubEmotion.excited,
          SubEmotion.enthusiastic,
          SubEmotion.determined,
          SubEmotion.motivated,
        ];
      case MoodLevel.excellent:
        return [
          SubEmotion.amazing,
          SubEmotion.energetic,
          SubEmotion.peaceful,
          SubEmotion.grateful,
          SubEmotion.loving,
        ];
    }
  }
}
