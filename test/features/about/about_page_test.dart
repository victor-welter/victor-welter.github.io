import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/about/about_page.dart';

void main() {
  testWidgets('shows the heading and full first-person bio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    expect(find.text('Sobre'), findsOneWidget);
    expect(find.textContaining('Víctor Vinícius Welter'), findsOneWidget);
    expect(
      find.textContaining('Inteligência Artificial e Visão Computacional'),
      findsOneWidget,
    );
    expect(
      find.text('Três de Maio, Rio Grande do Sul, Brasil'),
      findsOneWidget,
    );
  });
}
