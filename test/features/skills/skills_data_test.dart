import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/skills/skills_data.dart';

void main() {
  test('has exactly the five approved categories, in order', () {
    expect(skillCategories.map((c) => c.name), [
      'Mobile',
      'Backend & Dados',
      'IA & Automação',
      'Processos & Qualidade',
      'Arquitetura & Cloud',
    ]);
  });

  test('no category is empty', () {
    for (final category in skillCategories) {
      expect(category.skills, isNotEmpty, reason: category.name);
    }
  });

  test('does not include Git/GitHub as a stated skill', () {
    final allSkills = skillCategories.expand((c) => c.skills);
    expect(allSkills, isNot(contains('Git')));
    expect(allSkills, isNot(contains('GitHub')));
  });
}
