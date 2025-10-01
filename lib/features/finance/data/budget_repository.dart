import 'package:shared_preferences/shared_preferences.dart';

class BudgetRepository {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  void dispose() {
    // no-op for SharedPreferences
  }

  String _keyForMonth(DateTime month) =>
      'budget_${month.year}_${month.month.toString().padLeft(2, '0')}';

  double? getBudgetForMonth(DateTime month) {
    final p = _prefs;
    if (p == null) return null;
    final key = _keyForMonth(month);
    return p.getDouble(key);
  }

  Future<void> setBudgetForMonth(DateTime month, double amount) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setDouble(_keyForMonth(month), amount);
  }
}
