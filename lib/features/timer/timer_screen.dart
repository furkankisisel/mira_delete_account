import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';
import '../../core/timer/timer_controller.dart';
import '../../design_system/theme/theme_variations.dart';
import '../../design_system/tokens/colors.dart';
import '../habit/domain/habit_repository.dart';
import '../habit/domain/habit_types.dart';
import 'widgets/landscape_timer_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, this.variant});
  final ThemeVariant? variant;
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  final controller = TimerController.instance;
  late TabController _tabController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  static const double _historySectionHeight = 180;

  // Countdown inputs
  final _cdHours = TextEditingController(text: '0');
  final _cdMinutes = TextEditingController(text: '0');
  final _cdSeconds = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    controller.addListener(_onChange);
  }

  @override
  void dispose() {
    controller.removeListener(_onChange);
    _tabController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    _cdHours.dispose();
    _cdMinutes.dispose();
    _cdSeconds.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  // Normalize and apply countdown duration
  void _applyCountdown() {
    int h = int.tryParse(_cdHours.text) ?? 0;
    int m = int.tryParse(_cdMinutes.text) ?? 0;
    int s = int.tryParse(_cdSeconds.text) ?? 0;
    if (h < 0) h = 0;
    if (m < 0) m = 0;
    if (s < 0) s = 0;
    m += s ~/ 60;
    s %= 60;
    h += m ~/ 60;
    m %= 60;
    controller.setCountdown(Duration(hours: h, minutes: m, seconds: s));
  }

  Color _getAccentColor(BuildContext context) {
    final theme = Theme.of(context);
    final bool isWorld = widget.variant == ThemeVariant.world;
    return isWorld ? AppColors.accentPurple : theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = _getAccentColor(context);
    final isDark = theme.brightness == Brightness.dark;

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: accent),
        appBarTheme: theme.appBarTheme.copyWith(foregroundColor: accent),
        iconTheme: theme.iconTheme.copyWith(color: accent),
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? theme.scaffoldBackgroundColor
            : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.timerType,
            style: theme.textTheme.titleLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.stay_current_landscape,
                  color: accent,
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        LandscapeTimerScreen(variant: widget.variant),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (i) {
                  if (i == 0) controller.setMode(TimerMode.stopwatch);
                  if (i == 1) controller.setMode(TimerMode.countdown);
                  if (i == 2) controller.setMode(TimerMode.pomodoro);
                },
                indicator: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? Colors.white70
                    : Colors.grey[600],
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 18),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.timerTabStopwatch,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_bottom_outlined, size: 18),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.timerTabCountdown,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.timerTabPomodoro,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStopwatch(context),
            _buildCountdown(context),
            _buildPomodoro(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTimer({
    required BuildContext context,
    required String timeText,
    required double progress,
    required bool isRunning,
    String? subtitle,
    Color? progressColor,
  }) {
    final theme = Theme.of(context);
    final accent = progressColor ?? _getAccentColor(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth * 0.7, 280.0);

        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = isRunning
                ? 1.0 + (_pulseController.value * 0.02)
                : 1.0;

            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress arc
                    SizedBox(
                      width: size - 16,
                      height: size - 16,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _CircularProgressPainter(
                              progress: progress,
                              strokeWidth: 8,
                              progressColor: accent,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey[200]!,
                              isAnimating: isRunning,
                              animationValue: _progressController.value,
                            ),
                          );
                        },
                      ),
                    ),
                    // Time display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subtitle != null) ...[
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: size * 0.12,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isRunning)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'RUNNING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final accent = color ?? _getAccentColor(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final buttonColor = isDestructive
        ? Colors.red
        : isPrimary
        ? accent
        : (isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : colorScheme.surfaceContainerHighest);

    final textColor = isDestructive || isPrimary
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.85) : colorScheme.onSurface);

    return Container(
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary || isDestructive
            ? null
            : Border.all(
                color: isDark
                    ? colorScheme.outline.withValues(alpha: 0.15)
                    : colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
        boxShadow: isPrimary || isDestructive
            ? [
                BoxShadow(
                  color: (isDestructive ? Colors.red : accent)
                      .withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(
    BuildContext context, {
    required bool isRunning,
    required VoidCallback onPlayPause,
    required VoidCallback? onFinish,
    required VoidCallback? onReset,
    VoidCallback? onSettings,
    VoidCallback? onSkip,
  }) {
    final l10n = AppLocalizations.of(context);
    final accent = _getAccentColor(context);

    return Column(
      children: [
        // Main play/pause button
        GestureDetector(
          onTap: onPlayPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRunning
                    ? [Colors.orange, Colors.deepOrange]
                    : [accent, accent.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isRunning ? Colors.orange : accent).withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Secondary buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            if (onFinish != null)
              _buildActionButton(
                icon: Icons.flag_rounded,
                label: l10n.finish,
                onPressed: onFinish,
                isPrimary: true,
              ),
            if (onReset != null)
              _buildActionButton(
                icon: Icons.refresh_rounded,
                label: l10n.reset,
                onPressed: onReset,
              ),
            if (onSkip != null)
              _buildActionButton(
                icon: Icons.skip_next_rounded,
                label: l10n.timerPomodoroSkipPhase,
                onPressed: onSkip,
              ),
            if (onSettings != null)
              _buildActionButton(
                icon: Icons.tune_rounded,
                label: l10n.settings,
                onPressed: onSettings,
              ),
          ],
        ),
        // Pending duration indicator
        if (controller.hasPending) ...[
          const SizedBox(height: 20),
          _buildPendingCard(context),
        ],
      ],
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = _getAccentColor(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: isDark ? 0.15 : 0.08),
            Colors.amber.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: isDark ? 0.25 : 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                color: Colors.amber[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.timerPendingLabel(
                    controller.formatDuration(controller.pendingDuration),
                  ),
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Compact action buttons for Pomodoro screen
  Widget _buildCompactActionButtons(
    BuildContext context, {
    required bool isRunning,
    required VoidCallback onPlayPause,
    required VoidCallback? onFinish,
    required VoidCallback? onReset,
    VoidCallback? onSettings,
    VoidCallback? onSkip,
  }) {
    final l10n = AppLocalizations.of(context);
    final accent = _getAccentColor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side actions
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onFinish != null)
              _buildMiniIconAction(
                icon: Icons.flag_rounded,
                tooltip: l10n.finish,
                onPressed: onFinish,
                color: accent,
              ),
            if (onFinish != null && onReset != null) const SizedBox(height: 8),
            if (onReset != null)
              _buildMiniIconAction(
                icon: Icons.refresh_rounded,
                tooltip: l10n.reset,
                onPressed: onReset,
              ),
          ],
        ),
        const SizedBox(width: 14),

        // Center play/pause
        GestureDetector(
          onTap: onPlayPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRunning
                    ? [Colors.orange, Colors.deepOrange]
                    : [accent, accent.withValues(alpha: 0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isRunning ? Colors.orange : accent).withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Right side actions
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSkip != null)
              _buildMiniIconAction(
                icon: Icons.skip_next_rounded,
                tooltip: l10n.timerPomodoroSkipPhase,
                onPressed: onSkip,
              ),
            if (onSkip != null && onSettings != null) const SizedBox(height: 8),
            if (onSettings != null)
              _buildMiniIconAction(
                icon: Icons.tune_rounded,
                tooltip: l10n.settings,
                onPressed: onSettings,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniIconAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = color != null
        ? Colors.white
        : (isDark ? Colors.grey[200] : Colors.grey[800]);

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            gradient: color != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.8)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: color == null
                ? Border.all(
                    color: isDark
                        ? Colors.grey.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.3),
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = color != null
        ? Colors.white
        : (isDark ? Colors.grey[300] : Colors.grey[800]);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          gradient: color != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.8)],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: color == null
              ? Border.all(
                  color: isDark
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopwatch(BuildContext context) {
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.stopwatch;
    final elapsed = controller.elapsed;
    final progress = (elapsed.inSeconds % 60) / 60.0;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: _buildCircularTimer(
              context: context,
              timeText: controller.formatDuration(elapsed),
              progress: progress,
              isRunning: isRunning,
              subtitle: 'STOPWATCH',
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _buildFloatingActionButtons(
              context,
              isRunning: isRunning,
              onPlayPause: () =>
                  isRunning ? controller.pause() : controller.start(),
              onFinish: elapsed.inSeconds > 0 ? controller.finish : null,
              onReset: elapsed.inSeconds > 0 ? controller.reset : null,
            ),
          ),
        ),
        if (controller.sessions.isNotEmpty) ...[
          const Divider(height: 1),
          SizedBox(height: _historySectionHeight, child: _buildHistoryList()),
        ],
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final rem = controller.countdownRemaining;
    final total = controller.countdownTotal;
    final hasDuration = controller.hasCountdown;
    final progress = hasDuration && total.inSeconds > 0
        ? rem.inSeconds / total.inSeconds
        : 1.0;
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.countdown;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: hasDuration
                ? _buildCircularTimer(
                    context: context,
                    timeText: controller.formatDuration(rem),
                    progress: progress,
                    isRunning: isRunning,
                    subtitle: 'COUNTDOWN',
                    progressColor: rem.inSeconds <= 10 ? Colors.red : null,
                  )
                : _buildSetDurationPrompt(context),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _buildFloatingActionButtons(
              context,
              isRunning: isRunning,
              onPlayPause: !hasDuration
                  ? _showCountdownConfigDialog
                  : () => isRunning
                        ? controller.pause()
                        : controller.startCountdown(),
              onFinish: hasDuration && (rem != total)
                  ? controller.finish
                  : null,
              onReset: hasDuration ? controller.reset : null,
              onSettings: _showCountdownConfigDialog,
            ),
          ),
        ),
        if (controller.sessions.isNotEmpty) ...[
          const Divider(height: 1),
          SizedBox(height: _historySectionHeight, child: _buildHistoryList()),
        ],
      ],
    );
  }

  Widget _buildSetDurationPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = _getAccentColor(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _showCountdownConfigDialog,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.04),
                  ]
                : [
                    Colors.white,
                    accent.withValues(alpha: 0.05),
                  ],
          ),
          border: Border.all(
            color: accent.withValues(alpha: isDark ? 0.4 : 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, size: 32, color: accent),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.timerSetDurationFirst,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPomodoro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.pomodoro;
    final isWorkPhase = controller.pomodoroWorkPhase;
    final remaining = controller.pomodoroRemaining;
    final total = isWorkPhase
        ? controller.pomodoroWorkDuration
        : (controller.pomodoroCompletedWorkSessions %
                      controller.pomodoroLongBreakInterval ==
                  0
              ? controller.pomodoroLongBreakDuration
              : controller.pomodoroShortBreakDuration);
    final progress = total.inSeconds > 0
        ? remaining.inSeconds / total.inSeconds
        : 1.0;

    final accent = _getAccentColor(context);
    final phaseColor = isWorkPhase ? accent : Colors.green;

    return Column(
      children: [
        // Pomodoro sessions indicator - more compact
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.pomodoroLongBreakInterval, (
              index,
            ) {
              final isCompleted =
                  index <
                  controller.pomodoroCompletedWorkSessions %
                      controller.pomodoroLongBreakInterval;
              final isCurrent =
                  index ==
                  controller.pomodoroCompletedWorkSessions %
                      controller.pomodoroLongBreakInterval;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 16 : 12,
                  height: isCurrent ? 16 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isCompleted || isCurrent
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent,
                              accent.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: isCompleted || isCurrent
                        ? null
                        : Colors.grey.withValues(alpha: 0.25),
                    border: isCurrent
                        ? Border.all(color: accent.withValues(alpha: 0.4), width: 2)
                        : null,
                    boxShadow: isCompleted || isCurrent
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.3),
                              blurRadius: isCurrent ? 6 : 3,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
        // Timer
        Expanded(
          flex: 4,
          child: Center(
            child: _buildCircularTimer(
              context: context,
              timeText: controller.formatDuration(remaining),
              progress: progress,
              isRunning: isRunning,
              subtitle: isWorkPhase ? 'FOCUS' : 'BREAK',
              progressColor: phaseColor,
            ),
          ),
        ),
        // Phase indicator - compact
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                phaseColor.withValues(alpha: 0.15),
                phaseColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: phaseColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isWorkPhase ? Icons.laptop_mac : Icons.coffee,
                size: 14,
                color: phaseColor,
              ),
              const SizedBox(width: 8),
              Text(
                isWorkPhase
                    ? l10n.timerPomodoroWorkPhase
                    : l10n.timerPomodoroBreakPhase,
                style: TextStyle(
                  color: phaseColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: phaseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${controller.pomodoroCompletedWorkSessions}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Buttons - compact with padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildCompactActionButtons(
            context,
            isRunning: isRunning,
            onPlayPause: () =>
                isRunning ? controller.pause() : controller.startPomodoro(),
            onFinish: controller.finish,
            onReset: controller.reset,
            onSettings: _showPomodoroConfigDialog,
            onSkip: controller.activeMode == TimerMode.pomodoro
                ? controller.skipPomodoroPhase
                : null,
          ),
        ),
        // History list - take remaining space
        if (controller.sessions.isNotEmpty) ...[
          const Divider(height: 1),
          SizedBox(height: _historySectionHeight, child: _buildHistoryList()),
        ],
      ],
    );
  }

  Widget _buildHistoryList() {
    final l10n = AppLocalizations.of(context);
    final sessions = controller.sessions;
    final theme = Theme.of(context);
    final accent = _getAccentColor(context);
    final isDark = theme.brightness == Brightness.dark;

    if (sessions.isEmpty) {
      return Center(child: Text(l10n.noEntriesYet));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                l10n.historyTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (sessions.isNotEmpty)
                TextButton(
                  onPressed: controller.clearHistory,
                  child: Text(
                    l10n.clearHistory,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];
              final modeLabel = switch (s.mode) {
                TimerMode.stopwatch => l10n.timerTabStopwatch,
                TimerMode.countdown => l10n.timerTabCountdown,
                TimerMode.pomodoro => s.label ?? l10n.timerTabPomodoro,
              };
              final durStr = controller.formatDuration(s.duration);

              return GestureDetector(
                onTap: () => _onSessionTap(index),
                onLongPress: () => _confirmDeleteSession(index),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12, bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: s.assigned
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accent.withValues(alpha: 0.12),
                              accent.withValues(alpha: 0.06),
                            ],
                          )
                        : null,
                    color: s.assigned
                        ? null
                        : (isDark
                            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: s.assigned
                        ? Border.all(color: accent.withValues(alpha: 0.3), width: 1.5)
                        : Border.all(
                            color: isDark
                                ? theme.colorScheme.outline.withValues(alpha: 0.1)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            width: 1,
                          ),
                    boxShadow: [
                      if (s.assigned)
                        BoxShadow(
                          color: accent.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      else if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _iconForMode(s.mode),
                            size: 16,
                            color: s.assigned ? accent : Colors.grey,
                          ),
                          if (s.assigned) ...[
                            const Spacer(),
                            Icon(Icons.check_circle, size: 14, color: accent),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            durStr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            modeLabel,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDeleteSession(int index) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        title: Text(
          l10n.delete,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.deleteEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.removeSessionAt(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  IconData _iconForMode(TimerMode mode) => switch (mode) {
    TimerMode.stopwatch => Icons.timer_outlined,
    TimerMode.countdown => Icons.hourglass_bottom_outlined,
    TimerMode.pomodoro => Icons.local_fire_department_outlined,
  };

  void _showSaveDialog() {
    final l10n = AppLocalizations.of(context);
    final repo = HabitRepository.instance;
    final timerHabits = repo.habits
        .where((h) => h.habitType == HabitType.timer)
        .toList();
    if (timerHabits.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerCreateTimerHabitFirst)));
      return;
    }
    String? selectedId =
        controller.activeTimerHabitId ??
        (timerHabits.isNotEmpty ? timerHabits.first.id : null);

    final accent = _getAccentColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        title: Text(
          l10n.timerSaveDurationTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.15),
                    accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.formatDuration(controller.pendingDuration),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedId,
              decoration: InputDecoration(
                labelText: l10n.habit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: timerHabits
                  .map(
                    (h) => DropdownMenuItem(value: h.id, child: Text(h.title)),
                  )
                  .toList(),
              onChanged: (v) => selectedId = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedId != null) {
                await controller.savePendingToHabit(selectedId!);
                controller.setActiveTimerHabit(selectedId);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _onSessionTap(int index) {
    final l10n = AppLocalizations.of(context);
    final sessions = controller.sessions;
    if (index < 0 || index >= sessions.length) return;
    final s = sessions[index];
    if (s.assigned) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerSessionAlreadySaved)));
      return;
    }
    final repo = HabitRepository.instance;
    final timerHabits = repo.habits
        .where((h) => h.habitType == HabitType.timer)
        .toList();
    if (timerHabits.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerCreateTimerHabitFirst)));
      return;
    }
    String? selectedId = controller.activeTimerHabitId ?? timerHabits.first.id;
    final accent = _getAccentColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        title: Text(
          l10n.timerSaveSessionTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.15),
                    accent.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time, color: accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.formatDuration(s.duration),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedId,
              decoration: InputDecoration(
                labelText: l10n.habit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: timerHabits
                  .map(
                    (h) => DropdownMenuItem(value: h.id, child: Text(h.title)),
                  )
                  .toList(),
              onChanged: (v) => selectedId = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedId != null) {
                await controller.assignSessionToHabit(index, selectedId!);
                controller.setActiveTimerHabit(selectedId);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  // Countdown settings popup
  void _showCountdownConfigDialog() {
    final l10n = AppLocalizations.of(context);
    final accent = _getAccentColor(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.countdownConfigureTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _modernTimeField(
                    controller: _cdHours,
                    label: l10n.hours,
                    accent: accent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 24, color: accent),
                  ),
                ),
                Expanded(
                  child: _modernTimeField(
                    controller: _cdMinutes,
                    label: l10n.minutes,
                    accent: accent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 24, color: accent),
                  ),
                ),
                Expanded(
                  child: _modernTimeField(
                    controller: _cdSeconds,
                    label: l10n.seconds,
                    accent: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.timerQuickPresets,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _modernPresetButton('1m', accent, minutes: 1),
                _modernPresetButton('5m', accent, minutes: 5),
                _modernPresetButton('10m', accent, minutes: 10),
                _modernPresetButton('15m', accent, minutes: 15),
                _modernPresetButton('25m', accent, minutes: 25),
                _modernPresetButton('30m', accent, minutes: 30),
                _modernPresetButton('45m', accent, minutes: 45),
                _modernPresetButton('1h', accent, hours: 1),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _applyCountdown();
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernTimeField({
    required TextEditingController controller,
    required String label,
    required Color accent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      colorScheme.surfaceContainerHighest,
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? colorScheme.outline.withValues(alpha: 0.15)
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: accent,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 18),
            ),
            onSubmitted: (_) => _applyCountdown(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _modernPresetButton(
    String label,
    Color accent, {
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            _cdHours.text = hours.toString();
            _cdMinutes.text = minutes.toString();
            _cdSeconds.text = seconds.toString();
            setState(() {});
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(color: accent, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  // Pomodoro settings popup
  void _showPomodoroConfigDialog() {
    final l10n = AppLocalizations.of(context);
    final accent = _getAccentColor(context);
    final workCtrl = TextEditingController(
      text: controller.pomodoroWorkDuration.inMinutes.toString(),
    );
    final shortCtrl = TextEditingController(
      text: controller.pomodoroShortBreakDuration.inMinutes.toString(),
    );
    final longCtrl = TextEditingController(
      text: controller.pomodoroLongBreakDuration.inMinutes.toString(),
    );
    final intervalCtrl = TextEditingController(
      text: controller.pomodoroLongBreakInterval.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.timerPomodoroSettings,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _modernSettingField(
              controller: workCtrl,
              label: l10n.timerPomodoroWorkMinutesLabel,
              icon: Icons.laptop_mac,
              accent: accent,
            ),
            const SizedBox(height: 16),
            _modernSettingField(
              controller: shortCtrl,
              label: l10n.timerPomodoroShortBreakMinutesLabel,
              icon: Icons.coffee,
              accent: Colors.green,
            ),
            const SizedBox(height: 16),
            _modernSettingField(
              controller: longCtrl,
              label: l10n.timerPomodoroLongBreakMinutesLabel,
              icon: Icons.self_improvement,
              accent: Colors.blue,
            ),
            const SizedBox(height: 16),
            _modernSettingField(
              controller: intervalCtrl,
              label: l10n.timerPomodoroLongBreakIntervalLabel,
              icon: Icons.repeat,
              accent: Colors.orange,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final w = int.tryParse(workCtrl.text) ?? 25;
                  final s = int.tryParse(shortCtrl.text) ?? 5;
                  final l = int.tryParse(longCtrl.text) ?? 15;
                  final iv = int.tryParse(intervalCtrl.text) ?? 4;
                  controller.setPomodoroConfig(
                    work: Duration(minutes: w),
                    shortBreak: Duration(minutes: s),
                    longBreak: Duration(minutes: l),
                    longBreakInterval: iv,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernSettingField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.outline.withValues(alpha: 0.15)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.20),
                  accent.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.grey[700],
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: accent,
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Text(
            'min',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
    required this.isAnimating,
    required this.animationValue,
  });

  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final bool isAnimating;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Animated glow effect when running
    if (isAnimating && progress > 0) {
      final glowPaint = Paint()
        ..color = progressColor.withValues(
          alpha: 0.3 * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi)),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isAnimating != isAnimating ||
        oldDelegate.animationValue != animationValue;
  }
}
