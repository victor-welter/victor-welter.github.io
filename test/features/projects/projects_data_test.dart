import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/projects/projects_data.dart';

void main() {
  test('has exactly 4 featured and 3 secondary projects', () {
    final featured = projectEntries.where(
      (p) => p.tier == ProjectTier.featured,
    );
    final secondary = projectEntries.where(
      (p) => p.tier == ProjectTier.secondary,
    );

    expect(featured.length, 4);
    expect(secondary.length, 3);
  });

  test('does not include calculadora or BarberApp', () {
    final names = projectEntries.map((p) => p.name);
    expect(names, isNot(contains('calculadora')));
    expect(names, isNot(contains('BarberApp')));
  });

  test(
    'Bee Visit Tracking & Counting has no links (private repo) and no '
    'results/accuracy claims',
    () {
      final beeProject = projectEntries.firstWhere(
        (p) => p.name == 'Bee Visit Tracking & Counting',
      );

      expect(beeProject.links, isEmpty);
      expect(beeProject.description, isNot(contains('%')));
    },
  );

  test('AutoConnect links to all four sub-repos', () {
    final autoConnect = projectEntries.firstWhere(
      (p) => p.name == 'AutoConnect',
    );

    expect(autoConnect.links.length, 4);
  });
}
