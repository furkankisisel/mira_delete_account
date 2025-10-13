/// Big Five personality traits (OCEAN model)
/// Used for scoring onboarding assessment questions
enum PersonalityTrait {
  /// Openness to Experience - curiosity, creativity, imagination
  openness,

  /// Conscientiousness - organization, discipline, goal-orientation
  conscientiousness,

  /// Extraversion - sociability, energy, assertiveness
  extraversion,

  /// Agreeableness - cooperation, empathy, trust
  agreeableness,

  /// Neuroticism (inverse: Emotional Stability) - anxiety, mood stability
  neuroticism,
}

/// Represents a single onboarding quiz question with scoring weights
class OnboardingQuestion {
  final String id;

  /// Localization key for question text
  final String questionKey;

  /// Localization keys for answer options (typically 5 for Likert scale)
  final List<String> answerKeys;

  /// Scoring weights: Map of trait to weight multiplier per answer
  /// Example: {PersonalityTrait.openness: [1, 2, 3, 4, 5]} for 5-point Likert
  final Map<PersonalityTrait, List<double>> traitWeights;

  /// Question type (likert, multipleChoice)
  final QuestionType type;

  const OnboardingQuestion({
    required this.id,
    required this.questionKey,
    required this.answerKeys,
    required this.traitWeights,
    this.type = QuestionType.likert,
  });
}

enum QuestionType {
  /// 5-point Likert scale (Strongly Disagree to Strongly Agree)
  likert,

  /// Multiple choice with distinct options
  multipleChoice,
}

/// Predefined scientifically-based onboarding questions
class OnboardingQuestions {
  static const List<OnboardingQuestion> questions = [
    // Question 1: Openness - New Experiences
    OnboardingQuestion(
      id: 'q1_openness_new',
      questionKey: 'onboardingQ1',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.openness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 2: Conscientiousness - Organization
    OnboardingQuestion(
      id: 'q2_conscientiousness_org',
      questionKey: 'onboardingQ2',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.conscientiousness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 3: Extraversion - Social Energy
    OnboardingQuestion(
      id: 'q3_extraversion_social',
      questionKey: 'onboardingQ3',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.extraversion: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 4: Agreeableness - Cooperation
    OnboardingQuestion(
      id: 'q4_agreeableness_coop',
      questionKey: 'onboardingQ4',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.agreeableness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 5: Neuroticism (inverse) - Emotional Stability
    OnboardingQuestion(
      id: 'q5_neuroticism_calm',
      questionKey: 'onboardingQ5',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.neuroticism: [5, 4, 3, 2, 1], // Inverted scoring
      },
      type: QuestionType.likert,
    ),

    // Question 6: Openness - Creativity
    OnboardingQuestion(
      id: 'q6_openness_creative',
      questionKey: 'onboardingQ6',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.openness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 7: Conscientiousness - Discipline
    OnboardingQuestion(
      id: 'q7_conscientiousness_discipline',
      questionKey: 'onboardingQ7',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.conscientiousness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 8: Extraversion - Group Activities
    OnboardingQuestion(
      id: 'q8_extraversion_groups',
      questionKey: 'onboardingQ8',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.extraversion: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 9: Agreeableness - Empathy
    OnboardingQuestion(
      id: 'q9_agreeableness_empathy',
      questionKey: 'onboardingQ9',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.agreeableness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 10: Conscientiousness - Planning
    OnboardingQuestion(
      id: 'q10_conscientiousness_planning',
      questionKey: 'onboardingQ10',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.conscientiousness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 11: Openness - Variety
    OnboardingQuestion(
      id: 'q11_openness_variety',
      questionKey: 'onboardingQ11',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.openness: [1, 2, 3, 4, 5],
      },
      type: QuestionType.likert,
    ),

    // Question 12: Neuroticism (inverse) - Stress Management
    OnboardingQuestion(
      id: 'q12_neuroticism_stress',
      questionKey: 'onboardingQ12',
      answerKeys: [
        'likertStronglyDisagree',
        'likertDisagree',
        'likertNeutral',
        'likertAgree',
        'likertStronglyAgree',
      ],
      traitWeights: {
        PersonalityTrait.neuroticism: [5, 4, 3, 2, 1], // Inverted scoring
      },
      type: QuestionType.likert,
    ),
  ];
}
