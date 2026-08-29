enum ProjectTier { featured, secondary }

class ProjectLink {
  const ProjectLink({required this.label, required this.url});

  final String label;
  final String url;
}

class ProjectEntry {
  const ProjectEntry({
    required this.name,
    required this.description,
    required this.techStack,
    required this.links,
    required this.tier,
  });

  final String name;
  final String description;
  final List<String> techStack;
  final List<ProjectLink> links;
  final ProjectTier tier;
}

const List<ProjectEntry> projectEntries = [
  ProjectEntry(
    tier: ProjectTier.featured,
    name: 'Bee Visit Tracking & Counting',
    description:
        'Sistema de Visão Computacional para detectar, rastrear e contar '
        'visitas de abelhas em vídeos capturados em condições reais de '
        'campo. Objetivo: analisar a atividade de abelhas e contabilizar '
        'visitas automaticamente. Principais desafios enfrentados: objetos '
        'pequenos na imagem, movimento rápido, oclusões, iluminação '
        'variável, fundos complexos e dinâmicos, e falsos positivos '
        'causados por flores e vegetação. Em desenvolvimento ativo / '
        'validação acadêmica e de pesquisa.',
    techStack: [
      'Python',
      'OpenCV',
      'PyTorch',
      'YOLO',
      'ByteTrack / BoT-SORT',
      'PyTest',
      'Ruff',
    ],
    links: [],
  ),
  ProjectEntry(
    tier: ProjectTier.featured,
    name: 'AutoConnect',
    description:
        'Sistema para gerenciamento de dados de automóveis e proprietários, '
        'com aplicativo mobile, sistema web, API REST (FastAPI) e hardware '
        'embarcado. Desenvolvido como Prática Profissional (7°/8° semestre, '
        'Engenharia de Computação – SETREM).',
    techStack: ['Flutter', 'Dart', 'Python', 'FastAPI'],
    links: [
      ProjectLink(
        label: 'Mobile',
        url: 'https://github.com/victor-welter/autoConnect-Mobile',
      ),
      ProjectLink(
        label: 'Web',
        url: 'https://github.com/victor-welter/autoConnect-Web',
      ),
      ProjectLink(
        label: 'API',
        url: 'https://github.com/victor-welter/autoConnect-Api-Python',
      ),
      ProjectLink(
        label: 'Hardware',
        url: 'https://github.com/victor-welter/autoConnect-Hardware',
      ),
    ],
  ),
  ProjectEntry(
    tier: ProjectTier.featured,
    name: 'Monitoramento de Energia',
    description:
        'Protótipo de sistema para medição e monitoramento de consumo de '
        'energia elétrica em tempo real, apresentando ao usuário o valor '
        'monetário gasto por hora para um equipamento em funcionamento. '
        'Projeto acadêmico de extensão (4° semestre, Engenharia de '
        'Computação – SETREM).',
    techStack: ['Flutter', 'Dart'],
    links: [
      ProjectLink(
        label: 'Mobile',
        url: 'https://github.com/victor-welter/monitoramentoEnergia-Mobile',
      ),
      ProjectLink(
        label: 'Hardware',
        url: 'https://github.com/victor-welter/monitoramentoEnergia-Hardware',
      ),
      ProjectLink(
        label: 'API',
        url: 'https://github.com/victor-welter/monitoramentoEnergia-Api',
      ),
    ],
  ),
  ProjectEntry(
    tier: ProjectTier.featured,
    name: 'validator-assincrono',
    description:
        'Biblioteca/pacote Flutter para criação de validadores '
        'assíncronos.',
    techStack: ['Flutter', 'Dart'],
    links: [
      ProjectLink(
        label: 'GitHub',
        url: 'https://github.com/victor-welter/validator-assincrono',
      ),
    ],
  ),
  ProjectEntry(
    tier: ProjectTier.secondary,
    name: 'youtube_downloader',
    description:
        'Aplicativo desktop em Python para baixar vídeos do YouTube em '
        'alta qualidade.',
    techStack: ['Python'],
    links: [
      ProjectLink(
        label: 'GitHub',
        url: 'https://github.com/victor-welter/youtube_downloader',
      ),
    ],
  ),
  ProjectEntry(
    tier: ProjectTier.secondary,
    name: 'qr-scanner-generator',
    description: 'Leitor e gerador de QR Code em Flutter.',
    techStack: ['Flutter', 'Dart'],
    links: [
      ProjectLink(
        label: 'GitHub',
        url: 'https://github.com/victor-welter/qr-scanner-generator',
      ),
    ],
  ),
  ProjectEntry(
    tier: ProjectTier.secondary,
    name: 'flavors',
    description: 'Gerenciamento de Flavors para projetos Flutter.',
    techStack: ['Flutter', 'Dart'],
    links: [
      ProjectLink(
        label: 'GitHub',
        url: 'https://github.com/victor-welter/flavors',
      ),
    ],
  ),
];
