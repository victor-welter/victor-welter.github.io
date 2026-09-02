import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/section_card.dart';

void main() {
  testWidgets('renders its child inside a bordered container', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SectionCard(child: Text('conteúdo'))),
      ),
    );

    expect(find.text('conteúdo'), findsOneWidget);
    expect(find.byType(SectionCard), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(SectionCard),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.border, isNotNull);
    expect(decoration.borderRadius, BorderRadius.circular(12));
  });
}
