import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/not_found/not_found_page.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget page) {
    return tester.pumpWidget(MaterialApp(home: page));
  }

  testWidgets('NotFoundPage shows a not-found message', (tester) async {
    await pump(tester, const NotFoundPage());
    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
