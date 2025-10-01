import 'dart:math';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../data/answers.dart';
import 'package:mira/features/fortune_eggs/widgets/fortune_egg.dart' as fe;

class FortuneEggsScreen extends StatefulWidget {
  const FortuneEggsScreen({super.key});

  @override
  State<FortuneEggsScreen> createState() => _FortuneEggsScreenState();
}

class _FortuneEggsScreenState extends State<FortuneEggsScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  late List<String> _answers;
  late List<fe.EggTheme> _eggs;
  bool _didInit = false;

  // Screen flow states
  int _currentStep = 0; // 0: question input, 1: eggs selection

  // Egg interaction state
  final Map<int, double> _eggCrackProgress = {0: 0.0, 1: 0.0, 2: 0.0};
  final Map<int, int> _eggTapCounts = {0: 0, 1: 0, 2: 0};
  late final PageController _pageController;
  int _selectedEggIndex = 0;

  late final AnimationController _pageTransitionController;
  late final AnimationController _crackController;

  @override
  void initState() {
    super.initState();
    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _crackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageController = PageController(viewportFraction: 0.78);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _reshuffle();
    }
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _crackController.dispose();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _reshuffle() {
    final l10n = AppLocalizations.of(context);
    final pool = FortuneAnswers.pickDistinct(l10n.localeName, 3);
    final rnd = Random();
    final allThemes = fe.EggTheme.values.toList();
    allThemes.shuffle(rnd);
    setState(() {
      _answers = pool;
      _eggs = allThemes.take(3).toList();
      // Reset crack states
      _eggCrackProgress.updateAll((key, value) => 0.0);
      _eggTapCounts.updateAll((key, value) => 0);
    });
  }

  void _proceedToEggs() {
    if (_controller.text.trim().isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fortuneNoQuestion)));
      return;
    }
    setState(() => _currentStep = 1);
    _pageTransitionController.forward();
  }

  void _goBackToQuestion() {
    setState(() => _currentStep = 0);
    _pageTransitionController.reverse();
  }

  void _onEggTap(int index) {
    if (_currentStep != 1) return;

    // For panel mode: tapping an egg immediately reveals the answer as a popup
    _showAnswer(index);
  }

  void _showAnswer(int index) {
    final l10n = AppLocalizations.of(context);
    final answer = _answers[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.fortuneResultTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '"${_controller.text.trim()}"',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Text(
              answer,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _reshuffle();
            },
            child: Text(l10n.shuffle),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStep() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(flex: 2),
        Text(
          l10n.fortuneQuestionPrompt,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              onSubmitted: (_) => _proceedToEggs(),
              decoration: InputDecoration(
                hintText: l10n.fortuneQuestionHint,
                prefixIcon: const Icon(Icons.help_outline),
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _proceedToEggs,
          icon: const Icon(Icons.arrow_forward),
          label: Text('Yumurtalara Geç'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  Widget _buildEggsStep() {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _pageTransitionController,
      builder: (context, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _pageTransitionController,
                curve: Curves.easeInOut,
              ),
            );

        return SlideTransition(
          position: slideAnimation,
          child: Column(
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    onPressed: _goBackToQuestion,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      '"${_controller.text.trim()}"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
              const SizedBox(height: 32),

              // Single-egg swipeable panel
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Yumurtayı sağa/sola kaydırarak değiştirin, üzerine dokununca cevap görünür',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 260,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _eggs.length,
                        onPageChanged: (i) =>
                            setState(() => _selectedEggIndex = i),
                        itemBuilder: (context, i) {
                          final progress = _eggCrackProgress[i] ?? 0.0;
                          return Center(
                            child: GestureDetector(
                              onTap: () => _onEggTap(i),
                              child: AnimatedBuilder(
                                animation: _crackController,
                                builder: (context, child) => fe.FortuneEgg(
                                  theme: _eggs[i],
                                  size: 220,
                                  isSelected: _selectedEggIndex == i,
                                  crackProgress: progress,
                                  semanticLabel: l10n.fortuneEggSemantic(i + 1),
                                  onTap: () => _onEggTap(i),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    // Simple page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_eggs.length, (i) {
                        final filled = i == _selectedEggIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: filled ? 12 : 8,
                          height: filled ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _reshuffle,
                          icon: const Icon(Icons.shuffle),
                          label: Text(l10n.shuffle),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.fortuneDisclaimer,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEggWithProgress(int index) {
    final l10n = AppLocalizations.of(context);
    final progress = _eggCrackProgress[index]!;
    final tapCount = _eggTapCounts[index]!;
    final maxTaps = 4;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _crackController,
          builder: (context, child) {
            return fe.FortuneEgg(
              theme: _eggs[index],
              size: 160,
              isSelected: tapCount > 0,
              crackProgress: progress,
              semanticLabel: l10n.fortuneEggSemantic(index + 1),
              onTap: () => _onEggTap(index),
            );
          },
        ),
        const SizedBox(height: 8),
        // Progress indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < maxTaps; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < tapCount
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fortuneTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IndexedStack(
            index: _currentStep,
            children: [_buildQuestionStep(), _buildEggsStep()],
          ),
        ),
      ),
    );
  }
}
