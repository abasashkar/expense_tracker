import 'package:expense_tracker/core/constants/prefs_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession({
    required String token,
    required String nickname,
  });

  Future<({String? token, String? nickname})> getSession();

  Future<bool> isOnboardingComplete();

  Future<void> setOnboardingComplete();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> saveSession({
    required String token,
    required String nickname,
  }) async {
    final results = await Future.wait([
      _prefs.setString(PrefsConstants.authToken, token),
      _prefs.setString(PrefsConstants.nickname, nickname),
    ]);
    if (results.contains(false)) {
      throw CacheException('Failed to save session');
    }
  }

  @override
  Future<({String? token, String? nickname})> getSession() async {
    return (
      token: _prefs.getString(PrefsConstants.authToken),
      nickname: _prefs.getString(PrefsConstants.nickname),
    );
  }

  @override
  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(PrefsConstants.onboardingComplete) ?? false;
  }

  @override
  Future<void> setOnboardingComplete() async {
    final saved = await _prefs.setBool(PrefsConstants.onboardingComplete, true);
    if (!saved) {
      throw CacheException('Failed to save onboarding state');
    }
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(PrefsConstants.authToken),
      _prefs.remove(PrefsConstants.nickname),
    ]);
  }
}
