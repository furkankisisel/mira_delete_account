import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:ui' as ui;
// removed dart:math; not needed for minimal XP toast
import 'package:share_plus/share_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_system/theme/app_theme.dart';
import 'design_system/theme/theme_variations.dart';
import 'design_system/tokens/colors.dart';
import 'core/language_manager.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/habit/presentation/habit_screen.dart';
import 'features/finance/finance_screen.dart';
import 'features/finance/finance_analysis_screen.dart';
import 'features/vision/presentation/vision_screen.dart';
import 'features/profile/profile_screen.dart';
// Removed Decision Egg feature
import 'features/gamification/gamification_repository.dart';
import 'features/notifications/data/notification_settings_repository.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/habit/domain/habit_repository.dart';
// Removed unused imports related to text/image sticker creation relocated to Vision FAB
import 'core/settings/settings_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/presentation/splash_screen.dart';
import 'features/onboarding/data/onboarding_repository.dart';
import 'core/privacy/privacy_service.dart';
import 'features/profile/auth_repository.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/test_choice_screen.dart';
// In-app purchase and premium management
import 'services/premium_manager.dart';
import 'services/iap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // In widget tests, Firebase may not be available; guard initialization.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // ignore: avoid_print
    if (kDebugMode) {
      debugPrint('Firebase.initializeApp skipped in this context');
    }
  }
  runApp(const MiraApp());
}

class MiraApp extends StatefulWidget {
  const MiraApp({super.key});
  @override
  State<MiraApp> createState() => _MiraAppState();
}

class _MiraAppState extends State<MiraApp> {
  ThemeMode _mode = ThemeMode.light;
  ThemeVariant _variant = AppTheme.defaultVariant;
  late LanguageManager _languageManager;

  @override
  void initState() {
    super.initState();
    _languageManager = LanguageManager();
    _languageManager.addListener(_onLanguageChanged);
    _initializeLanguageManager();
    _initializeThemePreferences();
    // Initialize global settings
    // ignore: discarded_futures
    SettingsRepository.instance.initialize();
    unawaited(_initializeNotifications());
    // Initialize subscription/premium system
    unawaited(_initializeSubscriptionSystem());
    // Privacy service (consent toggles)
    // ignore: discarded_futures
    PrivacyService.instance.initialize();
  }

  static const _prefThemeMode = 'pref_theme_mode_v1';
  static const _prefThemeVariant = 'pref_theme_variant_v1';

  Future<void> _initializeThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_prefThemeMode);
      final variantIndex = prefs.getInt(_prefThemeVariant);
      if (modeIndex != null &&
          modeIndex >= 0 &&
          modeIndex < ThemeMode.values.length) {
        _mode = ThemeMode.values[modeIndex];
      }
      if (variantIndex != null &&
          variantIndex >= 0 &&
          variantIndex < ThemeVariant.values.length) {
        _variant = ThemeVariant.values[variantIndex];
      }
      if (mounted) setState(() {});
    } catch (_) {
      // ignore
    }
  }

  Future<void> _initializeLanguageManager() async {
    await _languageManager.initialize();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationSettingsRepository.instance.initialize();
      await NotificationService.instance.initialize();
      await NotificationService.instance.applySettings(
        NotificationSettingsRepository.instance,
      );

      // Initialize habit reminders
      await _initializeHabitReminders();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error initializing notifications: $e');
      // ignore failures so they do not block app launch
    }
  }

  /// Initialize subscription/premium system.
  /// Loads premium status from storage and sets up purchase listeners.
  Future<void> _initializeSubscriptionSystem() async {
    try {
      debugPrint('🔄 Initializing subscription system...');
      // Initialize premium manager (loads from SharedPreferences)
      await PremiumManager.instance.init();
      // Initialize IAP service (sets up Google Play billing)
      await IAPService.instance.init();
      debugPrint('✅ Subscription system initialized');
    } catch (e) {
      debugPrint('❌ Error initializing subscription system: $e');
      // Continue app launch even if subscription init fails
    }
  }

  Future<void> _initializeHabitReminders() async {
    try {
      if (kDebugMode) debugPrint('🔍 Initializing habit reminders...');
      final repo = HabitRepository.instance;
      await repo.initialize();
      final habits = repo.habits;
      if (kDebugMode) debugPrint('   Found ${habits.length} habits');

      int reminderCount = 0;
      for (final habit in habits) {
        if (kDebugMode) debugPrint('   Checking habit: ${habit.title}');
        if (kDebugMode) {
          debugPrint('     - reminderEnabled: ${habit.reminderEnabled}');
        }
        if (kDebugMode) {
          debugPrint('     - reminderTime: ${habit.reminderTime}');
        }

        if (habit.reminderEnabled && habit.reminderTime != null) {
          reminderCount++;
          await NotificationService.instance.scheduleHabitReminder(habit);
        }
      }
      if (kDebugMode) {
        debugPrint('✅ Initialized $reminderCount habit reminders');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error initializing habit reminders: $e');
      // ignore failures
    }
  }

  @override
  void dispose() {
    _languageManager.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _persistTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefThemeMode, _mode.index);
      await prefs.setInt(_prefThemeVariant, _variant.index);
    } catch (_) {
      // ignore
    }
  }

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    _persistTheme();
  }

  void _changeThemeVariant(ThemeVariant variant) {
    setState(() => _variant = variant);
    _persistTheme();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Mira',
    locale: _languageManager.currentLocale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: _languageManager.supportedLocales,
    theme: AppTheme.light(_variant),
    darkTheme: AppTheme.dark(_variant),
    themeMode: _mode,
    home: OnboardingCheckWrapper(
      onToggleTheme: _toggleTheme,
      themeMode: _mode,
      currentVariant: _variant,
      onVariantChanged: _changeThemeVariant,
      languageManager: _languageManager,
    ),
  );
}

/// Wrapper widget that checks onboarding status and shows appropriate screen
class OnboardingCheckWrapper extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final ThemeVariant currentVariant;
  final ValueChanged<ThemeVariant> onVariantChanged;
  final LanguageManager languageManager;

  const OnboardingCheckWrapper({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.currentVariant,
    required this.onVariantChanged,
    required this.languageManager,
  });

  @override
  State<OnboardingCheckWrapper> createState() => _OnboardingCheckWrapperState();
}

class _OnboardingCheckWrapperState extends State<OnboardingCheckWrapper> {
  bool _showSplash = true;
  bool? _isOnboardingCompleted;
  bool _authInitialized = false;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    // Listen to auth changes to update UI after sign-in
    AuthRepository.instance.addListener(_onAuthChanged);
  }

  Future<void> _initializeApp() async {
    // Initialize auth (silent sign-in) and check onboarding status in parallel
    try {
      await AuthRepository.instance.initialize();
    } catch (_) {}
    final isCompleted = await OnboardingRepository().isOnboardingCompleted();
    if (!mounted) return;
    setState(() {
      _isOnboardingCompleted = isCompleted;
      _authInitialized = true;
      _isSignedIn = AuthRepository.instance.isSignedIn;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {
      _isSignedIn = AuthRepository.instance.isSignedIn;
    });
  }

  @override
  void dispose() {
    AuthRepository.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return SplashScreen(onInitializationComplete: _onSplashComplete);
    }

    // If checks are still loading after splash, keep showing splash briefly
    if (_isOnboardingCompleted == null || !_authInitialized) {
      return SplashScreen(onInitializationComplete: _onSplashComplete);
    }

    // If onboarding is not completed, require Google sign-in first
    if (!_isOnboardingCompleted!) {
      if (!_isSignedIn) {
        return const SignInScreen();
      }
      // Show test choice screen with callbacks to update wrapper state
      return TestChoiceScreen(
        onSkip: () async {
          final isCompleted = await OnboardingRepository()
              .isOnboardingCompleted();
          if (!mounted) return;
          setState(() => _isOnboardingCompleted = isCompleted);
        },
        onStart: () async {
          // when returning from onboarding, refresh flag
          // We attach a post-frame callback to check later
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final isCompleted = await OnboardingRepository()
                .isOnboardingCompleted();
            if (!mounted) return;
            setState(() => _isOnboardingCompleted = isCompleted);
          });
        },
      );
    }

    // Show main home page if completed
    return PrototypeHomePage(
      onToggleTheme: widget.onToggleTheme,
      themeMode: widget.themeMode,
      currentVariant: widget.currentVariant,
      onVariantChanged: widget.onVariantChanged,
      languageManager: widget.languageManager,
    );
  }
}

class PrototypeHomePage extends StatefulWidget {
  const PrototypeHomePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.currentVariant,
    required this.onVariantChanged,
    required this.languageManager,
  });
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final ThemeVariant currentVariant;
  final ValueChanged<ThemeVariant> onVariantChanged;
  final LanguageManager languageManager;
  @override
  State<PrototypeHomePage> createState() => _PrototypeHomePageState();
}

class _PrototypeHomePageState extends State<PrototypeHomePage> {
  int _currentIndex = 0;
  late final PageController _pageController;
  final GlobalKey<HabitScreenState> _habitKey = GlobalKey<HabitScreenState>();
  final GlobalKey<FinanceScreenState> _financeKey =
      GlobalKey<FinanceScreenState>();
  final ValueNotifier<bool> _visionFreeform = ValueNotifier(false);
  final ValueNotifier<bool> _visionRoundCorners = ValueNotifier(true);
  final ValueNotifier<bool> _visionShowText = ValueNotifier(true);
  final ValueNotifier<bool> _visionShowProgress = ValueNotifier(false);
  late final StreamSubscription<int> _xpSub;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNavTap(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int i) => setState(() => _currentIndex = i);

  Widget _buildPage(int index) => switch (index) {
    0 => DashboardScreen(variant: widget.currentVariant),
    1 => HabitScreen(key: _habitKey),
    2 => FinanceScreen(key: _financeKey, variant: widget.currentVariant),
    3 => VisionScreen(
      variant: widget.currentVariant,
      freeformNotifier: _visionFreeform,
      roundCornersNotifier: _visionRoundCorners,
      showTextNotifier: _visionShowText,
      showProgressNotifier: _visionShowProgress,
      boardBoundaryKey: _visionBoardKey,
    ),
    4 => ProfileScreen(
      onToggleTheme: widget.onToggleTheme,
      themeMode: widget.themeMode,
      currentVariant: widget.currentVariant,
      onVariantChanged: widget.onVariantChanged,
      languageManager: widget.languageManager,
    ),
    _ => const SizedBox.shrink(),
  };

  Widget _buildBody() => PageView.builder(
    controller: _pageController,
    onPageChanged: _onPageChanged,
    // Disable swipe on Vision screen (index 3) to prevent accidental navigation
    physics: _currentIndex == 3
        ? const NeverScrollableScrollPhysics()
        : const PageScrollPhysics(),
    itemCount: 5,
    itemBuilder: (context, index) => _buildPage(index),
  );

  String _titleFor(int i, AppLocalizations l10n) => switch (i) {
    0 => l10n.dashboard,
    1 => l10n.habits,
    2 => l10n.finance,
    3 => l10n.vision,
    4 => l10n.profile,
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    NotificationService.instance.updateLocalizations(l10n);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        // Use scaffoldBackgroundColor to guarantee exact match with page background
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(_titleFor(_currentIndex, l10n)),
        actions: [
          if (_currentIndex == 3)
            ValueListenableBuilder<bool>(
              valueListenable: _visionFreeform,
              builder: (context, isFreeform, _) => isFreeform
                  ? IconButton(
                      tooltip: l10n.visionSettingsTooltip,
                      icon: const Icon(Icons.tune),
                      onPressed: () => _showFreeformSettings(context),
                    )
                  : const SizedBox.shrink(),
            ),
          if (_currentIndex == 3)
            ValueListenableBuilder<bool>(
              valueListenable: _visionFreeform,
              builder: (context, isFreeform, _) => IconButton(
                tooltip: isFreeform
                    ? l10n.visionBoardViewTooltip
                    : l10n.visionFreeformTooltip,
                icon: Icon(isFreeform ? Icons.grid_view : Icons.open_in_full),
                onPressed: () => _visionFreeform.value = !isFreeform,
              ),
            ),
          if (_currentIndex == 1)
            IconButton(
              tooltip: l10n.filterTooltip,
              icon: const Icon(Icons.filter_list),
              onPressed: () => _habitKey.currentState?.showFilterSheet(),
            ),
          if (_currentIndex == 1)
            IconButton(
              tooltip: l10n.selectDate,
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _habitKey.currentState?.showCalendar(),
            ),
          if (_currentIndex == 2)
            IconButton(
              tooltip: l10n.selectMonthTooltip,
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _financeKey.currentState?.showMonthPicker(),
            ),
          if (_currentIndex == 2)
            IconButton(
              tooltip: l10n.analysisTooltip,
              icon: const Icon(Icons.insights_outlined),
              onPressed: () {
                final month =
                    _financeKey.currentState?.currentMonth ?? DateTime.now();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FinanceAnalysisScreen(
                      month: DateTime(month.year, month.month, 1),
                      variant: widget.currentVariant,
                    ),
                  ),
                );
              },
            ),
          // Premium navigation removed — subscriptions cleaned from project.
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: widget.currentVariant == ThemeVariant.world
          ? _buildWorldNavigationBar(context, l10n)
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavTap,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.public_outlined),
                  selectedIcon: const Icon(Icons.public),
                  label: l10n.dashboard,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.eco_outlined),
                  selectedIcon: const Icon(Icons.eco),
                  label: l10n.habits,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.water_drop_outlined),
                  selectedIcon: const Icon(Icons.water_drop),
                  label: l10n.finance,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.terrain_outlined),
                  selectedIcon: const Icon(Icons.terrain),
                  label: l10n.vision,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.light_mode_outlined),
                  selectedIcon: const Icon(Icons.light_mode),
                  label: l10n.profile,
                ),
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // Listen to XP gains and show a small animated toast
    GamificationRepository.instance.initialize();
    _xpSub = GamificationRepository.instance.xpGains.listen((gain) {
      if (!mounted) return;
      final color = Theme.of(context).colorScheme.primary;
      _showXpCelebration(gain, color);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _xpSub.cancel();
    super.dispose();
  }

  void _showXpCelebration(int gain, Color color) {
    final overlay = Overlay.of(context);
    final media = MediaQuery.of(context);
    final double targetTop = media.padding.top + (kToolbarHeight / 2) - 8;
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: targetTop,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: _XpMinimalToast(amount: gain, color: color),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (entry.mounted) entry.remove();
    });
  }

  void _showFreeformSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.ios_share_outlined),
              title: Text(AppLocalizations.of(context).shareBoard),
              onTap: () async {
                Navigator.pop(ctx);
                await _shareVisionBoard(context);
              },
            ),
            const Divider(height: 1),
            ValueListenableBuilder<bool>(
              valueListenable: _visionRoundCorners,
              builder: (_, val, __) => SwitchListTile(
                title: Text(AppLocalizations.of(context).roundCorners),
                value: val,
                onChanged: (v) => _visionRoundCorners.value = v,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _visionShowText,
              builder: (_, val, __) => SwitchListTile(
                title: Text(AppLocalizations.of(context).showText),
                value: val,
                onChanged: (v) => _visionShowText.value = v,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _visionShowProgress,
              builder: (_, val, __) => SwitchListTile(
                title: Text(AppLocalizations.of(context).showProgress),
                value: val,
                onChanged: (v) => _visionShowProgress.value = v,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  final GlobalKey _visionBoardKey = GlobalKey();

  Future<void> _shareVisionBoard(BuildContext context) async {
    try {
      // Find the boundary in the currently built VisionScreen
      final boundary =
          _visionBoardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      // Render to image
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      // Share directly from memory (no temp file needed)
      final xfile = XFile.fromData(
        bytes,
        name: 'vision_board.png',
        mimeType: 'image/png',
      );
      await SharePlus.instance.share(
        ShareParams(text: AppLocalizations.of(context).myBoard, files: [xfile]),
      );
    } catch (_) {
      // silent
    }
  }

  // Creation actions for text/image stickers are owned by Vision screen's FAB now.

  Widget _buildWorldNavigationBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    // Colors per tab (5 tabs now)
    final tabColors = [
      _getGradientColor(context), // Dashboard
      AppColors.accentGreenDark, // Habit
      AppColors.accentBlue, // Finance
      AppColors.accentClay, // Vision
      AppColors.accentGold, // Profile
    ];

    final selectedColor = tabColors[_currentIndex];
    final labels = [
      l10n.dashboard,
      l10n.habits,
      l10n.finance,
      l10n.vision,
      l10n.profile,
    ];

    return Theme(
      data: theme.copyWith(
        navigationBarTheme: theme.navigationBarTheme.copyWith(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                color: selectedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }
            return TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            );
          }),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        destinations: List.generate(5, (index) {
          final isSelected = _currentIndex == index;
          final color = tabColors[index];
          final iconColor = isSelected
              ? color
              : theme.colorScheme.onSurfaceVariant;

          return NavigationDestination(
            icon: Icon(_getIconFor(index, false), color: iconColor),
            selectedIcon: Icon(_getIconFor(index, true), color: iconColor),
            label: labels[index],
          );
        }),
      ),
    );
  }

  IconData _getIconFor(int index, bool selected) => switch (index) {
    0 => selected ? Icons.public : Icons.public_outlined,
    1 => selected ? Icons.eco : Icons.eco_outlined,
    2 => selected ? Icons.water_drop : Icons.water_drop_outlined,
    3 => selected ? Icons.terrain : Icons.terrain_outlined,
    4 => selected ? Icons.light_mode : Icons.light_mode_outlined,
    _ => Icons.help_outline,
  };

  Color _getGradientColor(BuildContext context) {
    // Panel için mor renk
    return AppColors.accentPurple;
  }
}

class _XpMinimalToast extends StatefulWidget {
  const _XpMinimalToast({required this.amount, required this.color});
  final int amount;
  final Color color;

  @override
  State<_XpMinimalToast> createState() => _XpMinimalToastState();
}

class _XpMinimalToastState extends State<_XpMinimalToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _morph; // 0 → 1 → 0 (dot → pill → dot)
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;
  late final Animation<double> _offsetY; // drop into AppBar then rise back
  // Offset removed for pill open/close effect centered on AppBar

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _morph = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      // slight hold at full pill
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50, // much longer plateau at full pill
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 35,
      ),
    ]).animate(_c);
    _offsetY = TweenSequence<double>([
      // drop from above (-32) to center (0)
      TweenSequenceItem(
        tween: Tween(
          begin: -36.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      // hold in center
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
      // rise back up
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -36.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 30,
      ),
    ]).animate(_c);
    _fadeIn = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.02, 0.14, curve: Curves.easeOut),
    );
    _fadeOut = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.92, 1.0, curve: Curves.easeIn),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Morph dot → pill → dot around AppBar center
        final opacity = _fadeIn.value * (1 - _fadeOut.value + 1e-6);
        final g = _morph.value.clamp(0.0, 1.0);

        // Text style and target width measurement
        // Use black text on light theme for readability, white on dark
        final isLight = Theme.of(context).brightness == Brightness.light;
        final textStyle = TextStyle(
          color: isLight ? Colors.black : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          decoration: TextDecoration.none,
        );
        final text = '+${widget.amount} XP';
        final tp = TextPainter(
          text: const TextSpan(text: ''),
          textDirection: TextDirection.ltr,
        );
        tp.text = TextSpan(text: text, style: textStyle);
        tp.layout();
        final targetWidth = tp.width + 28; // 14px padding each side

        final width = ui.lerpDouble(6.0, targetWidth, g)!;
        final height = ui.lerpDouble(6.0, 28.0, g)!;
        final radius = height / 2;

        double smoothStep(double x, double a, double b) {
          if (x <= a) return 0.0;
          if (x >= b) return 1.0;
          final t = (x - a) / (b - a);
          return t.clamp(0.0, 1.0);
        }

        // Keep text visible while in pill form; fade in as it becomes a pill.
        // We tie it to morph (g) so plateau at g=1 keeps text fully visible.
        final textAppear = smoothStep(g, 0.35, 0.75);
        final textOpacity = (opacity * textAppear).clamp(0.0, 1.0);

        // Background opacity ramps with morph, softer at ends
        final tail = g < 0.15 ? g / 0.15 : (g > 0.85 ? (1 - g) / 0.15 : 1.0);
        final bgOpacity = 0.16 * tail.clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Center(
            child: Transform.translate(
              offset: Offset(0, _offsetY.value),
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(bgOpacity),
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: [
                    if (bgOpacity > 0)
                      BoxShadow(
                        color: widget.color.withOpacity(0.18 * tail),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: textOpacity,
                  child: Text(text, style: textStyle),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
