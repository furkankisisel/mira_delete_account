import 'package:flutter/material.dart';
import '../onboarding/presentation/onboarding_screen.dart';
import '../onboarding/data/onboarding_repository.dart';

/// Screen shown after successful sign-in to choose whether to start the test or skip it.
class TestChoiceScreen extends StatelessWidget {
  const TestChoiceScreen({super.key, this.onSkip, this.onStart});

  final VoidCallback? onSkip;
  final VoidCallback? onStart;

  Future<void> _skipTest(BuildContext context) async {
    await OnboardingRepository().setOnboardingCompleted(true);
    onSkip?.call();
  }

  void _startTest(BuildContext context) {
    onStart?.call();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.psychology,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Kişilik testine başlamak ister misin?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Testi tamamlarsan kişiliğine uygun öneriler ve önerilen alışkanlıklar alırsın. İstersen bu adımı şimdi atlayabilirsin.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _skipTest(context),
                      child: const Text('Testi Atla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _startTest(context),
                      child: const Text('Testi Başlat'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
