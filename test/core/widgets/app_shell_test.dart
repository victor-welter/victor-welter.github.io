import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio/core/theme/theme_controller.dart';
import 'package:portfolio/core/theme/theme_scope.dart';
import 'package:portfolio/core/widgets/app_shell.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: ThemeScope(
          controller: ThemeController(preferences),
          child: const AppShell(currentPath: '/', child: SizedBox.shrink()),
        ),
      ),
    );
  }

  testWidgets('shows a hamburger drawer on mobile widths', (tester) async {
    await pumpShell(tester, const Size(400, 800));

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Sobre'), findsNothing);
  });

  testWidgets('shows a horizontal nav bar on desktop widths', (tester) async {
    await pumpShell(tester, const Size(1300, 800));

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.widgetWithText(TextButton, 'Sobre'), findsOneWidget);
  });

  testWidgets('shows a theme toggle button on both layouts', (tester) async {
    await pumpShell(tester, const Size(400, 800));
    expect(find.byTooltip('Alternar tema'), findsOneWidget);

    await pumpShell(tester, const Size(1300, 800));
    expect(find.byTooltip('Alternar tema'), findsOneWidget);
  });
}
