import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/education/education_page.dart';

void main() {
  testWidgets(
    'shows both degrees, certifications, and the publication',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationPage()));

      expect(
        find.text('Bacharelado, Engenharia de Computação'),
        findsOneWidget,
      );
      expect(find.text('2021–2026 · Concluído'), findsOneWidget);
      expect(
        find.text('Curso Técnico, Técnico em Informática'),
        findsOneWidget,
      );
      expect(find.text('2017–2022 · Concluído'), findsOneWidget);
      expect(
        find.textContaining('Escola Regional de Aprendizado de Máquina'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'SoYolo: Detecção automática de vagens e grãos de soja',
        ),
        findsOneWidget,
      );
    },
  );
}
