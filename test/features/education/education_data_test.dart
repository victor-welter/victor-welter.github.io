import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/education/education_data.dart';

void main() {
  test('has both Setrem degree entries', () {
    expect(educationEntries.length, 2);
    expect(
      educationEntries.map((e) => e.degree),
      containsAll(<String>[
        'Bacharelado, Engenharia de Computação',
        'Curso Técnico, Técnico em Informática',
      ]),
    );
  });

  test('uses year-range periods, not month-specific dates', () {
    for (final entry in educationEntries) {
      expect(entry.period, matches(RegExp(r'^\d{4}–\d{4}$')));
    }
  });

  test('lists both certifications', () {
    expect(certifications.length, 2);
  });

  test('lists the SoYolo publication with its exact title', () {
    expect(
      publications,
      contains('SoYolo: Detecção automática de vagens e grãos de soja'),
    );
  });
}
