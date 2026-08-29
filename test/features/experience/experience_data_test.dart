import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/experience/experience_data.dart';

void main() {
  test('has all six roles from the résumé', () {
    expect(experienceEntries.length, 6);
  });

  test('splits into 3 primary (tech) and 3 previous roles', () {
    final primary = experienceEntries.where(
      (e) => e.tier == ExperienceTier.primary,
    );
    final previous = experienceEntries.where(
      (e) => e.tier == ExperienceTier.previous,
    );

    expect(primary.length, 3);
    expect(previous.length, 3);
    expect(
      primary.map((e) => e.company),
      containsAll(<String>[
        'Sicredi Confiança',
        'Abase Sistemas e Soluções Ltda',
      ]),
    );
  });

  test('no entry has empty bullets', () {
    for (final entry in experienceEntries) {
      expect(entry.bullets, isNotEmpty, reason: entry.company);
    }
  });
}
