import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/placeholder_section.dart';

void main() {
  testWidgets('renders the given title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PlaceholderSection(title: 'Título', message: 'Mensagem'),
      ),
    );

    expect(find.text('Título'), findsOneWidget);
    expect(find.text('Mensagem'), findsOneWidget);
  });
}
