import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/timer/timer_controller.dart';
import '../../../design_system/theme/theme_variations.dart';
import '../../../../design_system/tokens/colors.dart';
import '../timer_screen.dart';

class DashboardTimerCard extends StatefulWidget {
  const DashboardTimerCard({super.key, required this.variant});
  final ThemeVariant variant;

  @override
  State<DashboardTimerCard> createState() => _DashboardTimerCardState();
}

class _DashboardTimerCardState extends State<DashboardTimerCard> {
  final controller = TimerController.instance;
  TimerMode? _selected; // seçilen mod (genişlemiş görünüm)
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onChange);
  }

  @override
  void dispose() {
    controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  void _openFull(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TimerScreen(variant: widget.variant)),
    );
  }

  void _selectMode(TimerMode mode) {
    setState(() {
      _selected = mode;
      _expanded = true;
    });
    controller.setMode(mode);
  }

  void _collapse() {
    if (!mounted) return;
    setState(() {
      _expanded = false;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isRunning = controller.isRunning;
    // Dünya temasında mor accent kullan
    final bool isWorld = widget.variant == ThemeVariant.world;
    final Color accent = isWorld ? AppColors.accentPurple : scheme.primary;
    final fill = Color.alphaBlend(
      accent.withValues(alpha: 0.12),
      scheme.surfaceContainerHighest,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: !_expanded ? () => _openFull(context) : null,
      child: SizedBox(
        width: double.infinity,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: fill,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _expanded
                ? _ExpandedControls(
                    theme: theme,
                    accent: accent,
                    selected: _selected ?? controller.activeMode,
                    isRunning: isRunning,
                    onCollapse: _collapse,
                    onOpenFull: () => _openFull(context),
                  )
                : _ModeChooser(
                    title: l10n.timerType,
                    accent: accent,
                    theme: theme,
                    onSelect: _selectMode,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ModeChooser extends StatelessWidget {
  const _ModeChooser({
    required this.title,
    required this.accent,
    required this.theme,
    required this.onSelect,
  });
  final String title;
  final Color accent;
  final ThemeData theme;
  final ValueChanged<TimerMode> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BigIconButton(
              icon: Icons.timer,
              label: l10n.timerTabStopwatch,
              color: accent,
              onTap: () => onSelect(TimerMode.stopwatch),
            ),
            _BigIconButton(
              icon: Icons.hourglass_bottom,
              label: l10n.timerTabCountdown,
              color: accent,
              onTap: () => onSelect(TimerMode.countdown),
            ),
            _BigIconButton(
              icon: Icons.local_fire_department,
              label: l10n.timerTabPomodoro,
              color: accent,
              onTap: () => onSelect(TimerMode.pomodoro),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpandedControls extends StatelessWidget {
  const _ExpandedControls({
    required this.theme,
    required this.accent,
    required this.selected,
    required this.isRunning,
    required this.onCollapse,
    required this.onOpenFull,
  });
  final ThemeData theme;
  final Color accent;
  final TimerMode selected;
  final bool isRunning;
  final VoidCallback onCollapse;
  final VoidCallback onOpenFull;

  @override
  Widget build(BuildContext context) {
    final controller = TimerController.instance;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          controller.formattedTime,
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              tooltip: l10n.reset,
              onPressed: () {
                HapticFeedback.selectionClick();
                controller.reset();
              },
              icon: Icon(Icons.restart_alt, color: accent),
              style: IconButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.15),
                foregroundColor: accent,
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: isRunning ? l10n.pause : l10n.start,
              onPressed: () {
                HapticFeedback.selectionClick();
                switch (selected) {
                  case TimerMode.stopwatch:
                    isRunning ? controller.pause() : controller.start();
                    break;
                  case TimerMode.countdown:
                    if (!controller.hasCountdown ||
                        controller.countdownTotal == Duration.zero) {
                      controller.setCountdown(const Duration(minutes: 10));
                    }
                    isRunning
                        ? controller.pause()
                        : controller.startCountdown();
                    break;
                  case TimerMode.pomodoro:
                    isRunning ? controller.pause() : controller.startPomodoro();
                    break;
                }
              },
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
              style: IconButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: l10n.fullScreen,
              onPressed: onOpenFull,
              icon: Icon(Icons.open_in_full, color: accent),
              style: IconButton.styleFrom(
                backgroundColor: accent.withValues(alpha: 0.15),
                foregroundColor: accent,
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: l10n.close,
              onPressed: onCollapse,
              icon: Icon(
                Icons.close,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.outlineVariant.withValues(
                  alpha: 0.10,
                ),
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BigIconButton extends StatelessWidget {
  const _BigIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
