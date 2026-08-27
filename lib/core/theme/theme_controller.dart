import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferences) : _mode = _readMode(_preferences);

  static const String _prefsKey = 'theme_mode';

  /// May be `null` when persistence is unavailable (e.g. the browser blocks
  /// `localStorage`, so `SharedPreferences.getInstance()` never succeeded).
  /// The controller still works in that case; it just can't remember the
  /// chosen mode across reloads.
  final SharedPreferences? _preferences;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  static ThemeMode _readMode(SharedPreferences? preferences) {
    final stored = preferences?.getString(_prefsKey);
    return ThemeMode.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final preferences = _preferences;
    if (preferences == null) return;
    try {
      await preferences.setString(_prefsKey, mode.name);
    } catch (_) {
      // Persistence is best-effort: a blocked/unavailable storage backend
      // must not surface as an unhandled error from a discarded Future.
    }
  }

  Future<void> toggle() {
    final next = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    return setMode(next);
  }
}
