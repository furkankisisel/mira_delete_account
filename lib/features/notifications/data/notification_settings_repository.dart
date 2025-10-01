import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsRepository {
  NotificationSettingsRepository._();
  static final NotificationSettingsRepository instance =
      NotificationSettingsRepository._();

  static const _prefEnabled = 'notif_enabled_v1';

  bool _enabled = true;
  bool get enabled => _enabled;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefEnabled) ?? true;
    } catch (_) {
      // ignore storage errors
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnabled, value);
    } catch (_) {
      // ignore storage errors
    }
  }
}
