import 'character_type.dart';

/// Recommended habit template based on character type
class HabitRecommendation {
  /// Localization key for habit name
  final String nameKey;

  /// Localization key for habit description
  final String descriptionKey;

  /// Suggested frequency (daily, weekly, monthly)
  final String frequency;

  /// Character type this habit is recommended for
  final CharacterType characterType;

  /// Icon representation (emoji or icon name)
  final String icon;

  /// Category of habit (health, productivity, social, mindfulness)
  final String category;

  const HabitRecommendation({
    required this.nameKey,
    required this.descriptionKey,
    required this.frequency,
    required this.characterType,
    required this.icon,
    required this.category,
  });
}

/// Predefined habit recommendations per character type
class HabitRecommendations {
  static const Map<CharacterType, List<HabitRecommendation>> recommendations = {
    CharacterType.planner: [
      HabitRecommendation(
        nameKey: 'habitPlannerMorningRoutine',
        descriptionKey: 'habitPlannerMorningRoutineDesc',
        frequency: 'daily',
        characterType: CharacterType.planner,
        icon: '☀️',
        category: 'productivity',
      ),
      HabitRecommendation(
        nameKey: 'habitPlannerWeeklyReview',
        descriptionKey: 'habitPlannerWeeklyReviewDesc',
        frequency: 'weekly',
        characterType: CharacterType.planner,
        icon: '📊',
        category: 'productivity',
      ),
      HabitRecommendation(
        nameKey: 'habitPlannerGoalSetting',
        descriptionKey: 'habitPlannerGoalSettingDesc',
        frequency: 'monthly',
        characterType: CharacterType.planner,
        icon: '🎯',
        category: 'productivity',
      ),
      HabitRecommendation(
        nameKey: 'habitPlannerTaskPrioritization',
        descriptionKey: 'habitPlannerTaskPrioritizationDesc',
        frequency: 'daily',
        characterType: CharacterType.planner,
        icon: '✅',
        category: 'productivity',
      ),
      HabitRecommendation(
        nameKey: 'habitPlannerTimeBlocking',
        descriptionKey: 'habitPlannerTimeBlockingDesc',
        frequency: 'daily',
        characterType: CharacterType.planner,
        icon: '⏰',
        category: 'productivity',
      ),
    ],

    CharacterType.explorer: [
      HabitRecommendation(
        nameKey: 'habitExplorerLearnNewSkill',
        descriptionKey: 'habitExplorerLearnNewSkillDesc',
        frequency: 'weekly',
        characterType: CharacterType.explorer,
        icon: '📚',
        category: 'learning',
      ),
      HabitRecommendation(
        nameKey: 'habitExplorerTryNewActivity',
        descriptionKey: 'habitExplorerTryNewActivityDesc',
        frequency: 'weekly',
        characterType: CharacterType.explorer,
        icon: '🎨',
        category: 'creativity',
      ),
      HabitRecommendation(
        nameKey: 'habitExplorerReadDiverse',
        descriptionKey: 'habitExplorerReadDiverseDesc',
        frequency: 'daily',
        characterType: CharacterType.explorer,
        icon: '📖',
        category: 'learning',
      ),
      HabitRecommendation(
        nameKey: 'habitExplorerCreativeProject',
        descriptionKey: 'habitExplorerCreativeProjectDesc',
        frequency: 'weekly',
        characterType: CharacterType.explorer,
        icon: '🎭',
        category: 'creativity',
      ),
      HabitRecommendation(
        nameKey: 'habitExplorerExplorePlace',
        descriptionKey: 'habitExplorerExplorePlaceDesc',
        frequency: 'monthly',
        characterType: CharacterType.explorer,
        icon: '🗺️',
        category: 'adventure',
      ),
    ],

    CharacterType.socialConnector: [
      HabitRecommendation(
        nameKey: 'habitSocialCallFriend',
        descriptionKey: 'habitSocialCallFriendDesc',
        frequency: 'weekly',
        characterType: CharacterType.socialConnector,
        icon: '📞',
        category: 'social',
      ),
      HabitRecommendation(
        nameKey: 'habitSocialGroupActivity',
        descriptionKey: 'habitSocialGroupActivityDesc',
        frequency: 'weekly',
        characterType: CharacterType.socialConnector,
        icon: '👥',
        category: 'social',
      ),
      HabitRecommendation(
        nameKey: 'habitSocialVolunteer',
        descriptionKey: 'habitSocialVolunteerDesc',
        frequency: 'monthly',
        characterType: CharacterType.socialConnector,
        icon: '🤲',
        category: 'community',
      ),
      HabitRecommendation(
        nameKey: 'habitSocialFamilyTime',
        descriptionKey: 'habitSocialFamilyTimeDesc',
        frequency: 'weekly',
        characterType: CharacterType.socialConnector,
        icon: '👨‍👩‍👧',
        category: 'social',
      ),
      HabitRecommendation(
        nameKey: 'habitSocialCompliment',
        descriptionKey: 'habitSocialComplimentDesc',
        frequency: 'daily',
        characterType: CharacterType.socialConnector,
        icon: '💬',
        category: 'social',
      ),
    ],

    CharacterType.balancedMindful: [
      HabitRecommendation(
        nameKey: 'habitMindfulMeditation',
        descriptionKey: 'habitMindfulMeditationDesc',
        frequency: 'daily',
        characterType: CharacterType.balancedMindful,
        icon: '🧘',
        category: 'mindfulness',
      ),
      HabitRecommendation(
        nameKey: 'habitMindfulGratitude',
        descriptionKey: 'habitMindfulGratitudeDesc',
        frequency: 'daily',
        characterType: CharacterType.balancedMindful,
        icon: '🙏',
        category: 'mindfulness',
      ),
      HabitRecommendation(
        nameKey: 'habitMindfulNatureWalk',
        descriptionKey: 'habitMindfulNatureWalkDesc',
        frequency: 'weekly',
        characterType: CharacterType.balancedMindful,
        icon: '🌳',
        category: 'wellness',
      ),
      HabitRecommendation(
        nameKey: 'habitMindfulBreathing',
        descriptionKey: 'habitMindfulBreathingDesc',
        frequency: 'daily',
        characterType: CharacterType.balancedMindful,
        icon: '🌬️',
        category: 'mindfulness',
      ),
      HabitRecommendation(
        nameKey: 'habitMindfulJournaling',
        descriptionKey: 'habitMindfulJournalingDesc',
        frequency: 'daily',
        characterType: CharacterType.balancedMindful,
        icon: '✍️',
        category: 'reflection',
      ),
    ],
  };

  static List<HabitRecommendation> getRecommendations(CharacterType type) {
    return recommendations[type] ?? [];
  }
}
