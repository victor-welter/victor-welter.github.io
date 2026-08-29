import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/contact/contact_page.dart';

void main() {
  testWidgets('shows email, LinkedIn, GitHub, and location', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ContactPage()));

    expect(find.text('victorwelter2003@gmail.com'), findsOneWidget);
    expect(find.text('linkedin.com/in/victor-welter'), findsOneWidget);
    expect(find.text('github.com/victor-welter'), findsOneWidget);
    expect(
      find.text('Três de Maio, Rio Grande do Sul, Brasil'),
      findsOneWidget,
    );
  });
}
