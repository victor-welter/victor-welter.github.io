import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/section_card.dart';
import 'package:portfolio/core/widgets/tag_chip.dart';
import 'package:portfolio/features/skills/skills_page.dart';

void main() {
  testWidgets('shows every category name and renders a chip per skill', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SkillsPage()));

    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Backend & Dados'), findsOneWidget);
    expect(find.text('IA & Automação'), findsOneWidget);
    expect(find.text('Processos & Qualidade'), findsOneWidget);
    expect(find.text('Arquitetura & Cloud'), findsOneWidget);

    expect(find.widgetWithText(TagChip, 'Flutter'), findsOneWidget);
    expect(find.widgetWithText(TagChip, 'Python'), findsOneWidget);
    expect(find.widgetWithText(TagChip, 'Lean Office'), findsOneWidget);
  });

  testWidgets('wraps each of the 5 categories in a SectionCard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SkillsPage()));

    expect(find.byType(SectionCard), findsNWidgets(5));
  });

  // 1600 is the exact width where the naive card-width division rounds
  // against us: (1552 - 32) / 3 sums back to 1552.0000000000002, a hair over
  // the 1552 the Wrap is given, which is enough to bump the third card onto
  // its own line and degrade the grid to 2+2+1.
  testWidgets('fits 3 cards per row at a 1600px desktop width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: SkillsPage()));
    await tester.pump();

    expect(tester.takeException(), isNull);

    final cards = find.byType(SectionCard);
    expect(cards, findsNWidgets(5));

    final rects = [for (var i = 0; i < 5; i++) tester.getRect(cards.at(i))];
    // First three share a row; the fourth starts the next one.
    expect(rects[1].top, rects[0].top);
    expect(rects[2].top, rects[0].top);
    expect(rects[3].top, greaterThan(rects[0].top));
  });
}
