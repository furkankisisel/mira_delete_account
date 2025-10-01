import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/mood_models.dart';
import '../data/detailed_mood_repository.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _saveAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _saveScaleAnimation;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;
  bool _didSchedulePop = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _saveScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _saveAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    // Listen to text changes
    _textController.addListener(() {
      final moodState = context.read<MoodFlowState>();
      moodState.setJournalText(_textController.text);
    });

    // Auto-focus the text field after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveAnimationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final moodState = context.watch<MoodFlowState>();

    if (moodState.selectedReason == null) {
      if (!_didSchedulePop) {
        _didSchedulePop = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).maybePop();
        });
      }
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.journalEntry),
        centerTitle: true,
        actions: [
          if (moodState.canSave)
            IconButton(
              onPressed: _isSaving ? null : _saveMoodEntry,
              icon: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onSurface,
                        ),
                      ),
                    )
                  : const Icon(Icons.save),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    l10n.tellUsMore,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.journalEntryDesc,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Mood summary card
                  _buildMoodSummaryCard(theme, l10n, moodState),

                  const SizedBox(height: 24),

                  // Journal text field
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: 8,
                      textAlignVertical: TextAlignVertical.top,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: l10n.journalHint,
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  ScaleTransition(
                    scale: _saveScaleAnimation,
                    child: ElevatedButton(
                      onPressed: moodState.canSave && !_isSaving
                          ? _saveMoodEntry
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSaving
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.saving),
                              ],
                            )
                          : Text(
                              l10n.saveEntry,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSummaryCard(
    ThemeData theme,
    AppLocalizations l10n,
    MoodFlowState moodState,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _getMoodGradient(moodState.selectedMood!),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.yourMoodToday,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                icon: _getMoodIcon(moodState.selectedMood!),
                label: _getMoodTitle(moodState.selectedMood!, l10n),
                theme: theme,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                icon: _getSubEmotionIcon(moodState.selectedSubEmotion!),
                label: _getSubEmotionTitle(moodState.selectedSubEmotion!, l10n),
                theme: theme,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                icon: _getReasonIcon(moodState.selectedReason!),
                label: _getReasonTitle(moodState.selectedReason!, l10n),
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _saveMoodEntry() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });

    try {
      final moodState = context.read<MoodFlowState>();

      // Create new mood entry with the new model structure
      final newEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        mood: moodState.selectedMood!,
        subEmotion: moodState.selectedSubEmotion!,
        reason: moodState.selectedReason!,
        journalText: moodState.journalText,
      );

      // Save using our detailed mood repository
      final repository = DetailedMoodRepository();
      await repository.saveMoodEntry(newEntry);

      // Show success message
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.entrySaved),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Reset the flow state
        moodState.reset();

        // Navigate back to dashboard
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Helper methods for getting display data
  List<Color> _getMoodGradient(MoodLevel mood) {
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

  IconData _getSubEmotionIcon(SubEmotion subEmotion) {
    // Same as in mood_sub_emotion_screen.dart
    switch (subEmotion) {
      case SubEmotion.exhausted:
        return Icons.battery_0_bar;
      case SubEmotion.helpless:
        return Icons.help_outline;
      case SubEmotion.hopeless:
        return Icons.cloud_off;
      case SubEmotion.hurt:
        return Icons.favorite_border;
      case SubEmotion.drained:
        return Icons.water_drop_outlined;
      case SubEmotion.angry:
        return Icons.flash_on;
      case SubEmotion.sad:
        return Icons.sentiment_dissatisfied;
      case SubEmotion.anxious:
        return Icons.psychology;
      case SubEmotion.stressed:
        return Icons.speed;
      case SubEmotion.demoralized:
        return Icons.trending_down;
      case SubEmotion.indecisive:
        return Icons.shuffle;
      case SubEmotion.tired:
        return Icons.bedtime;
      case SubEmotion.ordinary:
        return Icons.remove;
      case SubEmotion.calm:
        return Icons.spa;
      case SubEmotion.empty:
        return Icons.crop_free;
      case SubEmotion.happy:
        return Icons.sentiment_satisfied;
      case SubEmotion.cheerful:
        return Icons.emoji_emotions;
      case SubEmotion.excited:
        return Icons.celebration;
      case SubEmotion.enthusiastic:
        return Icons.local_fire_department;
      case SubEmotion.determined:
        return Icons.flag;
      case SubEmotion.motivated:
        return Icons.trending_up;
      case SubEmotion.amazing:
        return Icons.auto_awesome;
      case SubEmotion.energetic:
        return Icons.bolt;
      case SubEmotion.peaceful:
        return Icons.self_improvement;
      case SubEmotion.grateful:
        return Icons.favorite;
      case SubEmotion.loving:
        return Icons.volunteer_activism;
    }
  }

  String _getSubEmotionTitle(SubEmotion subEmotion, AppLocalizations l10n) {
    // We'll need to add these localization keys
    switch (subEmotion) {
      case SubEmotion.exhausted:
        return l10n.subEmotionExhausted;
      case SubEmotion.helpless:
        return l10n.subEmotionHelpless;
      case SubEmotion.hopeless:
        return l10n.subEmotionHopeless;
      case SubEmotion.hurt:
        return l10n.subEmotionHurt;
      case SubEmotion.drained:
        return l10n.subEmotionDrained;
      case SubEmotion.angry:
        return l10n.subEmotionAngry;
      case SubEmotion.sad:
        return l10n.subEmotionSad;
      case SubEmotion.anxious:
        return l10n.subEmotionAnxious;
      case SubEmotion.stressed:
        return l10n.subEmotionStressed;
      case SubEmotion.demoralized:
        return l10n.subEmotionDemoralized;
      case SubEmotion.indecisive:
        return l10n.subEmotionIndecisive;
      case SubEmotion.tired:
        return l10n.subEmotionTired;
      case SubEmotion.ordinary:
        return l10n.subEmotionOrdinary;
      case SubEmotion.calm:
        return l10n.subEmotionCalm;
      case SubEmotion.empty:
        return l10n.subEmotionEmpty;
      case SubEmotion.happy:
        return l10n.subEmotionHappy;
      case SubEmotion.cheerful:
        return l10n.subEmotionCheerful;
      case SubEmotion.excited:
        return l10n.subEmotionExcited;
      case SubEmotion.enthusiastic:
        return l10n.subEmotionEnthusiastic;
      case SubEmotion.determined:
        return l10n.subEmotionDetermined;
      case SubEmotion.motivated:
        return l10n.subEmotionMotivated;
      case SubEmotion.amazing:
        return l10n.subEmotionAmazing;
      case SubEmotion.energetic:
        return l10n.subEmotionEnergetic;
      case SubEmotion.peaceful:
        return l10n.subEmotionPeaceful;
      case SubEmotion.grateful:
        return l10n.subEmotionGrateful;
      case SubEmotion.loving:
        return l10n.subEmotionLoving;
    }
  }

  IconData _getReasonIcon(ReasonCategory reason) {
    switch (reason) {
      case ReasonCategory.academic:
        return Icons.school;
      case ReasonCategory.work:
        return Icons.work;
      case ReasonCategory.relationship:
        return Icons.favorite;
      case ReasonCategory.finance:
        return Icons.attach_money;
      case ReasonCategory.health:
        return Icons.health_and_safety;
      case ReasonCategory.social:
        return Icons.people;
      case ReasonCategory.personalGrowth:
        return Icons.psychology;
      case ReasonCategory.weather:
        return Icons.wb_sunny;
      case ReasonCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getReasonTitle(ReasonCategory reason, AppLocalizations l10n) {
    switch (reason) {
      case ReasonCategory.academic:
        return l10n.reasonAcademic;
      case ReasonCategory.work:
        return l10n.reasonWork;
      case ReasonCategory.relationship:
        return l10n.reasonRelationship;
      case ReasonCategory.finance:
        return l10n.reasonFinance;
      case ReasonCategory.health:
        return l10n.reasonHealth;
      case ReasonCategory.social:
        return l10n.reasonSocial;
      case ReasonCategory.personalGrowth:
        return l10n.reasonPersonalGrowth;
      case ReasonCategory.weather:
        return l10n.reasonWeather;
      case ReasonCategory.other:
        return l10n.reasonOther;
    }
  }
}
