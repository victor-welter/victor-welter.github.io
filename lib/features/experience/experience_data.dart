enum ExperienceTier { primary, previous }

class ExperienceEntry {
  const ExperienceEntry({
    required this.company,
    required this.role,
    required this.period,
    required this.location,
    required this.bullets,
    required this.tier,
  });

  final String company;
  final String role;
  final String period;
  final String location;
  final List<String> bullets;
  final ExperienceTier tier;
}

const List<ExperienceEntry> experienceEntries = [
  ExperienceEntry(
    company: 'Sicredi Confiança',
    role: 'Assistente de Processos e Qualidade',
    period: 'mai/2024 – Presente',
    location: 'Três de Maio, RS',
    tier: ExperienceTier.primary,
    bullets: [
      'Atuação no mapeamento e identificação de melhorias e otimizações em '
          'jornadas e processos, aplicando conceitos de Lean Office e '
          'Poka-Yoke para eliminar desperdícios e prevenir falhas',
      'Modelagem de fluxos de processo em ferramenta de workflow, '
          'desenhando etapas, campos e funcionalidades específicas para '
          'cada jornada',
      'Identificação de oportunidades de automação e integração entre '
          'sistemas, implementando soluções via APIs e RPA',
      'Criação de consultas em SQL para levantamento e análise de bases '
          'de dados de apoio aos processos',
      'Desenvolvimento de scripts em Python para automação e otimização '
          'de tempo em tarefas recorrentes',
    ],
  ),
  ExperienceEntry(
    company: 'Abase Sistemas e Soluções Ltda',
    role: 'Desenvolvedor Mobile',
    period: 'ago/2021 – mai/2024',
    location: 'Três de Maio, RS',
    tier: ExperienceTier.primary,
    bullets: [
      'Participação no planejamento e desenvolvimento de mais de 20 '
          'aplicativos voltados para a gestão pública, responsável por '
          'todo o ciclo de desenvolvimento, desde a criação da interface '
          'até a integração com o backend',
      'Desenvolvimento de aplicativos utilizando Flutter/Dart, aplicando '
          'tecnologias como GetIt, MobX, Provider e SQFlite para '
          'gerenciamento de estado, dependências e banco de dados local',
      'Integração com Firebase, incluindo Firestore Database, Storage, '
          'Realtime Database, Crashlytics e Push Notifications',
      'Implementação de Flavors para criação de versões personalizadas '
          'de aplicativos, facilitando a gestão de diferentes '
          'configurações em um único projeto',
      'Desenvolvimento de soluções de segurança com Reconhecimento '
          'Facial para autenticação e Geolocalização para funcionalidades '
          'baseadas na localização dos usuários',
      'Criação e manutenção de APIs RESTful em C# ASP.NET, utilizando '
          'Sybase e PostgreSQL como bancos de dados',
      'Publicação dos aplicativos nas lojas Play Store e App Store',
    ],
  ),
  ExperienceEntry(
    company: 'Abase Sistemas e Soluções Ltda',
    role: 'Estagiário em Desenvolvimento Mobile',
    period: 'mai/2021 – ago/2021',
    location: 'Três de Maio, RS',
    tier: ExperienceTier.primary,
    bullets: [
      'Estudo das práticas de desenvolvimento de layouts para '
          'aplicativos móveis, com foco nas melhores técnicas de design',
      'Introdução ao Flutter, com noções iniciais do funcionamento e '
          'aplicação de widgets básicos no desenvolvimento de interfaces',
      'Desenvolvimento de um aplicativo móvel, criando uma solução que '
          'atendia às necessidades propostas pela empresa, aplicando '
          'conceitos aprendidos durante o estágio',
    ],
  ),
  ExperienceEntry(
    company: 'Lojas Colombo S/A',
    role: 'Vendedor de Comércio Varejista',
    period: 'jan/2021 – mai/2021',
    location: 'Três de Maio, RS',
    tier: ExperienceTier.previous,
    bullets: [
      'Atendimento ao cliente, ajudando a escolher produtos de acordo '
          'com as necessidades e desejos dos clientes',
      'Responsável pelo fechamento de vendas, atingindo as metas '
          'estabelecidas',
      'Auxílio na criação de vídeos e propagandas para atrair mais '
          'clientes e divulgar a loja',
      'Contribuição na elaboração de cartazes e materiais promocionais '
          'com preços e ofertas',
    ],
  ),
  ExperienceEntry(
    company: 'Lojas Colombo S/A',
    role: 'Assistente Administrativo (Programa Menor Aprendiz SENAC)',
    period: 'mai/2019 – jun/2020',
    location: 'Três de Maio, RS',
    tier: ExperienceTier.previous,
    bullets: [
      'Atendimento ao cliente e suporte nas vendas',
      'Conferência e organização de estoque dos produtos',
      'Organização e arquivamento de documentos',
      'Apoio nas assistências e entregas',
    ],
  ),
  ExperienceEntry(
    company: 'Grupo Lactalis',
    role: 'Assistente Administrativo (Programa Jovem Aprendiz SETREM)',
    period: 'mar/2017 – mar/2019',
    location: 'Três de Maio, RS',
    tier: ExperienceTier.previous,
    bullets: [
      'Lançamento e atualização de dados em planilhas administrativas',
      'Organização e arquivamento de documentos',
      'Apoio na contagem e controle de estoque',
    ],
  ),
];
