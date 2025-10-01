import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../data/mood_models.dart';
import 'mood_journal_screen.dart';

class MoodReasonScreen extends StatefulWidget {
  const MoodReasonScreen({super.key});

  @override
  State<MoodReasonScreen> createState() => _MoodReasonScreenState();
}

class _MoodReasonScreenState extends State<MoodReasonScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _didSchedulePop = false;

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
    final moodState = context.watch<MoodFlowState>();

    if (moodState.selectedSubEmotion == null) {
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
      appBar: AppBar(title: Text(l10n.selectReason), centerTitle: true),
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
                  l10n.whatsTheCause,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.selectReasonDesc,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                    itemCount: ReasonCategory.values.length,
                    itemBuilder: (context, index) {
                      final reason = ReasonCategory.values[index];
                      return _ReasonCard(
                        reason: reason,
                        onTap: () => _onReasonSelected(reason),
                        animationDelay: Duration(milliseconds: 80 * index),
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

  void _onReasonSelected(ReasonCategory reason) {
    final moodState = context.read<MoodFlowState>();
    moodState.setReason(reason);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider.value(
              value: moodState,
              child: const MoodJournalScreen(),
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

class _ReasonCard extends StatefulWidget {
  final ReasonCategory reason;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _ReasonCard({
    required this.reason,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  State<_ReasonCard> createState() => _ReasonCardState();
}

class _ReasonCardState extends State<_ReasonCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
              child: Container(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getReasonColor(
                                widget.reason,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              _getReasonIcon(widget.reason),
                              size: 24,
                              color: _getReasonColor(widget.reason),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getReasonTitle(widget.reason, l10n),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getReasonColor(ReasonCategory reason) {
    switch (reason) {
      case ReasonCategory.academic:
        return Colors.blue;
      case ReasonCategory.work:
        return Colors.orange;
      case ReasonCategory.relationship:
        return Colors.pink;
      case ReasonCategory.finance:
        return Colors.green;
      case ReasonCategory.health:
        return Colors.red;
      case ReasonCategory.social:
        return Colors.purple;
      case ReasonCategory.personalGrowth:
        return Colors.teal;
      case ReasonCategory.weather:
        return Colors.cyan;
      case ReasonCategory.other:
        return Colors.grey;
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
