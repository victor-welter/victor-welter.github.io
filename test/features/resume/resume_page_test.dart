import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/resume/resume_page.dart';

void main() {
  testWidgets('shows the summary and the PDF button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResumePage()));

    expect(find.text('Currículo'), findsOneWidget);
    expect(find.text('Ver Currículo (PDF)'), findsOneWidget);
  });

  test('resolves the PDF path relative to the current base URI', () {
    final resolved = Uri.base.resolve(ResumePage.resumeAssetPath);

    expect(
      resolved.path,
      endsWith('assets/documents/curriculo-victor-welter.pdf'),
    );
  });
}
