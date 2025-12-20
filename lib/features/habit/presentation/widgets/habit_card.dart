// HabitCard (clean) - adjusted margin + gesture behavior to avoid "panning" gap on swipe/scale
import 'package:flutter/material.dart';
import '../../domain/habit_types.dart';
import '../../domain/subtask_model.dart';
import '../../../../core/settings/settings_repository.dart' as app_settings;
import '../../../../l10n/app_localizations.dart';

class HabitCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? emoji;
  final Color color;
  final int currentStreak;
  final int streakCount;
  final int targetCount;
  final bool isCompleted;
  final HabitType habitType;
  final NumericalTargetType? numericalTargetType;
  final TimerTargetType? timerTargetType;
  final String? unit;
  final String? categoryName;
  final VoidCallback onTap;
  final Function(int)? onValueUpdate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAnalyze;
  final bool readOnly;
  final VoidCallback? onAssignToList;
  final int requiredBreakTaps;
  final bool iceEnabled;

  // Per-habit control: whether to show the streak indicator for this habit.
  final bool showStreakIndicator;
  // Callback when user toggles the per-habit streak indicator from the menu.
  final ValueChanged<bool>? onToggleStreakIndicator;

  // NEW: optional margin so parent can override spacing (keeps default aesthetic)
  final EdgeInsets? margin;

  // Subtasks (for subtasks habit type)
  final List<Subtask>? subtasks;
  final Function(String, bool)? onSubtaskToggle;

  const HabitCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.emoji,
    required this.color,
    required this.currentStreak,
    this.streakCount = 0,
    required this.targetCount,
    required this.isCompleted,
    this.habitType = HabitType.simple,
    this.numericalTargetType,
    this.timerTargetType,
    this.unit,
    required this.onTap,
    this.onValueUpdate,
    this.onEdit,
    this.onDelete,
    this.onAnalyze,
    this.readOnly = false,
    this.onAssignToList,
    this.requiredBreakTaps = 0,
    this.iceEnabled = false,
    this.categoryName,
    this.margin,
    this.showStreakIndicator = true,
    this.onToggleStreakIndicator,
    this.subtasks,
    this.onSubtaskToggle,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  int _brokenTaps = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets _defaultMargin(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // side inset = %3 of width, clamped between 12 and 20 for reasonable spacing
    final side = (w * 0.03).clamp(12.0, 20.0);
    return EdgeInsets.symmetric(horizontal: side, vertical: 6);
  }

  // ... (didUpdateWidget, handlers, dialogs, menu, etc. remain unchanged) ...
  @override
  void didUpdateWidget(covariant HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int oldNeed = oldWidget.iceEnabled && !oldWidget.isCompleted
        ? oldWidget.requiredBreakTaps.clamp(0, 7)
        : 0;
    final int newNeed = widget.iceEnabled && !widget.isCompleted
        ? widget.requiredBreakTaps.clamp(0, 7)
        : 0;
    if (newNeed != oldNeed ||
        newNeed == 0 ||
        widget.isCompleted != oldWidget.isCompleted) {
      if (_brokenTaps != 0) {
        setState(() => _brokenTaps = 0);
      }
    }
  }

  void _handleTapDown(TapDownDetails d) {
    if (!widget.readOnly) _controller.forward();
  }

  void _handleTapUp(TapUpDetails d) {
    if (!widget.readOnly) {
      // Simple ve checkbox: doğrudan toggle
      if (widget.habitType == HabitType.simple ||
          widget.habitType == HabitType.checkbox) {
        final need = widget.iceEnabled && !widget.isCompleted
            ? widget.requiredBreakTaps.clamp(0, 7)
            : 0;
        if (need > 0) {
          final next = _brokenTaps + 1;
          if (next < need) {
            setState(() => _brokenTaps = next);
          } else {
            widget.onTap();
            if (_brokenTaps != 0) setState(() => _brokenTaps = 0);
          }
        } else {
          widget.onTap();
          if (_brokenTaps != 0) setState(() => _brokenTaps = 0);
        }
      }
      // Subtasks: diyalog gösterme, alt görevlerden tıklama gerekiyor
      else if (widget.habitType == HabitType.subtasks) {
        // Alt görevler kartın içinde gösterilecek, buradan bir şey yapmaya gerek yok
      }
      // Numerical ve timer: manuel değer girişi
      else {
        _showManualValueDialog();
      }
    }
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  // (showManualValueDialog, _submitManual, _showMenu, _confirmDelete remain identical — omitted here for brevity)
  void _showManualValueDialog() {
    if (widget.readOnly || widget.onValueUpdate == null) return;
    final c = TextEditingController(text: widget.currentStreak.toString());
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final double progress = widget.targetCount > 0
        ? (widget.currentStreak / widget.targetCount).clamp(0.0, 1.0)
        : 0.0;
    String? ruleHint() {
      String unitLabel = '';
      if (widget.unit != null && widget.unit!.isNotEmpty) {
        unitLabel = ' ${widget.unit}';
      } else if (widget.habitType == HabitType.timer) {
        unitLabel = ' ${l10n.minutes.toLowerCase()}';
      }
      final targetText = '${widget.targetCount}$unitLabel';
      if (widget.habitType == HabitType.numerical &&
          widget.numericalTargetType != null) {
        switch (widget.numericalTargetType!) {
          case NumericalTargetType.minimum:
            return l10n.ruleEnteredValueAtLeast(targetText);
          case NumericalTargetType.exact:
            return l10n.ruleEnteredValueExactly(targetText);
          case NumericalTargetType.maximum:
            return l10n.ruleEnteredValueAtMost(targetText);
        }
      }
      if (widget.habitType == HabitType.timer &&
          widget.timerTargetType != null) {
        switch (widget.timerTargetType!) {
          case TimerTargetType.minimum:
            return l10n.ruleEnteredDurationAtLeast(targetText);
          case TimerTargetType.exact:
            return l10n.ruleEnteredDurationExactly(targetText);
          case TimerTargetType.maximum:
            return l10n.ruleEnteredDurationAtMost(targetText);
        }
      }
      return null;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.enterValueTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: c,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.unit ?? l10n.valueLabel,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitManual(c),
            ),
            const SizedBox(height: 8),
            if (ruleHint() != null)
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      ruleHint()!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progress <= 0 ? 0 : progress,
                backgroundColor: cs.outline.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(widget.color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.habitType != HabitType.simple)
                  Text(
                    '${widget.currentStreak} / ${widget.targetCount}${widget.unit != null ? ' ${widget.unit}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => _submitManual(c),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _submitManual(TextEditingController c) {
    final v = int.tryParse(c.text.trim());
    if (v != null && v >= 0) {
      widget.onValueUpdate?.call(v);
      Navigator.pop(context);
    }
  }

  void _showMenu() async {
    if (widget.readOnly) return;
    // Unfocus any active input and wait for the keyboard/focus to settle
    // This prevents gesture/focus conflicts when returning from other tabs
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final l10n = AppLocalizations.of(ctx);
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: Center(
                          child:
                              (widget.emoji != null && widget.emoji!.isNotEmpty)
                              ? Text(
                                  widget.emoji!,
                                  style: const TextStyle(fontSize: 22),
                                )
                              : Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.categoryName != null &&
                    widget.categoryName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.categoryName!,
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: Text(l10n.analysis),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onAnalyze?.call();
                  },
                ),
                if (widget.onAssignToList != null)
                  ListTile(
                    leading: const Icon(Icons.playlist_add_outlined),
                    title: Text(l10n.addToList),
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onAssignToList?.call();
                    },
                  ),
                if (widget.habitType != HabitType.simple &&
                    widget.onValueUpdate != null)
                  ListTile(
                    leading: const Icon(Icons.edit_attributes_outlined),
                    title: Text(l10n.enterValueTitle),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showManualValueDialog();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.edit),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onEdit?.call();
                  },
                ),
                // Per-habit streak toggle (user can show/hide the flame for this habit)
                if (widget.onToggleStreakIndicator != null)
                  ListTile(
                    leading: Icon(
                      widget.showStreakIndicator
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: cs.onSurfaceVariant,
                    ),
                    title: Text(l10n.streakIndicator),
                    trailing: Switch(
                      value: widget.showStreakIndicator,
                      onChanged: (v) {
                        Navigator.pop(ctx);
                        widget.onToggleStreakIndicator?.call(v);
                      },
                    ),
                  ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red[600]),
                  title: Text(
                    l10n.delete,
                    style: TextStyle(color: Colors.red[600]),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onDelete?.call();
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool done = widget.isCompleted;
    final Color completedBg = widget.color;
    final Color onCompleted = completedBg.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;

    final int need = widget.iceEnabled && !done
        ? widget.requiredBreakTaps.clamp(0, 7)
        : 0;
    final int remaining = (need - _brokenTaps).clamp(0, 7);
    final bool remainingCapped = need - _brokenTaps > 7;
    final double frostStrength = need == 0
        ? 0
        : (remaining / need).clamp(0.0, 1.0);

    // Resolve margin (allow override)
    final resolvedMargin = widget.margin ?? _defaultMargin(context);

    return Opacity(
      opacity: widget.readOnly ? 0.55 : 1.0,
      // KEEP margin OUTSIDE the scale transform so spacing is stable during press/swipe
      child: Padding(
        padding: resolvedMargin,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onLongPress: _showMenu,
          // translucent so parent horizontal drags (PageView/Dismissible) work nicer
          behavior: HitTestBehavior.translucent,
          child: ScaleTransition(
            scale: _scale,
            child: Stack(
              children: [
                // Base card (no external margin here anymore)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  decoration: BoxDecoration(
                    color: done
                        ? completedBg
                        : Color.alphaBlend(
                            widget.color.withValues(alpha: 0.06),
                            cs.surfaceContainerHighest,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: done
                        ? [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child:
                                  (widget.emoji != null &&
                                      widget.emoji!.isNotEmpty)
                                  ? Text(
                                      widget.emoji!,
                                      style: const TextStyle(fontSize: 24),
                                    )
                                  : Icon(
                                      widget.icon,
                                      color: done ? onCompleted : widget.color,
                                      size: 24,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: done ? onCompleted : cs.onSurface,
                                      // Tighter line-height when there's no description so
                                      // the single-line title visually centers with
                                      // the emoji/check area.
                                      height: widget.description.isEmpty
                                          ? 1.02
                                          : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        widget.description,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: done
                                                  ? onCompleted
                                                  : cs.onSurfaceVariant,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (need > 0 && !done && remaining > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.ac_unit,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    remainingCapped ? '+7' : '$remaining',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (app_settings
                                  .SettingsRepository
                                  .instance
                                  .showStreakIndicators &&
                              widget.showStreakIndicator &&
                              (widget.streakCount > 0 ||
                                  (widget.habitType == HabitType.simple &&
                                      widget.streakCount == 0 &&
                                      widget.currentStreak > 0)))
                            Container(
                              key: const ValueKey('streak-flame-emoji'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.streakCount > 0 ? widget.streakCount : (widget.habitType == HabitType.simple ? widget.currentStreak : widget.streakCount)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done
                                    ? widget.color
                                    : Color.alphaBlend(
                                        widget.color.withValues(alpha: 0.10),
                                        cs.surfaceContainerHighest,
                                      ),
                                boxShadow: done
                                    ? [
                                        BoxShadow(
                                          color: widget.color.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: widget.isCompleted
                                    ? Icon(
                                        Icons.check,
                                        key: const ValueKey('checked'),
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : const SizedBox(
                                        key: ValueKey('unchecked'),
                                      ),
                              ),
                            ),
                        ],
                      ),
                      // Subtasks listesi (sadece subtasks habit type için)
                      if (widget.habitType == HabitType.subtasks &&
                          widget.subtasks != null &&
                          widget.subtasks!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.subtasks!.length,
                            itemBuilder: (context, index) {
                              final subtask = widget.subtasks![index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: subtask.isCompleted,
                                        onChanged: widget.readOnly
                                            ? null
                                            : (val) {
                                                if (widget.onSubtaskToggle !=
                                                    null) {
                                                  widget.onSubtaskToggle!(
                                                    subtask.id,
                                                    val ?? false,
                                                  );
                                                }
                                              },
                                        activeColor: done
                                            ? onCompleted.withValues(alpha: 0.8)
                                            : widget.color,
                                        checkColor: Colors.white,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        subtask.title,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: done
                                                  ? onCompleted.withValues(
                                                      alpha: 0.9,
                                                    )
                                                  : cs.onSurface.withValues(
                                                      alpha: 0.8,
                                                    ),
                                              decoration: subtask.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (need > 0 && !done)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: frostStrength * 0.9,
                        curve: Curves.easeOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blueGrey.shade100.withOpacity(0.6),
                                      Colors.lightBlue.shade100.withOpacity(
                                        0.5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CustomPaint(painter: _FrostPainter()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 40; i++) {
      final dx = (i * 37) % size.width;
      final dy = (i * 59) % size.height;
      final r = 1.0 + (i % 3);
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
