import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/tag_chip.dart';

void main() {
  testWidgets('renders its label text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TagChip('Flutter')));

    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('uses a full-pill shape', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TagChip('Flutter')));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    final borderRadius = decoration.borderRadius as BorderRadius;

    expect(borderRadius, BorderRadius.circular(999));
  });
}
