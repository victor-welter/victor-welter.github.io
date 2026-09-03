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

  testWidgets(
    'desktop nav uses accent for the active label and muted text for '
    'inactive labels',
    (tester) async {
      await pumpShell(tester, const Size(1300, 800));

      final colorScheme = Theme.of(
        tester.element(find.byType(AppShell)),
      ).colorScheme;

      final activeButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Home'),
      );
      final inactiveButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Sobre'),
      );

      expect(
        activeButton.style?.foregroundColor?.resolve(<WidgetState>{}),
        colorScheme.primary,
      );
      expect(
        inactiveButton.style?.foregroundColor?.resolve(<WidgetState>{}),
        colorScheme.onSurfaceVariant,
      );
    },
  );

  testWidgets(
    'desktop nav shows a colored indicator under the active item only',
    (tester) async {
      await pumpShell(tester, const Size(1300, 800));

      final colorScheme = Theme.of(
        tester.element(find.byType(AppShell)),
      ).colorScheme;

      final indicators = tester.widgetList<AnimatedContainer>(
        find.byKey(const Key('nav-active-indicator')),
      );
      // AnimatedContainer has no public `color` field: its constructor folds
      // `color` into `decoration` (`BoxDecoration(color: color)`), exposing
      // only `decoration` — unlike `Container`, which keeps `color` as its
      // own field. Read the color back out of the resolved decoration.
      Color? indicatorColor(AnimatedContainer c) =>
          (c.decoration as BoxDecoration?)?.color;
      final activeCount = indicators
          .where((c) => indicatorColor(c) == colorScheme.primary)
          .length;
      final transparentCount = indicators
          .where((c) => indicatorColor(c) == Colors.transparent)
          .length;

      expect(activeCount, 1);
      expect(transparentCount, navDestinations.length - 1);
    },
  );

  group('tablet widths (600-1024px) show Home + a "Mais" overflow menu', () {
    for (final width in <double>[650, 800, 950]) {
      testWidgets('at ${width.toInt()}px', (tester) async {
        await pumpShell(tester, Size(width, 800));

        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.menu), findsNothing);
        expect(find.widgetWithText(TextButton, 'Home'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Sobre'), findsNothing);
        expect(find.text('Mais'), findsOneWidget);

        final colorScheme = Theme.of(
          tester.element(find.byType(AppShell)),
        ).colorScheme;
        final homeButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Home'),
        );
        expect(
          homeButton.style?.foregroundColor?.resolve(<WidgetState>{}),
          colorScheme.primary,
        );

        await tester.tap(find.text('Mais'));
        await tester.pumpAndSettle();

        final sobreItem = tester.widget<Text>(find.text('Sobre'));
        expect(sobreItem.style?.color, colorScheme.onSurfaceVariant);
      });
    }
  });

  testWidgets('shows a theme toggle button on both layouts', (tester) async {
    await pumpShell(tester, const Size(400, 800));
    expect(find.byTooltip('Alternar tema'), findsOneWidget);

    await pumpShell(tester, const Size(1300, 800));
    expect(find.byTooltip('Alternar tema'), findsOneWidget);
  });
}
