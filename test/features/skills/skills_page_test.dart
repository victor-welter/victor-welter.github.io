import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
