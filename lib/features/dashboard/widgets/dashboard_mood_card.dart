import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../design_system/tokens/colors.dart';
import '../../mood/mood_screen.dart';
import '../../mood/data/mood_repository.dart';
import '../../mood/data/mood_entry.dart';
import '../../mood/data/mood_models.dart';
import '../../mood/presentation/mood_selection_screen.dart';
import '../../mood/presentation/mood_analytics_screen.dart';
import '../../../design_system/theme/theme_variations.dart';

enum Mood { terrible, bad, ok, good, great }

IconData _iconFor(Mood m) => switch (m) {
  Mood.terrible => Icons.sentiment_very_dissatisfied,
  Mood.bad => Icons.sentiment_dissatisfied,
  Mood.ok => Icons.sentiment_neutral,
  Mood.good => Icons.sentiment_satisfied,
  Mood.great => Icons.sentiment_very_satisfied,
};

Color _colorFor(Mood m) => switch (m) {
  Mood.terrible => Colors.redAccent,
  Mood.bad => Colors.deepOrange,
  Mood.ok => AppColors.accentSand,
  Mood.good => AppColors.accentBlue,
  Mood.great => AppColors.accentGold,
};

class DashboardMoodCard extends StatefulWidget {
  const DashboardMoodCard({super.key, required this.variant});

  final ThemeVariant variant;

  @override
  State<DashboardMoodCard> createState() => _DashboardMoodCardState();
}

class _DashboardMoodCardState extends State<DashboardMoodCard> {
  Mood? _selected;
  final _repo = MoodRepository();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _repo.initialize();
      final today = DateTime.now();
      final existing = _repo.getForDate(today);
      if (existing != null) {
        _selected = _toDashboardMood(existing.mood);
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  Mood _toDashboardMood(MoodValue v) => Mood.values[v.index];
  MoodValue _toRepoMood(Mood m) => MoodValue.values[m.index];

  Future<void> _selectAndNavigate(Mood m) async {
    setState(() => _selected = m);
    HapticFeedback.selectionClick();
    await _repo.upsertForDate(DateTime.now(), _toRepoMood(m), null);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MoodFlowState(),
          child: const MoodSelectionScreen(),
        ),
      ),
    );
    // refresh on return (in case edits happened)
    final latest = _repo.getForDate(DateTime.now());
    if (mounted) {
      setState(() {
        _selected = latest != null ? _toDashboardMood(latest.mood) : _selected;
      });
    }
  }

  void _openMoodScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MoodFlowState(),
          child: const MoodSelectionScreen(),
        ),
      ),
    );
    // When returning, try to reflect persisted state
    final latest = _repo.getForDate(DateTime.now());
    if (mounted) {
      setState(
        () => _selected = latest != null
            ? _toDashboardMood(latest.mood)
            : _selected,
      );
    }
  }

  void _openAnalytics() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MoodAnalyticsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final bool usePurple = widget.variant == ThemeVariant.world;
    final localTheme = usePurple
        ? base.copyWith(
            colorScheme: base.colorScheme.copyWith(
              primary: AppColors.accentPurple,
            ),
          )
        : base;
    final fill = Color.alphaBlend(
      localTheme.colorScheme.primary.withValues(alpha: 0.12),
      localTheme.colorScheme.surfaceContainerHighest,
    );
    return Theme(
      data: localTheme,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          // Use the available vertical space and center the icon inside it to avoid overflow
          children: [
            Expanded(
              child: Builder(
                builder: (ctx) {
                  final swipeBg = Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: const Icon(Icons.insights_outlined),
                      color: localTheme.colorScheme.onSurfaceVariant,
                      onPressed: _openAnalytics,
                    ),
                  );
                  return Dismissible(
                    key: const ValueKey('dashboard_mood_dismissible'),
                    // Allow horizontal swipes in both directions
                    direction: DismissDirection.horizontal,
                    // Use the same background for both sides so the Dismissible assertion is satisfied
                    background: swipeBg,
                    secondaryBackground: swipeBg,
                    // Prevent actual dismiss — we only want the swipe-to-reveal affordance
                    confirmDismiss: (_) async {
                      // If the user swipes fully, treat it as opening analytics
                      _openAnalytics();
                      return false;
                    },
                    child: InkWell(
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      onTap: _openMoodScreen,
                      child: Center(
                        child: Padding(
                          // Use symmetric vertical padding to keep the icon centered visually
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Icon(
                            _selected != null
                                ? _iconFor(_selected!)
                                : Icons.sentiment_neutral,
                            color: _selected != null
                                ? _colorFor(_selected!)
                                : localTheme.colorScheme.onSurfaceVariant,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
