import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/section_card.dart';
import 'package:portfolio/features/experience/experience_page.dart';

void main() {
  testWidgets(
    'shows all 3 primary roles with bullets and 3 previous roles condensed',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExperiencePage()));

      expect(
        find.text('Assistente de Processos e Qualidade'),
        findsOneWidget,
      );
      expect(find.text('Desenvolvedor Mobile'), findsOneWidget);
      expect(
        find.text('Estagiário em Desenvolvimento Mobile'),
        findsOneWidget,
      );
      expect(find.textContaining('mais de 20 aplicativos'), findsOneWidget);

      expect(find.text('Experiência anterior'), findsOneWidget);
      expect(
        find.textContaining('Vendedor de Comércio Varejista'),
        findsOneWidget,
      );
      expect(find.textContaining('Grupo Lactalis'), findsOneWidget);
    },
  );

  testWidgets('wraps each of the 3 primary roles in a SectionCard', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExperiencePage()));

    expect(find.byType(SectionCard), findsNWidgets(3));
  });
}
