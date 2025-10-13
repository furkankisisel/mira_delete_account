import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/onboarding_question.dart';
import '../domain/onboarding_result.dart';
import '../data/onboarding_repository.dart';
import 'character_result_screen.dart';

/// Onboarding flow with welcome, quiz, and result screens
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final Map<String, int> _answers = {}; // questionId -> selected answer index
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < OnboardingQuestions.questions.length + 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    // Calculate result
    final traitScores = OnboardingResult.calculateTraitScores(
      OnboardingQuestions.questions,
      _answers,
    );
    final characterType = OnboardingResult.calculateCharacterType(traitScores);
    final result = OnboardingResult(
      characterType: characterType,
      traitScores: traitScores,
      completedAt: DateTime.now(),
    );

    // Save result
    final repository = OnboardingRepository();
    await repository.saveOnboardingResult(result);

    // Navigate to character result screen
    if (mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CharacterResultScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Welcome page
                  _WelcomePage(onNext: _nextPage),

                  // Quiz pages
                  ...OnboardingQuestions.questions.asMap().entries.map((entry) {
                    final questionIndex = entry.key;
                    final question = entry.value;
                    return _QuestionPage(
                      question: question,
                      selectedAnswer: _answers[question.id],
                      onAnswerSelected: (answerIndex) {
                        setState(() {
                          _answers[question.id] = answerIndex;
                        });

                        // Auto-advance to next question after a short delay
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (questionIndex <
                              OnboardingQuestions.questions.length - 1) {
                            // Not the last question, go to next
                            _nextPage();
                          } else {
                            // Last question, finish onboarding
                            _finishOnboarding();
                          }
                        });
                      },
                    );
                  }),
                ],
              ),

              // Progress indicator
              if (_currentPage > 0)
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: LinearProgressIndicator(
                    value:
                        _currentPage /
                        (OnboardingQuestions.questions.length + 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Welcome page widget
class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Cute animated logo
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 70,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Welcome title with fade-in
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                l10n.onboardingWelcomeTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Welcome description
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  l10n.onboardingWelcomeDesc,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const Spacer(),

            // Start button
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.startJourney,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quiz intro text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.onboardingQuizIntro,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Question page widget with Likert scale
class _QuestionPage extends StatelessWidget {
  final OnboardingQuestion question;
  final int? selectedAnswer;
  final ValueChanged<int> onAnswerSelected;

  const _QuestionPage({
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  String _getQuestionText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Map question keys to localized text
    switch (question.questionKey) {
      case 'onboardingQ1':
        return l10n.onboardingQ1;
      case 'onboardingQ2':
        return l10n.onboardingQ2;
      case 'onboardingQ3':
        return l10n.onboardingQ3;
      case 'onboardingQ4':
        return l10n.onboardingQ4;
      case 'onboardingQ5':
        return l10n.onboardingQ5;
      case 'onboardingQ6':
        return l10n.onboardingQ6;
      case 'onboardingQ7':
        return l10n.onboardingQ7;
      case 'onboardingQ8':
        return l10n.onboardingQ8;
      case 'onboardingQ9':
        return l10n.onboardingQ9;
      case 'onboardingQ10':
        return l10n.onboardingQ10;
      case 'onboardingQ11':
        return l10n.onboardingQ11;
      case 'onboardingQ12':
        return l10n.onboardingQ12;
      default:
        return question.questionKey;
    }
  }

  String _getAnswerText(BuildContext context, String answerKey) {
    final l10n = AppLocalizations.of(context);
    switch (answerKey) {
      case 'likertStronglyDisagree':
        return l10n.likertStronglyDisagree;
      case 'likertDisagree':
        return l10n.likertDisagree;
      case 'likertNeutral':
        return l10n.likertNeutral;
      case 'likertAgree':
        return l10n.likertAgree;
      case 'likertStronglyAgree':
        return l10n.likertStronglyAgree;
      default:
        return answerKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question number badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${OnboardingQuestions.questions.indexOf(question) + 1} / ${OnboardingQuestions.questions.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Question text
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getQuestionText(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Likert scale options
            ...List.generate(question.answerKeys.length, (index) {
              final isSelected = selectedAnswer == index;
              final answerText = _getAnswerText(
                context,
                question.answerKeys[index],
              );

              // Emoji indicators for Likert scale
              final emojis = ['😟', '😐', '😊', '😄', '🤩'];
              final emoji = index < emojis.length ? emojis[index] : '⭐';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onAnswerSelected(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Emoji
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            answerText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        // Check indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
