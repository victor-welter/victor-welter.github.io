class EducationEntry {
  const EducationEntry({
    required this.institution,
    required this.degree,
    required this.period,
    required this.status,
  });

  final String institution;
  final String degree;
  final String period;
  final String status;
}

const List<EducationEntry> educationEntries = [
  EducationEntry(
    institution: 'Setrem - Sociedade Educacional Três de Maio',
    degree: 'Bacharelado, Engenharia de Computação',
    period: '2021–2026',
    status: 'Concluído',
  ),
  EducationEntry(
    institution: 'Setrem - Sociedade Educacional Três de Maio',
    degree: 'Curso Técnico, Técnico em Informática',
    period: '2017–2022',
    status: 'Concluído',
  ),
];

const List<String> certifications = [
  'Escola Regional de Aprendizado de Máquina e IA',
  'Notificações por Push no Android, iOS e Web com Flutter',
];

const List<String> publications = [
  'SoYolo: Detecção automática de vagens e grãos de soja',
];
