import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/core/theme/theme_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tapping the theme toggle switches and persists the mode', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController(preferences);
    await tester.pumpWidget(PortfolioApp(themeController: controller));
    await tester.pumpAndSettle();

    expect(controller.mode, ThemeMode.system);

    await tester.tap(find.byTooltip('Alternar tema'));
    await tester.pumpAndSettle();

    expect(controller.mode, ThemeMode.dark);
    expect(preferences.getString('theme_mode'), 'dark');
  });

  testWidgets(
    'first tap on a dark-OS device with system mode switches to light '
    '(the opposite of what is already showing)',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(
        tester.platformDispatcher.clearPlatformBrightnessTestValue,
      );

      final preferences = await SharedPreferences.getInstance();
      final controller = ThemeController(preferences);
      await tester.pumpWidget(PortfolioApp(themeController: controller));
      await tester.pumpAndSettle();

      expect(controller.mode, ThemeMode.system);

      await tester.tap(find.byTooltip('Alternar tema'));
      await tester.pumpAndSettle();

      expect(controller.mode, ThemeMode.light);
      expect(preferences.getString('theme_mode'), 'light');
    },
  );
}
