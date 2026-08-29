class SkillCategory {
  const SkillCategory({required this.name, required this.skills});

  final String name;
  final List<String> skills;
}

const List<SkillCategory> skillCategories = [
  SkillCategory(
    name: 'Mobile',
    skills: [
      'Flutter',
      'Dart',
      'GetIt',
      'MobX',
      'Provider',
      'SQFlite',
      'Flavors',
    ],
  ),
  SkillCategory(
    name: 'Backend & Dados',
    skills: [
      'C#',
      'ASP.NET',
      'APIs RESTful',
      'PostgreSQL',
      'Sybase',
      'SQL',
      'Firebase',
    ],
  ),
  SkillCategory(
    name: 'IA & Automação',
    skills: [
      'Python',
      'Inteligência Artificial',
      'Visão Computacional',
      'Deep Learning',
      'RPA',
    ],
  ),
  SkillCategory(
    name: 'Processos & Qualidade',
    skills: [
      'Mapeamento de processos',
      'Melhoria contínua',
      'Lean Office',
      'Poka-Yoke',
      'Gestão de mudanças',
    ],
  ),
  SkillCategory(
    name: 'Arquitetura & Cloud',
    skills: ['Arquitetura de software', 'Cloud Computing', 'DevOps'],
  ),
];
