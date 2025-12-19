import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/timer/timer_controller.dart';
import '../../../design_system/theme/theme_variations.dart';
import '../../../design_system/tokens/colors.dart';

/// Fullscreen landscape timer view optimized for OLED (true black background)
/// and focus. Shows large time with minimal chrome.
class LandscapeTimerScreen extends StatefulWidget {
  const LandscapeTimerScreen({super.key, this.variant});
  final ThemeVariant? variant;

  @override
  State<LandscapeTimerScreen> createState() => _LandscapeTimerScreenState();
}

class _LandscapeTimerScreenState extends State<LandscapeTimerScreen>
    with SingleTickerProviderStateMixin {
  final controller = TimerController.instance;
  late final VoidCallback _listener;
  Timer? _hideUiDebounce;
  Timer? _dimDebounce;
  bool _dimmed = false;
  bool _useOledTheme = true; // true black vs app theme
  late final AnimationController _driftCtl;
  static const String _prefsKeyOledTheme = 'landscape_timer_use_oled';

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsKeyOledTheme);
    if (!mounted) return;
    if (saved != null) setState(() => _useOledTheme = saved);
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyOledTheme, _useOledTheme);
  }

  // Theme helpers
  Color _bg(BuildContext context) =>
      _useOledTheme ? Colors.black : Theme.of(context).colorScheme.surface;
  Color _onBg(BuildContext context) =>
      _useOledTheme ? Colors.white : Theme.of(context).colorScheme.onSurface;
  Color _onBgMuted(BuildContext context) {
    final base = _onBg(context);
    return base.withValues(alpha: _useOledTheme ? 0.7 : 0.8);
  }

  Color _outline(BuildContext context) => _useOledTheme
      ? Colors.white24
      : Theme.of(context).colorScheme.outlineVariant;
  bool get _isWorld => widget.variant == ThemeVariant.world;
  Color _accent(BuildContext context) =>
      _isWorld ? AppColors.accentPurple : Theme.of(context).colorScheme.primary;
  Color _primaryFill(BuildContext context) {
    if (_useOledTheme) return Colors.white;
    // World variant: custom blended panel style for purple accent
    if (_isWorld) {
      final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
      return Color.alphaBlend(
        _accent(context).withValues(alpha: 0.12),
        surface,
      );
    }
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Color _onPrimaryFill(BuildContext context) => _useOledTheme
      ? Colors.black
      : _isWorld
      ? _accent(context)
      : Theme.of(context).colorScheme.onPrimaryContainer;
  Color _inactiveFill(BuildContext context) => _useOledTheme
      ? Colors.white10
      : Theme.of(context).colorScheme.surfaceContainerHighest;
  Color _inactiveIcon(BuildContext context) => _useOledTheme
      ? Colors.white38
      : Theme.of(context).colorScheme.onSurfaceVariant;
  Color _trackColor(BuildContext context) => _useOledTheme
      ? Colors.white12
      : Theme.of(context).colorScheme.surfaceContainerHighest;
  Color _primaryColor(BuildContext context) =>
      _useOledTheme ? Colors.white : _accent(context);

  @override
  void initState() {
    super.initState();
    _listener = () => setState(() {});
    controller.addListener(_listener);
    // Lock orientation to landscape and enable immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Very slow drift for burn-in mitigation
    _driftCtl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();
    // Start inactivity dim timer
    _resetInactivity();
    // Load persisted theme preference
    _loadPrefs();
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    _hideUiDebounce?.cancel();
    _dimDebounce?.cancel();
    _driftCtl.dispose();
    // Restore orientation and system UI
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _reHideSystemUI() {
    _hideUiDebounce?.cancel();
    _hideUiDebounce = Timer(const Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  void _resetInactivity() {
    setState(() => _dimmed = false);
    _dimDebounce?.cancel();
    _dimDebounce = Timer(const Duration(seconds: 20), () {
      if (mounted) setState(() => _dimmed = true);
    });
  }

  void _onUserActivity() {
    _reHideSystemUI();
    _resetInactivity();
  }

  Offset _driftOffset() {
    // Calculate a small Lissajous curve offset within +/- 6px range
    final t = _driftCtl.value * 2 * math.pi;
    final dx = math.sin(t) * 6.0;
    final dy = math.sin(t * 0.7 + math.pi / 3) * 6.0;
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Palette per theme
    final bg = _bg(context);
    final fg = _onBg(context);
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: _onUserActivity,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          // Leave top/bottom padding minimal in immersive mode
          top: false,
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _driftCtl,
                  builder: (context, child) =>
                      Transform.translate(offset: _driftOffset(), child: child),
                  child: _buildContent(context, l10n),
                ),
              ),
              // Dim overlay after inactivity
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: _dimmed ? 0.35 : 0.0,
                    child: Container(color: Colors.black),
                  ),
                ),
              ),
              // Close button (top-right)
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  icon: Icon(Icons.close, color: fg),
                  onPressed: () {
                    _feedback();
                    Navigator.of(context).maybePop();
                  },
                ),
              ),

              // Vertical icon-only mode switcher (right side)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _modeIconButton(
                        context,
                        icon: Icons.timer,
                        selected: controller.activeMode == TimerMode.stopwatch,
                        onTap: () {
                          controller.setMode(TimerMode.stopwatch);
                          _onUserActivity();
                        },
                        tooltip: l10n.timerTabStopwatch,
                      ),
                      const SizedBox(height: 12),
                      _modeIconButton(
                        context,
                        icon: Icons.hourglass_bottom,
                        selected: controller.activeMode == TimerMode.countdown,
                        onTap: () {
                          controller.setMode(TimerMode.countdown);
                          _onUserActivity();
                        },
                        tooltip: l10n.timerTabCountdown,
                      ),
                      const SizedBox(height: 12),
                      _modeIconButton(
                        context,
                        icon: Icons.local_fire_department,
                        selected: controller.activeMode == TimerMode.pomodoro,
                        onTap: () {
                          controller.setMode(TimerMode.pomodoro);
                          _onUserActivity();
                        },
                        tooltip: l10n.timerTabPomodoro,
                      ),
                    ],
                  ),
                ),
              ),

              // Left-side theme toggle button (OLED <-> App theme)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _modeIconButton(
                        context,
                        icon: _useOledTheme
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        selected: false,
                        onTap: () async {
                          setState(() => _useOledTheme = !_useOledTheme);
                          await _savePrefs();
                          _onUserActivity();
                        },
                        tooltip: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeIconButton(
    BuildContext context, {
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final bg = selected ? _primaryFill(context) : _inactiveFill(context);
    final fg = selected ? _onPrimaryFill(context) : _onBgMuted(context);
    final btn = InkWell(
      onTap: () {
        _feedback();
        onTap();
      },
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(
            color: selected ? _outline(context) : _outline(context),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _useOledTheme ? Colors.white10 : Colors.black12,
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: fg, size: 22),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    switch (controller.activeMode) {
      case TimerMode.stopwatch:
        return _buildStopwatch(context, l10n);
      case TimerMode.countdown:
        return _buildCountdown(context, l10n);
      case TimerMode.pomodoro:
        return _buildPomodoro(context, l10n);
    }
  }

  // Large typography helper
  TextStyle _megaDigits(BuildContext context) => TextStyle(
    fontFeatures: const [FontFeature.tabularFigures()],
    fontSize: 140,
    letterSpacing: 2,
    fontWeight: FontWeight.w700,
    color: _onBg(context),
  );

  TextStyle _subDigits(BuildContext context) => TextStyle(
    fontFeatures: const [FontFeature.tabularFigures()],
    fontSize: 24,
    color: _onBgMuted(context),
    fontWeight: FontWeight.w600,
  );

  Widget _bigTime(String value, {String? subtitle}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(child: Text(value, style: _megaDigits(context))),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: _subDigits(context)),
        ],
      ],
    );
  }

  Widget _controls({required List<Widget> actions}) {
    // Make horizontally scrollable to avoid overflow on narrow widths
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: actions
            .map(
              (w) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: w,
              ),
            )
            .toList(),
      ),
    );
  }

  // Stopwatch layout
  Widget _buildStopwatch(BuildContext context, AppLocalizations l10n) {
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.stopwatch;
    return Container(
      color: _bg(context),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _bigTime(controller.formatDuration(controller.elapsed)),
              const SizedBox(height: 24),
              _controls(
                actions: [
                  _btn(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    isRunning ? l10n.pause : l10n.start,
                    () {
                      _feedback();
                      isRunning ? controller.pause() : controller.start();
                      _onUserActivity();
                    },
                  ),
                  _btn(
                    Icons.flag,
                    l10n.finish,
                    controller.elapsed.inSeconds > 0
                        ? () {
                            _feedback();
                            controller.finish();
                            _onUserActivity();
                          }
                        : null,
                  ),
                  _btnOutlined(
                    Icons.restart_alt,
                    l10n.reset,
                    controller.elapsed.inSeconds > 0
                        ? () {
                            _feedback();
                            controller.reset();
                            _onUserActivity();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Countdown layout with ring
  Widget _buildCountdown(BuildContext context, AppLocalizations l10n) {
    final rem = controller.countdownRemaining;
    final total = controller.countdownTotal;
    final hasDuration = controller.hasCountdown;
    final progress = hasDuration && total.inSeconds > 0
        ? 1 - (rem.inSeconds / total.inSeconds)
        : 0.0;
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.countdown;
    return Container(
      color: _bg(context),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Time and optional subtitle
              _bigTime(
                controller.formatDuration(rem),
                subtitle: hasDuration
                    ? '${l10n.totalDuration}: ${controller.formatDuration(total)}'
                    : l10n.timerSetDurationFirst,
              ),
              const SizedBox(height: 16),
              // Linear progress below time
              FractionallySizedBox(
                widthFactor: 0.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(
                      begin: 0,
                      end: hasDuration ? progress.clamp(0.0, 1.0) : 0,
                    ),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      color: _primaryColor(context),
                      backgroundColor: _trackColor(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _controls(
                actions: [
                  _btn(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    isRunning ? l10n.pause : l10n.start,
                    !hasDuration
                        ? null
                        : () {
                            _feedback();
                            isRunning
                                ? controller.pause()
                                : controller.startCountdown();
                            _onUserActivity();
                          },
                  ),
                  _btn(
                    Icons.flag,
                    l10n.finish,
                    hasDuration && (rem != total)
                        ? () {
                            _feedback();
                            controller.finish();
                            _onUserActivity();
                          }
                        : null,
                  ),
                  _btnOutlined(
                    Icons.restart_alt,
                    l10n.reset,
                    hasDuration
                        ? () {
                            _feedback();
                            controller.reset();
                            _onUserActivity();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pomodoro layout
  Widget _buildPomodoro(BuildContext context, AppLocalizations l10n) {
    final isRunning =
        controller.isRunning && controller.activeMode == TimerMode.pomodoro;
    final phase = controller.pomodoroWorkPhase
        ? l10n.timerPomodoroWorkPhase
        : l10n.timerPomodoroBreakPhase;
    return Container(
      color: _bg(context),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                phase,
                style: TextStyle(
                  color: _onBgMuted(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _bigTime(
                controller.formattedTime,
                subtitle: l10n.timerPomodoroCompletedWork(
                  controller.pomodoroCompletedWorkSessions,
                ),
              ),
              const SizedBox(height: 24),
              _controls(
                actions: [
                  _btn(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    isRunning ? l10n.pause : l10n.start,
                    () {
                      _feedback();
                      isRunning
                          ? controller.pause()
                          : controller.startPomodoro();
                      _onUserActivity();
                    },
                  ),
                  _btn(Icons.flag, l10n.finish, () {
                    _feedback();
                    controller.finish();
                    _onUserActivity();
                  }),
                  _btnOutlined(
                    Icons.skip_next,
                    l10n.timerPomodoroSkipPhase,
                    controller.activeMode == TimerMode.pomodoro
                        ? () {
                            _feedback();
                            controller.skipPomodoroPhase();
                            _onUserActivity();
                          }
                        : null,
                  ),
                  _btnOutlined(Icons.restart_alt, l10n.reset, () {
                    _feedback();
                    controller.reset();
                    _onUserActivity();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback? onPressed) {
    final enabled = onPressed != null;
    final bg = enabled ? _primaryFill(context) : _inactiveFill(context);
    final fg = enabled ? _onPrimaryFill(context) : _inactiveIcon(context);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: fg),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  Widget _btnOutlined(IconData icon, String label, VoidCallback? onPressed) {
    final side = BorderSide(color: _outline(context));
    final fg = _onBgMuted(context);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: side,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: fg),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  void _feedback() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }
}
