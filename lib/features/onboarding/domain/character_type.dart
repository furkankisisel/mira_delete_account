/// Character types based on Big Five personality traits and Self-Determination Theory
/// Scientific basis: Costa & McCrae (1992), Deci & Ryan (2000)
enum CharacterType {
  /// High Conscientiousness - organized, goal-oriented, detail-focused
  /// Prefers structure, planning, and achievement-based habits
  planner,

  /// High Openness - creative, curious, adaptable
  /// Prefers variety, learning, and exploration-based habits
  explorer,

  /// High Extraversion + Agreeableness - social, collaborative, empathetic
  /// Prefers community, relationships, and socially-engaging habits
  socialConnector,

  /// Low Neuroticism + Balanced traits - calm, steady, mindful
  /// Prefers wellness, balance, and stress-reduction habits
  balancedMindful,
}

extension CharacterTypeExtension on CharacterType {
  String get key {
    switch (this) {
      case CharacterType.planner:
        return 'planner';
      case CharacterType.explorer:
        return 'explorer';
      case CharacterType.socialConnector:
        return 'socialConnector';
      case CharacterType.balancedMindful:
        return 'balancedMindful';
    }
  }

  /// Returns localization key for character name
  String get nameKey {
    switch (this) {
      case CharacterType.planner:
        return 'characterTypePlanner';
      case CharacterType.explorer:
        return 'characterTypeExplorer';
      case CharacterType.socialConnector:
        return 'characterTypeSocialConnector';
      case CharacterType.balancedMindful:
        return 'characterTypeBalancedMindful';
    }
  }

  /// Returns localization key for character description
  String get descriptionKey {
    switch (this) {
      case CharacterType.planner:
        return 'characterDescPlanner';
      case CharacterType.explorer:
        return 'characterDescExplorer';
      case CharacterType.socialConnector:
        return 'characterDescSocialConnector';
      case CharacterType.balancedMindful:
        return 'characterDescBalancedMindful';
    }
  }

  /// Returns emoji representation for visual appeal
  String get emoji {
    switch (this) {
      case CharacterType.planner:
        return '📋';
      case CharacterType.explorer:
        return '🧭';
      case CharacterType.socialConnector:
        return '🤝';
      case CharacterType.balancedMindful:
        return '🧘';
    }
  }
}

// Helper function to parse CharacterType from string key
CharacterType characterTypeFromKey(String key) {
  return CharacterType.values.firstWhere(
    (e) => e.key == key,
    orElse: () => CharacterType.balancedMindful,
  );
}
