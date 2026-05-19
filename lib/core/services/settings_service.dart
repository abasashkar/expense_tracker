import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/prefs_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  double get monthlyLimit =>
      _prefs.getDouble(PrefsConstants.monthlyLimit) ??
      AppConstants.monthlyExpenseLimit;

  Future<void> setMonthlyLimit(double limit) async {
    await _prefs.setDouble(PrefsConstants.monthlyLimit, limit);
  }

  Future<void> updateNickname(String nickname) async {
    await _prefs.setString(PrefsConstants.nickname, nickname);
  }
}
