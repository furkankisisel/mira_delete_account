import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsRepository {
  NotificationSettingsRepository._();
  static final NotificationSettingsRepository instance =
      NotificationSettingsRepository._();

  static const _prefEnabled = 'notif_enabled_v1';
  static const _prefHabitReminders = 'notif_habit_reminders_v1';
  static const _prefSound = 'notif_sound_v1';
  static const _prefVibration = 'notif_vibration_v1';

  bool _enabled = true;
  bool _habitReminders = true;
  bool _sound = true;
  bool _vibration = true;

  // Callback for when settings change
  void Function()? _onSettingsChanged;

  bool get enabled => _enabled;
  bool get habitReminders => _habitReminders;
  bool get sound => _sound;
  bool get vibration => _vibration;

  void setOnSettingsChangedCallback(void Function()? callback) {
    _onSettingsChanged = callback;
  }

  void _notifyChanged() {
    _onSettingsChanged?.call();
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefEnabled) ?? true;
      _habitReminders = prefs.getBool(_prefHabitReminders) ?? true;
      _sound = prefs.getBool(_prefSound) ?? true;
      _vibration = prefs.getBool(_prefVibration) ?? true;
    } catch (_) {
      // ignore storage errors
    }
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await _save(_prefEnabled, value);
    _notifyChanged();
  }

  Future<void> setHabitReminders(bool value) async {
    _habitReminders = value;
    await _save(_prefHabitReminders, value);
    _notifyChanged();
  }

  Future<void> setSound(bool value) async {
    _sound = value;
    await _save(_prefSound, value);
    _notifyChanged();
  }

  Future<void> setVibration(bool value) async {
    _vibration = value;
    await _save(_prefVibration, value);
    _notifyChanged();
  }

  Future<void> _save(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // ignore storage errors
    }
  }
}
