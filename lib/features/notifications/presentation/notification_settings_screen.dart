import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_settings/app_settings.dart' as sys;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../data/notification_settings_repository.dart';
import '../../../design_system/theme/theme_variations.dart';
import '../../../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key, this.variant});

  final ThemeVariant? variant;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _permissionGranted = false;
  bool _initializing = true;
  String? _timezoneId;
  String? _timezoneLocalized;

  final _repo = NotificationSettingsRepository.instance;
  late bool _masterEnabled;
  late bool _habitReminders;
  late bool _sound;
  late bool _vibration;

  final _plugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _load();
  }

  void _loadSettings() {
    _masterEnabled = _repo.enabled;
    _habitReminders = _repo.habitReminders;
    _sound = _repo.sound;
    _vibration = _repo.vibration;
  }

  Future<void> _load() async {
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final id = tzInfo.identifier;
      final localized = tzInfo.localizedName;
      setState(() {
        _timezoneId = id;
        _timezoneLocalized = localized != null
            ? '${localized.name} (${localized.locale})'
            : null;
      });
    } catch (_) {
      setState(() => _timezoneId = 'unknown');
    }

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted =
        await androidImpl?.requestNotificationsPermission() ?? false;

    setState(() {
      _permissionGranted = granted;
      _initializing = false;
    });
  }

  Future<void> _toggleMaster(bool value) async {
    await _repo.setEnabled(value);
    setState(() => _masterEnabled = value);
  }

  Future<void> _toggleHabitReminders(bool value) async {
    await _repo.setHabitReminders(value);
    setState(() => _habitReminders = value);
  }

  Future<void> _toggleSound(bool value) async {
    await _repo.setSound(value);
    setState(() => _sound = value);
  }

  Future<void> _toggleVibration(bool value) async {
    await _repo.setVibration(value);
    setState(() => _vibration = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final content = Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Master Switch
                Card(
                  child: SwitchListTile(
                    secondary: Icon(
                      _masterEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: _masterEnabled ? theme.colorScheme.primary : null,
                    ),
                    title: Text(
                      l10n.enableNotifications,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(l10n.notificationsMasterSubtitle),
                    value: _masterEnabled,
                    onChanged: _toggleMaster,
                  ),
                ),

                const SizedBox(height: 24),

                // Notification Types
                Text(
                  l10n.notificationTypes,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.alarm),
                        title: Text(l10n.habitReminders),
                        subtitle: Text(l10n.habitRemindersSubtitle),
                        value: _habitReminders && _masterEnabled,
                        onChanged: _masterEnabled
                            ? _toggleHabitReminders
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Notification Behavior
                Text(
                  l10n.notificationBehavior,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(
                          _sound ? Icons.volume_up : Icons.volume_off,
                        ),
                        title: Text(l10n.sound),
                        subtitle: Text(l10n.soundSubtitle),
                        value: _sound && _masterEnabled,
                        onChanged: _masterEnabled ? _toggleSound : null,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: Icon(
                          _vibration ? Icons.vibration : Icons.phone_android,
                        ),
                        title: Text(l10n.vibration),
                        subtitle: Text(l10n.vibrationSubtitle),
                        value: _vibration && _masterEnabled,
                        onChanged: _masterEnabled ? _toggleVibration : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // System Info
                Text(
                  l10n.systemInfo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.public),
                        title: Text(l10n.timezone),
                        subtitle: Text(
                          _timezoneLocalized ?? _timezoneId ?? '—',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          _permissionGranted
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: _permissionGranted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        title: Text(l10n.notificationPermission),
                        subtitle: Text(
                          _permissionGranted ? l10n.granted : l10n.notGranted,
                        ),
                        trailing: TextButton.icon(
                          onPressed: () {
                            // Open OS notification settings page for this app
                            sys.AppSettings.openAppSettings(
                              type: sys.AppSettingsType.notification,
                            );
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Important Notice
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.importantNotice,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.notificationTroubleshooting,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => sys.AppSettings.openAppSettings(
                                type: sys.AppSettingsType.notification,
                              ),
                              icon: const Icon(Icons.notifications_active),
                              label: const Text('Open notification settings'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  sys.AppSettings.openAppSettings(),
                              icon: const Icon(Icons.settings),
                              label: const Text('Open system settings'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => sys.AppSettings.openAppSettings(
                                type: sys.AppSettingsType.batteryOptimization,
                              ),
                              icon: const Icon(Icons.battery_saver),
                              label: const Text('Open battery optimization'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );

    // If world variant is requested, mirror ProfileScreen's behavior and
    // apply the golden/world variation theme for a consistent look.
    if (widget.variant == ThemeVariant.world) {
      final brightness = Theme.of(context).brightness;
      final themed = brightness == Brightness.dark
          ? ThemeVariations.dark(ThemeVariant.golden)
          : ThemeVariations.light(ThemeVariant.golden);
      return Theme(data: themed, child: content);
    }

    return content;
  }
}
