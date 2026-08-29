# Portfolio Fase 5 (Conteúdo) — Content Design

## Context

Fase 3 (Fundação) and Fase 4 (Design) are complete and live: routing, adaptive
shell, the full dark/light visual identity, and CI/CD are all in place. All
nine pages (`lib/features/*`) are still `PlaceholderSection` widgets showing
`PLACEHOLDER: ...` text — no real content exists anywhere on the site yet.

**Goal of this phase:** replace every placeholder with real, honest content
sourced from Víctor's actual résumé (LinkedIn export, `Profile.pdf`) and
GitHub repositories. Nothing about routing, theme, or CI/CD changes in this
phase.

**Hard content rule (non-negotiable, carried from the project's standing
instructions):** never invent, exaggerate, or infer professional facts,
skills, achievements, project details, dates, or academic information. Only
technologies/skills/claims explicitly supported by the résumé, project
information, or information Víctor provided directly in this conversation
are allowed on the site. Anything genuinely uncertain is marked
`TODO: confirmar informação`, not guessed.

## Sources Used

- `Profile.pdf` (LinkedIn export, provided by Víctor, moved into the repo as
  a build asset — see Architecture below) — full résumé: contact, top
  skills, certifications, publications, professional summary, all 6
  employment entries with exact dates/bullets, both education entries.
- GitHub public API (`api.github.com/users/victor-welter`, `.../repos`) —
  profile metadata and repo list/descriptions.
- Individual repo READMEs (`monitoramentoEnergia-Mobile`,
  `autoConnect-Api-Python`) — richer project descriptions than the repo
  metadata alone provided.
- Details Víctor typed directly in this conversation for two projects not
  publicly visible on GitHub (private repos): **Bee Visit Tracking &
  Counting** (full details provided) and **BarberApp** (not yet provided —
  see Open Items).
- LinkedIn itself could not be fetched directly (blocked automated access,
  HTTP 999) — the PDF export was the substitute and turned out to be more
  complete than the live page would have been anyway.

## Architecture

Continues Fase 3/4's established pattern — no premature data/domain/backend
layers, since all content is static:

- **One typed data model + static `const` list per section that needs
  structured data**, living in that feature's own folder:
  - `lib/features/experience/experience_data.dart` — `ExperienceEntry`
    (company, role, period, location, bullets, `tier` enum
    `{primary, previous}`)
  - `lib/features/education/education_data.dart` — `EducationEntry`
    (institution, degree, period, status) plus separate const lists for
    certifications and publications (plain strings — no need for a type)
  - `lib/features/skills/skills_data.dart` — `SkillCategory` (name, `List<String>` skills)
  - `lib/features/projects/projects_data.dart` — `ProjectEntry` (name,
    description, tech stack, `List<ProjectLink>` (label + URL), `tier` enum
    `{featured, secondary}`)
  - Home, Sobre, Currículo, Contato stay plain widgets with inline text —
    the content is prose/links, not repeating structured records, so a data
    model would be pure ceremony.
- **New dependency: `url_launcher`** (this phase's one new package, same
  pattern as Fase 4's `google_fonts`) — needed for GitHub project links, the
  Contato page's email/LinkedIn/GitHub links, and opening the résumé PDF.
- **Skills displayed as pill-shaped tag chips** using `AppTheme.monoTextStyle`
  and the `StadiumBorder` shape — this is exactly what Fase 4's design spec
  pre-reserved that convention for. No proficiency bars/percentages/ratings
  anywhere — those would be fabricated precision this project's rules
  explicitly forbid.
- **Résumé PDF handling:** `Profile.pdf` is renamed and moved to
  `web/assets/documents/curriculo-victor-welter.pdf` (a static file Flutter's
  web build copies through as-is). The Currículo page's button opens it via
  `url_launcher`, in a new tab — not a forced download (explicitly Víctor's
  call: "opening in a new tab is not necessarily the same as downloading";
  simple and reliable now, explicit download behavior can be added later if
  needed). The URL is built as `Uri.base.resolve('assets/documents/curriculo-victor-welter.pdf')`
  rather than a hardcoded absolute path, so it keeps working if the site's
  base href ever changes from root (GitHub Pages project-page subpaths,
  etc.) — this was an explicit robustness requirement, not the default
  Fase 3 routing behavior.

## Content

### Home

- Nome: **Víctor Welter**
- Tagline: **Engenheiro de Computação · Software · IA**
- Intro (short, condensed from the résumé's own Resumo — forward-looking
  framing was Víctor's explicit choice over leading with his current
  "Assistente de Processos e Qualidade" title):

  > Engenheiro de Computação com experiência em desenvolvimento de
  > software, integração de sistemas e melhoria de processos. Atuo com
  > aplicações, APIs e bancos de dados, além de projetos e pesquisas em
  > Inteligência Artificial e Visão Computacional.

- CTAs to Projetos and Contato (navigation only, not content claims).

### Sobre

Résumé's "Resumo" section, essentially verbatim (it's Víctor's own
first-person writing), split into two paragraphs for web readability:

> Olá! Sou Víctor Vinícius Welter, Engenheiro de Computação e Técnico em
> Informática, com experiência em desenvolvimento de software, integração
> de sistemas e melhoria de processos. Minha experiência envolve
> desenvolvimento de aplicações, APIs e bancos de dados, além do contato
> com práticas de arquitetura, Cloud Computing e DevOps.
>
> Também desenvolvo projetos e pesquisas na área de Inteligência
> Artificial e Visão Computacional, explorando modelos de Deep Learning
> aplicados a problemas reais. Busco constantemente aprimorar minhas
> habilidades e acompanhar novas tecnologias. Priorizo a organização,
> qualidade e excelência no que faço, além de valorizar a comunicação, o
> trabalho em equipe e o aprendizado contínuo.

Location line: Três de Maio, Rio Grande do Sul, Brasil.

### Experiência

Two visual tiers, same six entries — nothing removed, per Víctor's explicit
instruction to keep the full trajectory but not give every role equal
prominence.

**Tier `primary` (tech-relevant, prominent treatment):**

1. **Sicredi Confiança** — Assistente de Processos e Qualidade — mai/2024 – Presente — Três de Maio, RS
   - Atuação no mapeamento e identificação de melhorias e otimizações em jornadas e processos, aplicando conceitos de Lean Office e Poka-Yoke para eliminar desperdícios e prevenir falhas
   - Modelagem de fluxos de processo em ferramenta de workflow, desenhando etapas, campos e funcionalidades específicas para cada jornada
   - Identificação de oportunidades de automação e integração entre sistemas, implementando soluções via APIs e RPA
   - Criação de consultas em SQL para levantamento e análise de bases de dados de apoio aos processos
   - Desenvolvimento de scripts em Python para automação e otimização de tempo em tarefas recorrentes

2. **Abase Sistemas e Soluções Ltda** — Desenvolvedor Mobile — ago/2021 – mai/2024 — Três de Maio, RS
   - Participação no planejamento e desenvolvimento de mais de 20 aplicativos voltados para a gestão pública, responsável por todo o ciclo de desenvolvimento, desde a criação da interface até a integração com o backend
   - Desenvolvimento de aplicativos utilizando Flutter/Dart, aplicando tecnologias como GetIt, MobX, Provider e SQFlite para gerenciamento de estado, dependências e banco de dados local
   - Integração com Firebase, incluindo Firestore Database, Storage, Realtime Database, Crashlytics e Push Notifications
   - Implementação de Flavors para criação de versões personalizadas de aplicativos, facilitando a gestão de diferentes configurações em um único projeto
   - Desenvolvimento de soluções de segurança com Reconhecimento Facial para autenticação e Geolocalização para funcionalidades baseadas na localização dos usuários
   - Criação e manutenção de APIs RESTful em C# ASP.NET, utilizando Sybase e PostgreSQL como bancos de dados
   - Publicação dos aplicativos nas lojas Play Store e App Store

3. **Abase Sistemas e Soluções Ltda** — Estagiário em Desenvolvimento Mobile — mai/2021 – ago/2021 — Três de Maio, RS
   - Estudo das práticas de desenvolvimento de layouts para aplicativos móveis, com foco nas melhores técnicas de design
   - Introdução ao Flutter, com noções iniciais do funcionamento e aplicação de widgets básicos no desenvolvimento de interfaces
   - Desenvolvimento de um aplicativo móvel, criando uma solução que atendia às necessidades propostas pela empresa, aplicando conceitos aprendidos durante o estágio

**Tier `previous` ("Experiência anterior", visually secondary — e.g.
collapsed/condensed list, smaller type, no expanded bullets required):**

4. **Lojas Colombo S/A** — Vendedor de Comércio Varejista — jan/2021 – mai/2021 — Três de Maio, RS
5. **Lojas Colombo S/A** — Assistente Administrativo (Programa Menor Aprendiz SENAC) — mai/2019 – jun/2020 — Três de Maio, RS
6. **Grupo Lactalis** — Assistente Administrativo (Programa Jovem Aprendiz SETREM) — mar/2017 – mar/2019 — Três de Maio, RS

(Full bullets for these three are still stored in `experience_data.dart` for
completeness/reuse even if the UI only surfaces title/company/period at a
glance — implementation plan decides exact collapsed-vs-expanded
presentation.)

### Formação

- **Bacharelado em Engenharia de Computação** — SETREM (Sociedade
  Educacional Três de Maio) — 2021–2026 · Concluído
- **Técnico em Informática** — SETREM (Sociedade Educacional Três de Maio)
  — 2017–2022 · Concluído

(Year-range format per Víctor's explicit instruction — the résumé's PDF
export states month-level dates, but the Bacharelado's end date coincides
suspiciously exactly with today, so month precision isn't trusted; the same
simplification applies to both entries for consistency, per his instruction.)

**Certificações:**
- Escola Regional de Aprendizado de Máquina e IA
- Notificações por Push no Android, iOS e Web com Flutter

**Publicações:**
- SoYolo: Detecção automática de vagens e grãos de soja

(Exact title, no paraphrasing — explicit instruction. No link — text only.)

### Skills

Five type-pure categories (tools/frameworks kept separate from practices,
which are kept separate from broad domains; one-off project features like
Reconhecimento Facial/Geolocalização excluded as not generalizable skills —
they're already covered in the Experiência bullets above; Git/GitHub
excluded because it's never actually stated as a skill in the résumé, only
implied by the presence of a GitHub link):

- **Mobile** — Flutter, Dart, GetIt, MobX, Provider, SQFlite, Flavors
- **Backend & Dados** — C#, ASP.NET, APIs RESTful, PostgreSQL, Sybase, SQL, Firebase
- **IA & Automação** — Python, Inteligência Artificial, Visão Computacional, Deep Learning, RPA
- **Processos & Qualidade** — Mapeamento de processos, Melhoria contínua, Lean Office, Poka-Yoke, Gestão de mudanças
- **Arquitetura & Cloud** — Arquitetura de software, Cloud Computing, DevOps

### Projetos

**Featured (full card — name, description, tech stack, link(s)):**

1. **Bee Visit Tracking & Counting**
   - Descrição: Sistema de Visão Computacional para detectar, rastrear e
     contar visitas de abelhas em vídeos capturados em condições reais de
     campo. Objetivo: analisar a atividade de abelhas e contabilizar
     visitas automaticamente. Principais desafios enfrentados: objetos
     pequenos na imagem, movimento rápido, oclusões, iluminação variável,
     fundos complexos e dinâmicos, e falsos positivos causados por flores e
     vegetação.
   - Tecnologias: Python, OpenCV, PyTorch, YOLO, ByteTrack / BoT-SORT, PyTest, Ruff
   - Status: Em desenvolvimento ativo / validação acadêmica e de pesquisa
   - **No accuracy/results metrics** — none were provided, none are claimed.
   - Link: **TODO: confirmar se deve haver link** — o repositório é
     privado; decidir se o card omite o link (como a publicação SoYolo) ou
     se Víctor prefere tornar o repositório público antes do lançamento
     desta seção.

2. **AutoConnect** — Prática Profissional (7°/8° semestre, Engenharia de
   Computação – SETREM)
   - Descrição: Sistema para gerenciamento de dados de automóveis e
     proprietários, com aplicativo mobile, sistema web, API REST (FastAPI)
     e hardware embarcado.
   - Tecnologias: Flutter/Dart (mobile e web), Python/FastAPI (API), hardware embarcado
   - Links: `autoConnect-Mobile`, `autoConnect-Web`, `autoConnect-Api-Python`, `autoConnect-Hardware` (todos em github.com/victor-welter)

3. **Monitoramento de Energia** — projeto acadêmico de extensão (4°
   semestre, Engenharia de Computação – SETREM)
   - Descrição: Protótipo de sistema para medição e monitoramento de
     consumo de energia elétrica em tempo real, apresentando ao usuário o
     valor monetário gasto por hora para um equipamento em funcionamento.
   - Tecnologias: Flutter/Dart (mobile), hardware embarcado, API
   - Links: `monitoramentoEnergia-Mobile`, `monitoramentoEnergia-Hardware`, `monitoramentoEnergia-Api`

4. **validator-assincrono**
   - Descrição: Biblioteca/pacote Flutter para criação de validadores assíncronos.
   - Tecnologias: Flutter/Dart
   - Link: github.com/victor-welter/validator-assincrono

**Secondary (lightweight — name + one-liner + link, no full card):**

- **youtube_downloader** — Aplicativo desktop em Python para baixar vídeos do YouTube em alta qualidade.
- **qr-scanner-generator** — Leitor e gerador de QR Code em Flutter.
- **flavors** — Gerenciamento de Flavors para projetos Flutter.

**Excluded:** `calculadora` (no substantive real description available;
Víctor confirmed he's comfortable leaving it out).

**Explicitly out of scope for this implementation: BarberApp.** Víctor
flagged it as an important project but has not yet provided real project
details (description, tech stack, status). It must not be added with
invented content. See Open Items.

### Currículo

- Condensed professional summary (same short paragraph as Home, or a
  slightly fuller variant — implementation plan's call, not a content
  question).
- Button: "Ver Currículo (PDF)" → opens
  `web/assets/documents/curriculo-victor-welter.pdf` in a new tab via
  `url_launcher`, using the `Uri.base.resolve(...)`-based URL described in
  Architecture.

### Contato

- Email: victorwelter2003@gmail.com (`mailto:` link)
- LinkedIn: linkedin.com/in/victor-welter (external link)
- GitHub: github.com/victor-welter (external link)
- Localização: Três de Maio, Rio Grande do Sul, Brasil (informational text, not a link)

## Testing

Matches Fase 3/4's rigor: widget tests per page confirming the real content
renders (title/company/skill-chip text present, correct tier grouping,
correct link count), plus a unit test or two on the data files themselves
where trivial (e.g. `experienceEntries` isn't empty, has exactly 6 entries,
tier counts are 3/3). No golden-image tests — out of scope, matches existing
project conventions. Real-browser Playwright verification before any
deploy, unbroken streak from Fase 3/4's established practice given this
project's history of bugs that only a real browser catches.

## Scope

**Changes:**
- `pubspec.yaml` — add `url_launcher`.
- All 9 files under `lib/features/*` — real content replacing
  `PlaceholderSection` usage.
- New `*_data.dart` files per section listed in Architecture.
- `Profile.pdf` moved to `web/assets/documents/curriculo-victor-welter.pdf`
  (and removed from the repo root where it currently sits untracked).

**Explicitly out of scope for this phase:**
- Routing, theme (`AppTheme`), `AppShell`, CI/CD — untouched, Fase 3/4's territory.
- BarberApp content (see Open Items).
- Any new visual/interaction pattern beyond what Fase 4 already established
  (chips/pill shape, card shape, button shape) — this phase populates
  content into the existing design system, it doesn't extend the design
  system itself.

## Open Items (must be resolved before/during implementation, not guessed)

1. **BarberApp** — Víctor will provide project details (description, tech
   stack, status, and whether it should be a featured or secondary
   project) before this project is added. Until then it does not appear on
   the site at all.
2. **Bee Visit Tracking & Counting's GitHub link** — the repo is currently
   private. Decide whether the project card omits the link entirely (like
   the SoYolo publication) or whether Víctor will make the repo public
   before this section ships.
