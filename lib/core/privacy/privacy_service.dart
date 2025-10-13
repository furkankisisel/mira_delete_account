import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores user privacy preferences (consent toggles) locally.
class PrivacyService extends ChangeNotifier {
  PrivacyService._();
  static final PrivacyService instance = PrivacyService._();

  static const _kDiagnostics = 'pref_privacy_diagnostics_v1';
  static const _kCrashReports = 'pref_privacy_crash_reports_v1';

  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _diagnostics = false; // default opt-out
  bool _crashReports = false; // default opt-out

  bool get isInitialized => _initialized;
  bool get diagnosticsAllowed => _diagnostics;
  bool get crashReportsAllowed => _crashReports;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _diagnostics = _prefs?.getBool(_kDiagnostics) ?? false;
    _crashReports = _prefs?.getBool(_kCrashReports) ?? false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setDiagnosticsAllowed(bool value) async {
    _diagnostics = value;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool(_kDiagnostics, value);
    notifyListeners();
  }

  Future<void> setCrashReportsAllowed(bool value) async {
    _crashReports = value;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool(_kCrashReports, value);
    notifyListeners();
  }
}
