import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/core/theme/theme_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system mode when nothing is stored', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    expect(controller.mode, ThemeMode.system);
  });

  test('setMode persists the choice and notifies listeners', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    var notified = false;
    controller.addListener(() => notified = true);

    await controller.setMode(ThemeMode.dark);

    expect(controller.mode, ThemeMode.dark);
    expect(notified, isTrue);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('a fresh controller reads back a previously persisted mode', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    expect(controller.mode, ThemeMode.dark);
  });

  test('toggle flips between light and dark', () async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    await controller.setMode(ThemeMode.light);

    await controller.toggle();
    expect(controller.mode, ThemeMode.dark);

    await controller.toggle();
    expect(controller.mode, ThemeMode.light);
  });
}
