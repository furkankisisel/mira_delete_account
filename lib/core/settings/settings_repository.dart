import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide settings persisted via SharedPreferences.
class SettingsRepository extends ChangeNotifier {
  SettingsRepository._();
  static final SettingsRepository instance = SettingsRepository._();

  static const _kShowStreakIndicators = 'pref_show_streak_indicators_v1';

  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _showStreakIndicators = true;

  bool get isInitialized => _initialized;
  bool get showStreakIndicators => _showStreakIndicators;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _showStreakIndicators = _prefs?.getBool(_kShowStreakIndicators) ?? true;
    _initialized = true;
  }

  Future<void> setShowStreakIndicators(bool value) async {
    _showStreakIndicators = value;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool(_kShowStreakIndicators, value);
    notifyListeners();
  }
}
