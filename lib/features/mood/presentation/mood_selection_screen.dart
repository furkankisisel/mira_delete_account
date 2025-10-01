import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/mood_models.dart';
import 'mood_sub_emotion_screen.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moodSelection), centerTitle: true),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n.howAreYouFeeling,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.selectYourCurrentMood,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.separated(
                    itemCount: MoodLevel.values.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final mood = MoodLevel.values[index];
                      return _MoodOption(
                        mood: mood,
                        onTap: () => _onMoodSelected(mood),
                        animationDelay: Duration(milliseconds: 100 * index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMoodSelected(MoodLevel mood) {
    final moodState = context.read<MoodFlowState>();
    moodState.setMood(mood);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider.value(
              value: moodState,
              child: const MoodSubEmotionScreen(),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _MoodOption extends StatefulWidget {
  final MoodLevel mood;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _MoodOption({
    required this.mood,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  State<_MoodOption> createState() => _MoodOptionState();
}

class _MoodOptionState extends State<_MoodOption>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    Future.delayed(widget.animationDelay, () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
            child: Material(
              elevation: _isHovered ? 8 : 2,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: _getMoodGradient(widget.mood, theme),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          _getMoodIcon(widget.mood),
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getMoodTitle(widget.mood, l10n),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getMoodDescription(widget.mood, l10n),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getMoodGradient(MoodLevel mood, ThemeData theme) {
    switch (mood) {
      case MoodLevel.terrible:
        return [Colors.red.shade600, Colors.red.shade800];
      case MoodLevel.bad:
        return [Colors.orange.shade600, Colors.red.shade600];
      case MoodLevel.neutral:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case MoodLevel.good:
        return [Colors.green.shade500, Colors.green.shade700];
      case MoodLevel.excellent:
        return [Colors.purple.shade500, Colors.purple.shade700];
    }
  }

  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.terrible:
        return Icons.sentiment_very_dissatisfied;
      case MoodLevel.bad:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.neutral:
        return Icons.sentiment_neutral;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied;
    }
  }

  String _getMoodTitle(MoodLevel mood, AppLocalizations l10n) {
    switch (mood) {
      case MoodLevel.terrible:
        return l10n.moodTerrible;
      case MoodLevel.bad:
        return l10n.moodBad;
      case MoodLevel.neutral:
        return l10n.moodNeutral;
      case MoodLevel.good:
        return l10n.moodGood;
      case MoodLevel.excellent:
        return l10n.moodExcellent;
    }
  }

  String _getMoodDescription(MoodLevel mood, AppLocalizations l10n) {
    switch (mood) {
      case MoodLevel.terrible:
        return l10n.moodTerribleDesc;
      case MoodLevel.bad:
        return l10n.moodBadDesc;
      case MoodLevel.neutral:
        return l10n.moodNeutralDesc;
      case MoodLevel.good:
        return l10n.moodGoodDesc;
      case MoodLevel.excellent:
        return l10n.moodExcellentDesc;
    }
  }
}
