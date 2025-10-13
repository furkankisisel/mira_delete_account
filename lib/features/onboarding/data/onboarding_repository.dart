import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/onboarding_result.dart';

/// Repository for managing onboarding state and results
class OnboardingRepository {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _onboardingResultKey = 'onboarding_result';

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  /// Save onboarding result
  Future<void> saveOnboardingResult(OnboardingResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(result.toJson());
    await prefs.setString(_onboardingResultKey, jsonString);
    await setOnboardingCompleted(true);
  }

  /// Get saved onboarding result
  Future<OnboardingResult?> getOnboardingResult() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_onboardingResultKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return OnboardingResult.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Clear onboarding data (useful for testing/re-taking quiz)
  Future<void> clearOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_onboardingResultKey);
  }
}
