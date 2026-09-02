import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/section_card.dart';
import 'package:portfolio/core/widgets/tag_chip.dart';
import 'package:portfolio/features/projects/projects_page.dart';

void main() {
  testWidgets(
    'shows every featured project card and every secondary project row',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectsPage()));

      expect(find.text('Bee Visit Tracking & Counting'), findsOneWidget);
      expect(find.text('AutoConnect'), findsOneWidget);
      expect(find.text('Monitoramento de Energia'), findsOneWidget);
      expect(find.text('validator-assincrono'), findsOneWidget);

      expect(find.widgetWithText(TagChip, 'YOLO'), findsOneWidget);

      expect(find.text('Outros projetos'), findsOneWidget);
      expect(find.textContaining('youtube_downloader'), findsOneWidget);

      expect(find.text('calculadora'), findsNothing);
    },
  );

  testWidgets(
    'renders exactly 8 project link buttons total (Bee Visit contributes '
    'none, since its repo is private)',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectsPage()));

      expect(find.byType(TextButton), findsNWidgets(8));
    },
  );

  testWidgets(
    'wraps every project (4 featured + 3 secondary) in a SectionCard',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectsPage()));

      expect(find.byType(SectionCard), findsNWidgets(7));
    },
  );
}
