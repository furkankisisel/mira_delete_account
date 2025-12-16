import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design_system/tokens/colors.dart';
import '../../fortune_eggs/widgets/fortune_egg.dart' as fe;
import '../../fortune_eggs/data/answers.dart';
import 'dart:math';

import '../../../design_system/theme/theme_variations.dart';

class DashboardFortuneEggsCard extends StatefulWidget {
  const DashboardFortuneEggsCard({super.key, required this.variant});
  final ThemeVariant variant;

  @override
  State<DashboardFortuneEggsCard> createState() =>
      _DashboardFortuneEggsCardState();
}

class _DashboardFortuneEggsCardState extends State<DashboardFortuneEggsCard> {
  late PageController _pageController;
  int _selected = 0;
  late List<fe.EggTheme> _themes;
  List<String>? _answers;
  // Track the last answer index shown for each egg so we can avoid immediate repeats
  List<int>? _lastAnswerIndexForEgg;
  bool _didDependenciesInit = false;

  @override
  void initState() {
    super.initState();
    // Narrower viewport so eggs take less horizontal space
    _pageController = PageController(viewportFraction: 0.85);
    final rnd = Random();
    final all = fe.EggTheme.values.toList();
    all.shuffle(rnd);
    // Show all available egg themes in the dashboard pager (not just 3)
    _themes = all;
    // Ensure the last-answer index list exists immediately so quick taps
    // before didChangeDependencies don't crash.
    _lastAnswerIndexForEgg = List<int>.filled(_themes.length, -1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didDependenciesInit) {
      // Pick as many distinct answers as there are eggs so indexing is safe
      _answers = FortuneAnswers.pickDistinct(
        AppLocalizations.of(context).localeName,
        _themes.length,
      );
      // Initialize last-seen indices to -1 (none shown yet)
      _lastAnswerIndexForEgg = List<int>.filled(_themes.length, -1);
      _didDependenciesInit = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAnswer(int eggIndex) {
    final l10n = AppLocalizations.of(context);

    // Choose a random answer index from the pool but avoid returning the same
    // answer that was shown for this egg on the immediately previous tap.
    final rnd = Random();
    // Lazily initialize answers and tracking if not already set so a quick tap
    // immediately produces a response instead of a "loading" message.
    _answers ??= FortuneAnswers.pickDistinct(
      AppLocalizations.of(context).localeName,
      _themes.length,
    );
    _lastAnswerIndexForEgg ??= List<int>.filled(_themes.length, -1);

    final answers = _answers!;
    final lastIndices = _lastAnswerIndexForEgg!;
    final poolSize = answers.length;
    if (poolSize == 0) return; // defensive

    int pick = rnd.nextInt(poolSize);
    if (lastIndices[eggIndex] >= 0 && poolSize > 1) {
      // If we accidentally picked the same index, pick again (guarantees different)
      while (pick == lastIndices[eggIndex]) {
        pick = rnd.nextInt(poolSize);
      }
    }

    lastIndices[eggIndex] = pick;
  final answer = answers[pick % poolSize];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.fortunePlay),
        content: Text(answer, textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isWorld = widget.variant == ThemeVariant.world;
    final Color accent = isWorld ? AppColors.accentPurple : cs.secondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.12),
          cs.surfaceContainerHighest,
        ),
      ),
      // Make the pager expand horizontally and size the egg relative to available width
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availW = constraints.maxWidth;
          // Use most of the width for the pager so eggs look large in compact dashboard
          final pagerWidth = availW;
          // Compute egg size relative to pager width, but clamp to a reasonable max
          final eggSize = (pagerWidth * 0.75).clamp(48.0, 100.0);

          return Center(
            child: SizedBox(
              width: pagerWidth,
              height: eggSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _themes.length,
                    onPageChanged: (i) => setState(() => _selected = i),
                    itemBuilder: (context, i) => Center(
                      child: fe.FortuneEgg(
                        theme: _themes[i],
                        size: eggSize * 0.84,
                        crackProgress: 0,
                        isSelected: _selected == i,
                        onTap: () => _showAnswer(i),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Opacity(
                      opacity: 0.18,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              size: 28,
                              color: accent,
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 28,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
