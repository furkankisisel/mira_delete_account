import 'character_type.dart';
import 'onboarding_question.dart';

/// Result of the onboarding personality assessment
class OnboardingResult {
  /// Determined character type based on trait scores
  final CharacterType characterType;

  /// Big Five trait scores (0-1 normalized)
  final Map<PersonalityTrait, double> traitScores;

  /// Timestamp of completion
  final DateTime completedAt;

  const OnboardingResult({
    required this.characterType,
    required this.traitScores,
    required this.completedAt,
  });

  /// Calculate character type from trait scores using dominance hierarchy
  static CharacterType calculateCharacterType(
    Map<PersonalityTrait, double> scores,
  ) {
    // Normalize scores to 0-1 range
    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final normalized = scores.map((k, v) => MapEntry(k, v / maxScore));

    // Decision tree based on dominant traits
    final conscientiousness =
        normalized[PersonalityTrait.conscientiousness] ?? 0.5;
    final openness = normalized[PersonalityTrait.openness] ?? 0.5;
    final extraversion = normalized[PersonalityTrait.extraversion] ?? 0.5;
    final agreeableness = normalized[PersonalityTrait.agreeableness] ?? 0.5;
    final neuroticism = normalized[PersonalityTrait.neuroticism] ?? 0.5;

    // High Conscientiousness → Planner
    if (conscientiousness >= 0.7) {
      return CharacterType.planner;
    }

    // High Openness → Explorer
    if (openness >= 0.7) {
      return CharacterType.explorer;
    }

    // High Extraversion + High Agreeableness → Social Connector
    if (extraversion >= 0.6 && agreeableness >= 0.6) {
      return CharacterType.socialConnector;
    }

    // Low Neuroticism (emotionally stable) → Balanced Mindful
    if (neuroticism <= 0.4) {
      return CharacterType.balancedMindful;
    }

    // Default: Most balanced profile
    return CharacterType.balancedMindful;
  }

  /// Calculate trait scores from quiz answers
  static Map<PersonalityTrait, double> calculateTraitScores(
    List<OnboardingQuestion> questions,
    Map<String, int> answers, // questionId -> selected answer index
  ) {
    final traitTotals = <PersonalityTrait, double>{};
    final traitCounts = <PersonalityTrait, int>{};

    for (final question in questions) {
      final answerIndex = answers[question.id];
      if (answerIndex == null) continue;

      for (final entry in question.traitWeights.entries) {
        final trait = entry.key;
        final weights = entry.value;

        if (answerIndex >= 0 && answerIndex < weights.length) {
          traitTotals[trait] = (traitTotals[trait] ?? 0) + weights[answerIndex];
          traitCounts[trait] = (traitCounts[trait] ?? 0) + 1;
        }
      }
    }

    // Average scores per trait
    final averages = <PersonalityTrait, double>{};
    for (final trait in PersonalityTrait.values) {
      final total = traitTotals[trait] ?? 0;
      final count = traitCounts[trait] ?? 1;
      averages[trait] = total / count;
    }

    return averages;
  }

  Map<String, dynamic> toJson() {
    return {
      'characterType': characterType.key,
      'traitScores': traitScores.map((k, v) => MapEntry(k.name, v)),
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory OnboardingResult.fromJson(Map<String, dynamic> json) {
    return OnboardingResult(
      characterType: characterTypeFromKey(json['characterType'] as String),
      traitScores: (json['traitScores'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          PersonalityTrait.values.firstWhere((e) => e.name == k),
          (v as num).toDouble(),
        ),
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}
