import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/main.dart';

void main() {
  testWidgets('boots and shows the placeholder home text', (tester) async {
    await tester.pumpWidget(const PortfolioApp());

    expect(find.text('Victor Welter — Portfólio'), findsOneWidget);
  });
}
