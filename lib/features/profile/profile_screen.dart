import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../design_system/theme/theme_variations.dart';
import '../../design_system/components/theme_selector.dart';
import '../../design_system/components/language_selector.dart';
import '../../core/language_manager.dart';
import '../gamification/gamification_repository.dart';
import '../notifications/presentation/notification_settings_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'profile_repository.dart';
import '../../core/settings/settings_repository.dart';
import 'auth_repository.dart';
import 'backup_repository.dart';
import 'dart:convert';
import '../onboarding/data/onboarding_repository.dart';
import '../onboarding/presentation/onboarding_screen.dart';
import 'privacy_security_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.onToggleTheme,
    this.themeMode,
    this.currentVariant,
    this.onVariantChanged,
    this.languageManager,
  });
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final ThemeVariant? currentVariant;
  final ValueChanged<ThemeVariant>? onVariantChanged;
  final LanguageManager? languageManager;
  @override
  Widget build(BuildContext context) {
    final isWorld = currentVariant == ThemeVariant.world;
    final content = DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 4),
          _ProfileTabBar(),
          const SizedBox(height: 12),
          Expanded(
            child: _ProfileTabViews(
              onToggleTheme: onToggleTheme,
              themeMode: themeMode,
              currentVariant: currentVariant,
              onVariantChanged: onVariantChanged,
              languageManager: languageManager,
            ),
          ),
        ],
      ),
    );

    if (isWorld) {
      final brightness = Theme.of(context).brightness;
      final themed = brightness == Brightness.dark
          ? ThemeVariations.dark(ThemeVariant.golden)
          : ThemeVariations.light(ThemeVariant.golden);
      return Theme(data: themed, child: content);
    }
    return content;
  }
}

class _ProfileTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(2),
        child: TabBar(
          isScrollable: false,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(2),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.06),
          ),
          labelColor: scheme.onPrimaryContainer,
          unselectedLabelColor: scheme.onSurfaceVariant,
          indicator: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          tabs: [
            Tab(text: l10n.settings),
            Tab(text: l10n.achievements),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabViews extends StatelessWidget {
  const _ProfileTabViews({
    required this.onToggleTheme,
    required this.themeMode,
    required this.currentVariant,
    required this.onVariantChanged,
    required this.languageManager,
  });

  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final ThemeVariant? currentVariant;
  final ValueChanged<ThemeVariant>? onVariantChanged;
  final LanguageManager? languageManager;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        _SettingsTab(
          onToggleTheme: onToggleTheme,
          themeMode: themeMode,
          currentVariant: currentVariant,
          onVariantChanged: onVariantChanged,
          languageManager: languageManager,
        ),
        const _AchievementsTab(),
      ],
    );
  }
}

class _AchievementsTab extends StatefulWidget {
  const _AchievementsTab();
  @override
  State<_AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<_AchievementsTab> {
  @override
  void initState() {
    super.initState();
    // Initialize gamification state
    GamificationRepository.instance.initialize();
    GamificationRepository.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    GamificationRepository.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final repo = GamificationRepository.instance;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final badges = repo.allBadges(l10n);
    final unlocked = repo.unlockedBadges;
    // Group badges by category
    final Map<String, List<BadgeDef>> groups = {};
    for (final b in badges) {
      groups.putIfAbsent(b.category, () => []).add(b);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: _XpHeader(
              level: repo.level,
              xpIntoLevel: repo.xpIntoLevel,
              xpPerLevel: repo.xpPerLevel,
              xpToNext: repo.xpToNextLevel,
              scheme: scheme,
            ),
          ),
        ),
        for (final entry in groups.entries) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                entry.key,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .82,
              ),
              delegate: SliverChildBuilderDelegate((context, i) {
                final b = entry.value[i];
                final isUnlocked = unlocked.contains(b.id);
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showBadgeDetails(context, b, isUnlocked),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isUnlocked ? 1 : 0.45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? scheme.primaryContainer
                            : scheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUnlocked
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            b.icon,
                            size: 32,
                            color: isUnlocked
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          if (!isUnlocked)
                            Text(
                              l10n.notUnlocked,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: entry.value.length),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  void _showBadgeDetails(BuildContext context, BadgeDef badge, bool unlocked) {
    final repo = GamificationRepository.instance;
    // Compute current value by metric
    int current;
    switch (badge.metric) {
      case BadgeMetric.totalHabitCompletions:
        current = repo.totalHabitCompletions;
        break;
      case BadgeMetric.activeDays:
        current = repo.activeDays;
        break;
      case BadgeMetric.totalTransactions:
        current = repo.totalTransactions;
        break;
      case BadgeMetric.totalVisions:
        current = repo.totalVisions;
        break;
      case BadgeMetric.level:
        current = repo.level;
        break;
      case BadgeMetric.xp:
        current = repo.xp;
        break;
    }
    final pct = (current / badge.goal).clamp(0.0, 1.0);
    showDialog(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                badge.icon,
                color: unlocked ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(badge.title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.description),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: pct, minHeight: 10),
              ),
              const SizedBox(height: 8),
              Text('$current / ${badge.goal}'),
              const SizedBox(height: 8),
              if (!unlocked)
                Text(
                  '${l10n.howToEarn}: ${badge.description}',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }
}

class _XpHeader extends StatelessWidget {
  const _XpHeader({
    required this.level,
    required this.xpIntoLevel,
    required this.xpPerLevel,
    required this.xpToNext,
    required this.scheme,
  });
  final int level;
  final int xpIntoLevel;
  final int xpPerLevel;
  final int xpToNext;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pct = xpIntoLevel / xpPerLevel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.primary,
                  child: Text(
                    l10n.levelShort(level),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.levelLabel(level),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.xpProgressSummary(
                          xpIntoLevel.toString(),
                          xpPerLevel.toString(),
                          xpToNext.toString(),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
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
  }
}

class _SettingsTab extends StatefulWidget {
  const _SettingsTab({
    required this.onToggleTheme,
    required this.themeMode,
    required this.currentVariant,
    required this.onVariantChanged,
    required this.languageManager,
  });

  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  final ThemeVariant? currentVariant;
  final ValueChanged<ThemeVariant>? onVariantChanged;
  final LanguageManager? languageManager;

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  final _nameCtrl = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    ProfileRepository.instance.initialize();
    ProfileRepository.instance.addListener(_onProfileChange);
    AuthRepository.instance.initialize();
    AuthRepository.instance.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    ProfileRepository.instance.removeListener(_onProfileChange);
    AuthRepository.instance.removeListener(_onAuthChange);
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onAuthChange() {
    if (mounted) setState(() {});
  }

  void _onProfileChange() {
    final repo = ProfileRepository.instance;
    if (_nameCtrl.text != repo.name) _nameCtrl.text = repo.name;
    if (mounted) setState(() {});
  }

  LanguageManager get _languageManager =>
      widget.languageManager ?? LanguageManager();

  String _getThemeText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (widget.themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
      default:
        return l10n.systemTheme;
    }
  }

  void _showThemeVariantSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: ThemeSelector(
            currentVariant: widget.currentVariant ?? ThemeVariant.forest,
            onVariantChanged: (variant) {
              widget.onVariantChanged?.call(variant);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showLanguageSelector(
      context: context,
      currentLanguage: _languageManager.currentLanguage,
      onLanguageChanged: (language) async {
        await _languageManager.changeLanguage(language);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (result != null) {
        await ProfileRepository.instance.setAvatarPath(result.path);
      }
    } catch (_) {
      // ignore errors silently for now
    }
  }

  void _showEditProfileSheet() {
    final profile = ProfileRepository.instance;
    // prime controllers with latest values
    _nameCtrl.text = profile.name;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final insets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + insets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Theme.of(
                          ctx,
                        ).colorScheme.surfaceContainerHighest,
                        backgroundImage:
                            (profile.avatarPath != null &&
                                profile.avatarPath!.isNotEmpty)
                            ? FileImage(io.File(profile.avatarPath!))
                            : (profile.avatarUrl != null &&
                                  profile.avatarUrl!.isNotEmpty)
                            ? NetworkImage(profile.avatarUrl!) as ImageProvider
                            : null,
                        child:
                            (profile.avatarPath == null ||
                                    profile.avatarPath!.isEmpty) &&
                                (profile.avatarUrl == null ||
                                    profile.avatarUrl!.isEmpty)
                            ? const Text('ğŸ‘¤', style: TextStyle(fontSize: 28))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            Navigator.of(ctx).pop();
                            await _pickAvatar();
                            _showEditProfileSheet();
                          },
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Theme.of(ctx).colorScheme.primary,
                            foregroundColor: Theme.of(
                              ctx,
                            ).colorScheme.onPrimary,
                            child: const Icon(Icons.edit, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.fullName,
                            hintText: l10n.enterYourName,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 8),
                        // Bio field removed per design change
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () async {
                    // Capture navigator and messenger before awaits to avoid
                    // using BuildContext across async gaps.
                    final navigator = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(context);
                    await profile.setName(_nameCtrl.text.trim());
                    if (navigator.mounted) navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.profileUpdated)),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: Text(l10n.save),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ProfileRepository.instance;
    // initialize controllers with current values (idempotent)
    if (_nameCtrl.text.isEmpty && profile.name.isNotEmpty) {
      _nameCtrl.text = profile.name;
    }
    // bio field removed; no initialization needed
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      children: [
        // Compact profile header with edit pencil
        Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              backgroundImage:
                  (profile.avatarPath != null && profile.avatarPath!.isNotEmpty)
                  ? FileImage(io.File(profile.avatarPath!))
                  : (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                  ? NetworkImage(profile.avatarUrl!) as ImageProvider
                  : null,
              child:
                  (profile.avatarPath == null || profile.avatarPath!.isEmpty) &&
                      (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                  ? const Text('ğŸ‘¤', style: TextStyle(fontSize: 22))
                  : null,
            ),
            title: Text(
              (profile.name.isNotEmpty) ? profile.name : l10n.profile,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: _showEditProfileSheet,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.appearance,
          children: [
            AnimatedBuilder(
              animation: SettingsRepository.instance,
              builder: (context, _) => SwitchListTile(
                secondary: const Icon(Icons.local_fire_department_outlined),
                title: Text(l10n.streakIndicator),
                subtitle: Text(l10n.streakIndicatorDesc),
                value: SettingsRepository.instance.showStreakIndicators,
                onChanged: (v) =>
                    SettingsRepository.instance.setShowStreakIndicators(v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(
                '${_languageManager.currentLanguage.flag} ${_languageManager.currentLanguage.displayName}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageSelector(context),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text(l10n.theme),
              subtitle: Text(_getThemeText(context)),
              trailing: Switch(
                value: widget.themeMode == ThemeMode.dark,
                onChanged: widget.onToggleTheme != null
                    ? (_) => widget.onToggleTheme!()
                    : null,
              ),
              onTap: widget.onToggleTheme,
            ),
            if (widget.currentVariant != null &&
                widget.onVariantChanged != null)
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l10n.colorTheme),
                subtitle: Text(widget.currentVariant?.displayName ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeVariantSheet(context),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.notifications,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(l10n.notificationSettings),
              subtitle: Text(l10n.notificationSettingsSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NotificationSettingsScreen(
                      variant: widget.currentVariant,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.privacySecurity,
          children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacySecurity),
              subtitle: const Text(
                'Ayarları ve veri silme seçeneklerini yönetin',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacySecurityScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.account,
          children: [
            // Google sign-in area
            Builder(
              builder: (ctx) {
                final auth = AuthRepository.instance;
                if (!auth.isSignedIn) {
                  return ListTile(
                    leading: const Icon(Icons.login, size: 28),
                    title: const Text('Sign in with Google'),
                    onTap: () async {
                      await auth.signIn();
                    },
                  );
                }
                final acc = auth.account!;
                return ListTile(
                  leading: (acc.photoUrl != null)
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(acc.photoUrl!),
                        )
                      : const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(acc.displayName ?? acc.email),
                  subtitle: Text(acc.email),
                  trailing: TextButton(
                    onPressed: () async =>
                        await AuthRepository.instance.signOut(),
                    child: Text(l10n.logout),
                  ),
                );
              },
            ),
            // Backup / Restore actions (visible when signed in)
            Builder(
              builder: (ctx) {
                final auth = AuthRepository.instance;
                if (!auth.isSignedIn) return const SizedBox.shrink();
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: const Text('Backup now'),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(ctx);
                        final navigator = Navigator.of(
                          ctx,
                          rootNavigator: true,
                        );
                        showDialog<void>(
                          context: ctx,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          // For simplicity, backup the entire shared preferences / profile state
                          final profile = ProfileRepository.instance;
                          final payload = {
                            'name': profile.name,
                            'bio': profile.bio,
                            'avatarPath': profile.avatarPath,
                            'timestamp': DateTime.now().toIso8601String(),
                          };
                          final ok = await BackupRepository.instance
                              .uploadBackup(jsonEncode(payload));
                          if (ok) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Backup succeeded')),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Backup failed')),
                            );
                          }
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Backup failed: $e')),
                          );
                        } finally {
                          // close loader
                          navigator.pop();
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Restore latest'),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(ctx);
                        final navigator = Navigator.of(
                          ctx,
                          rootNavigator: true,
                        );
                        showDialog<void>(
                          context: ctx,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          final data = await BackupRepository.instance
                              .downloadBackup();
                          if (data == null) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('No backup found')),
                            );
                          } else {
                            final obj =
                                jsonDecode(data) as Map<String, dynamic>;
                            // Restore profile fields
                            await ProfileRepository.instance.setName(
                              obj['name'] ?? '',
                            );
                            // bio restore intentionally omitted (UI no longer supports editing bio)
                            await ProfileRepository.instance.setAvatarPath(
                              obj['avatarPath'],
                            );
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Restore succeeded'),
                              ),
                            );
                          }
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Restore failed: $e')),
                          );
                        } finally {
                          navigator.pop();
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.profileInfo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.privacySecurity),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SettingsSection(
          title: l10n.other,
          children: [
            ListTile(
              leading: const Icon(Icons.psychology_outlined),
              title: const Text('Reset Onboarding'),
              subtitle: const Text('Retake personality test'),
              onTap: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Onboarding?'),
                    content: const Text(
                      'This will clear your current personality results and let you retake the quiz.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  // Clear onboarding data
                  await OnboardingRepository().clearOnboardingData();

                  // Navigate to onboarding screen
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.about),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(title, style: theme.textTheme.labelLarge),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
