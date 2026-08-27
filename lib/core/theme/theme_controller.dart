import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferences) : _mode = _readMode(_preferences);

  static const String _prefsKey = 'theme_mode';

  final SharedPreferences _preferences;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static ThemeMode _readMode(SharedPreferences preferences) {
    final stored = preferences.getString(_prefsKey);
    return ThemeMode.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _preferences.setString(_prefsKey, mode.name);
  }

  Future<void> toggle() {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setMode(next);
  }
}
