# Portfolio Fase 5 (Conteúdo) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder text on all nine portfolio pages with real content sourced from Víctor's résumé and GitHub, per the approved design spec.

**Architecture:** One typed data model + `const` list per section that needs structured data (`ExperienceEntry`, `EducationEntry`, `SkillCategory`, `ProjectEntry`), each living in its own feature folder, rendered by that feature's page widget. A new shared `TagChip` widget (pill-shaped, mono font — the convention Fase 4 reserved for exactly this) is used by both Skills and Projetos. `url_launcher` is added as the phase's one new dependency for external links and the résumé PDF.

**Tech Stack:** Flutter (stable channel, web only — unchanged from Fase 3/4), + `url_launcher` (new this phase).

Full context and the approved content: `docs/superpowers/specs/2026-08-29-portfolio-content-design.md`.

## Global Constraints

- Dart identifiers, class names, and code comments are in English; every string the user sees is in Portuguese (pt-BR) — all content below is already written in pt-BR, copy it verbatim.
- **Never invent, exaggerate, or infer professional facts, skills, achievements, project details, dates, or academic information.** Every string of real content in this plan is already sourced from Víctor's résumé, GitHub, or what he typed directly in the design conversation — do not add anything beyond what's written in each task below.
- `BarberApp` is explicitly **out of scope** for this plan — do not add it to `projects_data.dart` under any circumstances. It will be added in a follow-up once real project details are provided.
- The "Bee Visit Tracking & Counting" project has **no link** (private repo) and **no accuracy/results metrics** — do not add either.
- The only new dependency this phase is `url_launcher`. Do not add any other package.
- Do not change `AppTheme`, `AppShell`, routing, breakpoints, or CI/CD — those are Fase 3/4's territory and are done.
- Every git commit must be authored solely as the repository owner. Never add a `Co-Authored-By` line or any AI/tool-attribution trailer to a commit message.
- This phase ends with real code changes to a live, deployed site. Do not push to `main` without explicit user confirmation immediately before doing so — same production-action gate Fase 3/4 used for their deploys.
- CI (`.github/workflows/deploy.yml`) is pinned to Flutter `3.47.2` (see commit `8df680b`, "Fix CI deploy failure"). If the Flutter SDK on the machine running this plan is a different version, verify the final build/test pass against 3.47.2 specifically before considering this phase done — see Task 11.

---

### Task 1: Add the shared TagChip widget

**Files:**
- Create: `lib/core/widgets/tag_chip.dart`
- Test: `test/core/widgets/tag_chip_test.dart`

**Interfaces:**
- Consumes: `AppTheme.monoTextStyle` (existing static getter, `lib/core/theme/app_theme.dart:140`).
- Produces: `TagChip` widget — `const TagChip(String label, {Key? key})`. Consumed by Task 5 (Skills) and Task 7 (Projetos).

- [ ] **Step 1: Write the failing test**

Create `test/core/widgets/tag_chip_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/tag_chip.dart';

void main() {
  testWidgets('renders its label text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TagChip('Flutter')));

    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('uses a full-pill shape', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TagChip('Flutter')));

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration as BoxDecoration;
    final borderRadius = decoration.borderRadius as BorderRadius;

    expect(borderRadius, BorderRadius.circular(999));
  });
}
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/core/widgets/tag_chip_test.dart`
Expected: FAIL — compile error, `TagChip` isn't defined yet.

- [ ] **Step 3: Implement TagChip**

Create `lib/core/widgets/tag_chip.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small pill-shaped tag for skill names and project tech stacks — the
/// mono-font/full-pill convention the Fase 4 design spec reserved for
/// exactly this kind of technical/code-like UI element.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTheme.monoTextStyle.copyWith(
          color: colorScheme.onSurface,
          fontSize: 13,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/core/widgets/tag_chip_test.dart`
Expected: PASS — 2 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/tag_chip.dart test/core/widgets/tag_chip_test.dart
git commit -m "$(cat <<'EOF'
Add TagChip: pill-shaped skill/tech tag widget

Uses AppTheme.monoTextStyle and a full StadiumBorder-equivalent
radius — the convention the Fase 4 design spec reserved for
technical/code-like UI elements. First consumers are the Skills and
Projetos pages later in this phase.
EOF
)"
```

---

### Task 2: Home page content

**Files:**
- Modify: `lib/features/home/home_page.dart`
- Modify: `test/app/router_test.dart` (fix the now-stale placeholder assertion)
- Create: `test/features/home/home_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the HomePage entry — replaced by the dedicated test file)

**Interfaces:**
- Consumes: nothing new — `go_router`'s `context.go` (already used by `AppShell`).
- Produces: no public API change — `HomePage` stays a plain `StatelessWidget`.

- [ ] **Step 1: Write the failing tests**

Create `test/features/home/home_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/features/contact/contact_page.dart';
import 'package:portfolio/features/home/home_page.dart';
import 'package:portfolio/features/projects/projects_page.dart';

void main() {
  Widget buildTestApp() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/projetos',
          builder: (context, state) => const ProjectsPage(),
        ),
        GoRoute(
          path: '/contato',
          builder: (context, state) => const ContactPage(),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows the name and tagline', (tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Víctor Welter'), findsOneWidget);
    expect(
      find.text('Engenheiro de Computação · Software · IA'),
      findsOneWidget,
    );
  });

  testWidgets('the "Ver Projetos" button navigates to /projetos', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Ver Projetos'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectsPage), findsOneWidget);
  });

  testWidgets('the "Entrar em Contato" button navigates to /contato', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.widgetWithText(OutlinedButton, 'Entrar em Contato'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactPage), findsOneWidget);
  });
}
```

In `test/app/router_test.dart`, replace the `'renders the home page at the initial route'` test's body:

```dart
  testWidgets('renders the home page at the initial route', (tester) async {
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Víctor Welter'), findsOneWidget);
  });
```

In `test/features/pages_smoke_test.dart`, delete the `'HomePage shows its placeholder message'` test block and its now-unused `HomePage` import.

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/home/home_page_test.dart test/app/router_test.dart`
Expected: FAIL — `HomePage` still shows the old placeholder text, no "Ver Projetos"/"Entrar em Contato" buttons exist yet.

- [ ] **Step 3: Implement HomePage**

Replace the full contents of `lib/features/home/home_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Víctor Welter', style: textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Engenheiro de Computação · Software · IA',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Engenheiro de Computação com experiência em desenvolvimento de '
            'software, integração de sistemas e melhoria de processos. Atuo '
            'com aplicações, APIs e bancos de dados, além de projetos e '
            'pesquisas em Inteligência Artificial e Visão Computacional.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => context.go('/projetos'),
                child: const Text('Ver Projetos'),
              ),
              OutlinedButton(
                onPressed: () => context.go('/contato'),
                child: const Text('Entrar em Contato'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/features/home/home_page_test.dart test/app/router_test.dart test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/home_page.dart test/features/home/home_page_test.dart test/app/router_test.dart test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Home page content

Name, forward-looking tagline, and an intro condensed from the
résumé's own summary, plus CTAs to Projetos and Contato. Replaces the
Fase 3 placeholder.
EOF
)"
```

---

### Task 3: Sobre page content

**Files:**
- Modify: `lib/features/about/about_page.dart`
- Create: `test/features/about/about_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the AboutPage entry)

**Interfaces:**
- Consumes: nothing new.
- Produces: no public API change.

- [ ] **Step 1: Write the failing test**

Create `test/features/about/about_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/about/about_page.dart';

void main() {
  testWidgets('shows the heading and full first-person bio', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    expect(find.text('Sobre'), findsOneWidget);
    expect(find.textContaining('Víctor Vinícius Welter'), findsOneWidget);
    expect(
      find.textContaining('Inteligência Artificial e Visão Computacional'),
      findsOneWidget,
    );
    expect(
      find.text('Três de Maio, Rio Grande do Sul, Brasil'),
      findsOneWidget,
    );
  });
}
```

In `test/features/pages_smoke_test.dart`, delete the `'AboutPage shows its placeholder message'` test block and its now-unused `AboutPage` import.

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/about/about_page_test.dart`
Expected: FAIL — the page still shows the old placeholder text.

- [ ] **Step 3: Implement AboutPage**

Replace the full contents of `lib/features/about/about_page.dart`:

```dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sobre', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Olá! Sou Víctor Vinícius Welter, Engenheiro de Computação e '
            'Técnico em Informática, com experiência em desenvolvimento de '
            'software, integração de sistemas e melhoria de processos. '
            'Minha experiência envolve desenvolvimento de aplicações, APIs '
            'e bancos de dados, além do contato com práticas de '
            'arquitetura, Cloud Computing e DevOps.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Também desenvolvo projetos e pesquisas na área de '
            'Inteligência Artificial e Visão Computacional, explorando '
            'modelos de Deep Learning aplicados a problemas reais. Busco '
            'constantemente aprimorar minhas habilidades e acompanhar '
            'novas tecnologias. Priorizo a organização, qualidade e '
            'excelência no que faço, além de valorizar a comunicação, o '
            'trabalho em equipe e o aprendizado contínuo.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Três de Maio, Rio Grande do Sul, Brasil',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/features/about/about_page_test.dart test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/about/about_page.dart test/features/about/about_page_test.dart test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Sobre page content

The résumé's own first-person "Resumo" section, split into two
paragraphs for web readability. Replaces the Fase 3 placeholder.
EOF
)"
```

---

### Task 4: Formação page content (education, certifications, publications)

**Files:**
- Create: `lib/features/education/education_data.dart`
- Test: `test/features/education/education_data_test.dart`
- Modify: `lib/features/education/education_page.dart`
- Create: `test/features/education/education_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the EducationPage entry)

**Interfaces:**
- Consumes: nothing new.
- Produces: `EducationEntry` (institution, degree, period, status), `const List<EducationEntry> educationEntries`, `const List<String> certifications`, `const List<String> publications`. Not consumed by any other task.

- [ ] **Step 1: Write the failing data test**

Create `test/features/education/education_data_test.dart`:

```dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/education/education_data_test.dart`
Expected: FAIL — compile error, `education_data.dart` doesn't exist yet.

- [ ] **Step 3: Create the education data file**

Create `lib/features/education/education_data.dart`:

```dart
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
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/features/education/education_data_test.dart`
Expected: PASS — 4 tests.

- [ ] **Step 5: Write the failing page test**

Create `test/features/education/education_page_test.dart`:

```dart
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
```

In `test/features/pages_smoke_test.dart`, delete the `'EducationPage shows its placeholder message'` test block and its now-unused `EducationPage` import.

- [ ] **Step 6: Run it to confirm it fails**

Run: `flutter test test/features/education/education_page_test.dart`
Expected: FAIL — the page still shows the old placeholder text.

- [ ] **Step 7: Implement EducationPage**

Replace the full contents of `lib/features/education/education_page.dart`:

```dart
import 'package:flutter/material.dart';

import 'education_data.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Formação', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final entry in educationEntries) ...[
            Text(entry.degree, style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(entry.institution, style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '${entry.period} · ${entry.status}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
          Text('Certificações', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final certification in certifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $certification', style: textTheme.bodyLarge),
            ),
          const SizedBox(height: 20),
          Text('Publicações', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final publication in publications)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $publication', style: textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 8: Run it to confirm it passes**

Run: `flutter test test/features/education/ test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 9: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 10: Commit**

```bash
git add lib/features/education/education_data.dart lib/features/education/education_page.dart test/features/education/ test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Formação page content

Both Setrem degrees (year-range dates, not month-specific — the
Bacharelado's résumé end date coincides suspiciously exactly with
today, so month precision isn't trusted; kept consistent across both
entries), plus certifications and the SoYolo publication with its
exact, unparaphrased title. Replaces the Fase 3 placeholder.
EOF
)"
```

---

### Task 5: Skills page content

**Files:**
- Create: `lib/features/skills/skills_data.dart`
- Test: `test/features/skills/skills_data_test.dart`
- Modify: `lib/features/skills/skills_page.dart`
- Create: `test/features/skills/skills_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the SkillsPage entry)

**Interfaces:**
- Consumes: `TagChip` (Task 1, `lib/core/widgets/tag_chip.dart`).
- Produces: `SkillCategory` (name, `List<String> skills`), `const List<SkillCategory> skillCategories`. Not consumed by any other task.

- [ ] **Step 1: Write the failing data test**

Create `test/features/skills/skills_data_test.dart`:

```dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/skills/skills_data_test.dart`
Expected: FAIL — compile error, `skills_data.dart` doesn't exist yet.

- [ ] **Step 3: Create the skills data file**

Create `lib/features/skills/skills_data.dart`:

```dart
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
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/features/skills/skills_data_test.dart`
Expected: PASS — 3 tests.

- [ ] **Step 5: Write the failing page test**

Create `test/features/skills/skills_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/tag_chip.dart';
import 'package:portfolio/features/skills/skills_page.dart';

void main() {
  testWidgets('shows every category name and renders a chip per skill', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SkillsPage()));

    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Backend & Dados'), findsOneWidget);
    expect(find.text('IA & Automação'), findsOneWidget);
    expect(find.text('Processos & Qualidade'), findsOneWidget);
    expect(find.text('Arquitetura & Cloud'), findsOneWidget);

    expect(find.widgetWithText(TagChip, 'Flutter'), findsOneWidget);
    expect(find.widgetWithText(TagChip, 'Python'), findsOneWidget);
    expect(find.widgetWithText(TagChip, 'Lean Office'), findsOneWidget);
  });
}
```

In `test/features/pages_smoke_test.dart`, delete the `'SkillsPage shows its placeholder message'` test block and its now-unused `SkillsPage` import.

- [ ] **Step 6: Run it to confirm it fails**

Run: `flutter test test/features/skills/skills_page_test.dart`
Expected: FAIL — the page still shows the old placeholder text.

- [ ] **Step 7: Implement SkillsPage**

Replace the full contents of `lib/features/skills/skills_page.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/widgets/tag_chip.dart';
import 'skills_data.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Skills', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final category in skillCategories) ...[
            Text(category.name, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final skill in category.skills) TagChip(skill)],
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 8: Run it to confirm it passes**

Run: `flutter test test/features/skills/ test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 9: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 10: Commit**

```bash
git add lib/features/skills/skills_data.dart lib/features/skills/skills_page.dart test/features/skills/ test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Skills page content

Five type-pure categories (tools/frameworks kept separate from
practices, kept separate from broad domains) rendered as TagChip
pills. Excludes Git/GitHub (never actually stated as a skill in the
résumé) and one-off project features like Reconhecimento
Facial/Geolocalização (already covered in Experiência, not
generalizable skills). Replaces the Fase 3 placeholder.
EOF
)"
```

---

### Task 6: Experiência page content

**Files:**
- Create: `lib/features/experience/experience_data.dart`
- Test: `test/features/experience/experience_data_test.dart`
- Modify: `lib/features/experience/experience_page.dart`
- Create: `test/features/experience/experience_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the ExperiencePage entry)

**Interfaces:**
- Consumes: nothing new.
- Produces: `ExperienceTier` enum (`primary`, `previous`), `ExperienceEntry` (company, role, period, location, `List<String> bullets`, tier), `const List<ExperienceEntry> experienceEntries`. Not consumed by any other task.

- [ ] **Step 1: Write the failing data test**

Create `test/features/experience/experience_data_test.dart`:

```dart
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
```

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/experience/experience_data_test.dart`
Expected: FAIL — compile error, `experience_data.dart` doesn't exist yet.

- [ ] **Step 3: Create the experience data file**

Create `lib/features/experience/experience_data.dart`:

```dart
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
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/features/experience/experience_data_test.dart`
Expected: PASS — 3 tests.

- [ ] **Step 5: Write the failing page test**

Create `test/features/experience/experience_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/experience/experience_page.dart';

void main() {
  testWidgets(
    'shows all 3 primary roles with bullets and 3 previous roles condensed',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ExperiencePage()));

      expect(
        find.text('Assistente de Processos e Qualidade'),
        findsOneWidget,
      );
      expect(find.text('Desenvolvedor Mobile'), findsOneWidget);
      expect(
        find.text('Estagiário em Desenvolvimento Mobile'),
        findsOneWidget,
      );
      expect(find.textContaining('mais de 20 aplicativos'), findsOneWidget);

      expect(find.text('Experiência anterior'), findsOneWidget);
      expect(
        find.textContaining('Vendedor de Comércio Varejista'),
        findsOneWidget,
      );
      expect(find.textContaining('Grupo Lactalis'), findsOneWidget);
    },
  );
}
```

In `test/features/pages_smoke_test.dart`, delete the `'ExperiencePage shows its placeholder message'` test block and its now-unused `ExperiencePage` import.

- [ ] **Step 6: Run it to confirm it fails**

Run: `flutter test test/features/experience/experience_page_test.dart`
Expected: FAIL — the page still shows the old placeholder text.

- [ ] **Step 7: Implement ExperiencePage**

Replace the full contents of `lib/features/experience/experience_page.dart`:

```dart
import 'package:flutter/material.dart';

import 'experience_data.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = experienceEntries.where(
      (e) => e.tier == ExperienceTier.primary,
    );
    final previous = experienceEntries.where(
      (e) => e.tier == ExperienceTier.previous,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Experiência', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final entry in primary) _ExperienceCard(entry: entry),
          const SizedBox(height: 12),
          Text('Experiência anterior', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final entry in previous) _PreviousExperienceRow(entry: entry),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.entry});

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.role, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${entry.company} · ${entry.period}', style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          for (final bullet in entry.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $bullet', style: textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}

class _PreviousExperienceRow extends StatelessWidget {
  const _PreviousExperienceRow({required this.entry});

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${entry.role} — ${entry.company} (${entry.period})',
        style: textTheme.bodyMedium,
      ),
    );
  }
}
```

- [ ] **Step 8: Run it to confirm it passes**

Run: `flutter test test/features/experience/ test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 9: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 10: Commit**

```bash
git add lib/features/experience/experience_data.dart lib/features/experience/experience_page.dart test/features/experience/ test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Experiência page content

All 6 roles from the résumé, split into two visual tiers per
Víctor's explicit instruction: full bullet detail for the 3
tech-relevant roles (Sicredi, both Abase positions), condensed
one-line treatment under "Experiência anterior" for the 3 earlier
retail/admin roles. Nothing removed, just re-weighted. Replaces the
Fase 3 placeholder.
EOF
)"
```

---

### Task 7: Projetos page content

**Files:**
- Modify: `pubspec.yaml` (add `url_launcher`)
- Create: `lib/features/projects/projects_data.dart`
- Test: `test/features/projects/projects_data_test.dart`
- Modify: `lib/features/projects/projects_page.dart`
- Create: `test/features/projects/projects_page_test.dart`
- Modify: `test/app/router_test.dart` (fix the now-stale placeholder assertion)
- Modify: `test/features/pages_smoke_test.dart` (remove the ProjectsPage entry)

**Interfaces:**
- Consumes: `TagChip` (Task 1).
- Produces: `ProjectTier` enum (`featured`, `secondary`), `ProjectLink` (label, url), `ProjectEntry` (name, description, `List<String> techStack`, `List<ProjectLink> links`, tier), `const List<ProjectEntry> projectEntries`. `url_launcher`'s `launchUrl` is also consumed by Task 8 and Task 9.

- [ ] **Step 1: Add the url_launcher dependency**

Run: `flutter pub add url_launcher`

- [ ] **Step 2: Write the failing data test**

Create `test/features/projects/projects_data_test.dart`:

```dart
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
```

- [ ] **Step 3: Run it to confirm it fails**

Run: `flutter test test/features/projects/projects_data_test.dart`
Expected: FAIL — compile error, `projects_data.dart` doesn't exist yet.

- [ ] **Step 4: Create the projects data file**

Create `lib/features/projects/projects_data.dart`:

```dart
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
```

- [ ] **Step 5: Run it to confirm it passes**

Run: `flutter test test/features/projects/projects_data_test.dart`
Expected: PASS — 4 tests.

- [ ] **Step 6: Write the failing page test**

Create `test/features/projects/projects_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/widgets/tag_chip.dart';
import 'package:portfolio/features/projects/projects_page.dart';

void main() {
  testWidgets(
    'shows every featured project card and every secondary project row',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectsPage()));

      expect(find.text('Bee Visit Tracking & Counting'), findsOneWidget);
      expect(find.text('AutoConnect'), findsOneWidget);
      expect(find.text('Monitoramento de Energia'), findsOneWidget);
      expect(find.text('validator-assincrono'), findsOneWidget);

      expect(find.widgetWithText(TagChip, 'YOLO'), findsOneWidget);

      expect(find.text('Outros projetos'), findsOneWidget);
      expect(find.textContaining('youtube_downloader'), findsOneWidget);

      expect(find.text('calculadora'), findsNothing);
    },
  );

  testWidgets(
    'renders exactly 8 project link buttons total (Bee Visit contributes '
    'none, since its repo is private)',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProjectsPage()));

      expect(find.byType(TextButton), findsNWidgets(8));
    },
  );
}
```

In `test/app/router_test.dart`, replace the `'navigates to the projects route'` test's assertion:

```dart
  testWidgets('navigates to the projects route', (tester) async {
    final app = await buildApp();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    app.router.go('/projetos');
    await tester.pumpAndSettle();

    expect(find.text('AutoConnect'), findsOneWidget);
  });
```

In `test/features/pages_smoke_test.dart`, delete the `'ProjectsPage shows its placeholder message'` test block and its now-unused `ProjectsPage` import.

- [ ] **Step 7: Run it to confirm it fails**

Run: `flutter test test/features/projects/projects_page_test.dart test/app/router_test.dart`
Expected: FAIL — the page still shows the old placeholder text.

- [ ] **Step 8: Implement ProjectsPage**

Replace the full contents of `lib/features/projects/projects_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/tag_chip.dart';
import 'projects_data.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final featured = projectEntries.where(
      (p) => p.tier == ProjectTier.featured,
    );
    final secondary = projectEntries.where(
      (p) => p.tier == ProjectTier.secondary,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Projetos', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final project in featured) _ProjectCard(project: project),
          const SizedBox(height: 12),
          Text('Outros projetos', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final project in secondary)
            _SecondaryProjectRow(project: project),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.name, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(project.description, style: textTheme.bodyLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final tech in project.techStack) TagChip(tech)],
            ),
            if (project.links.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  for (final link in project.links)
                    TextButton(
                      onPressed: () => launchUrl(Uri.parse(link.url)),
                      child: Text(link.label),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryProjectRow extends StatelessWidget {
  const _SecondaryProjectRow({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: project.links.isEmpty
            ? null
            : () => launchUrl(Uri.parse(project.links.first.url)),
        child: Text(
          '${project.name} — ${project.description}',
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }
}
```

- [ ] **Step 9: Run it to confirm it passes**

Run: `flutter test test/features/projects/ test/app/router_test.dart test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 10: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 11: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/projects/projects_data.dart lib/features/projects/projects_page.dart test/features/projects/ test/app/router_test.dart test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Projetos page content

4 featured projects (Bee Visit Tracking & Counting, AutoConnect,
Monitoramento de Energia, validator-assincrono) as full cards with
tech-stack TagChips and links; 3 secondary projects as lightweight
rows. calculadora and BarberApp are deliberately excluded — the
former has no substantive real description, the latter awaits real
project details. Bee Visit Tracking & Counting has no link (private
repo) and no accuracy/results claims, matching the SoYolo publication
pattern. Adds url_launcher for the GitHub links. Replaces the Fase 3
placeholder.
EOF
)"
```

---

### Task 8: Currículo page content

**Files:**
- Modify: `lib/features/resume/resume_page.dart`
- Create: `test/features/resume/resume_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the ResumePage entry)
- Move: `Profile.pdf` (repo root) → `web/assets/documents/curriculo-victor-welter.pdf`

**Interfaces:**
- Consumes: `url_launcher`'s `launchUrl` (added in Task 7).
- Produces: `ResumePage.resumeAssetPath` (`static const String`) — not consumed by any other task, but documented here since the test references it directly.

- [ ] **Step 1: Move the résumé PDF into the web assets folder**

```bash
mkdir -p web/assets/documents
mv Profile.pdf web/assets/documents/curriculo-victor-welter.pdf
```

- [ ] **Step 2: Write the failing tests**

Create `test/features/resume/resume_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/resume/resume_page.dart';

void main() {
  testWidgets('shows the summary and the PDF button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResumePage()));

    expect(find.text('Currículo'), findsOneWidget);
    expect(find.text('Ver Currículo (PDF)'), findsOneWidget);
  });

  test('resolves the PDF path relative to the current base URI', () {
    final resolved = Uri.base.resolve(ResumePage.resumeAssetPath);

    expect(
      resolved.path,
      endsWith('assets/documents/curriculo-victor-welter.pdf'),
    );
  });
}
```

In `test/features/pages_smoke_test.dart`, delete the `'ResumePage shows its placeholder message'` test block and its now-unused `ResumePage` import.

- [ ] **Step 3: Run it to confirm it fails**

Run: `flutter test test/features/resume/resume_page_test.dart`
Expected: FAIL — the page still shows the old placeholder text; `ResumePage.resumeAssetPath` doesn't exist yet.

- [ ] **Step 4: Implement ResumePage**

Replace the full contents of `lib/features/resume/resume_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  /// Path relative to the deployed site's base href — resolved via
  /// `Uri.base.resolve` rather than a hardcoded absolute path so the link
  /// keeps working even if the site is ever served from a subpath instead
  /// of the domain root.
  static const String resumeAssetPath =
      'assets/documents/curriculo-victor-welter.pdf';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Currículo', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Engenheiro de Computação com experiência em desenvolvimento de '
            'software, integração de sistemas e melhoria de processos. '
            'Atuo com aplicações, APIs e bancos de dados, além de projetos '
            'e pesquisas em Inteligência Artificial e Visão Computacional.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => launchUrl(Uri.base.resolve(resumeAssetPath)),
            child: const Text('Ver Currículo (PDF)'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run it to confirm it passes**

Run: `flutter test test/features/resume/ test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 6: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 7: Commit**

```bash
git add web/assets/documents/curriculo-victor-welter.pdf lib/features/resume/resume_page.dart test/features/resume/ test/features/pages_smoke_test.dart
git status
```

Confirm `Profile.pdf` no longer appears anywhere in `git status` (it was untracked at the repo root and has been moved, not copied).

```bash
git commit -m "$(cat <<'EOF'
Add real Currículo page content

Moves the provided résumé PDF into web/assets/documents/ and wires
the download button to open it in a new tab via url_launcher, using
Uri.base.resolve so the link stays correct even if the site's base
href ever changes from the domain root. Opens in a new tab rather
than forcing a download, per explicit instruction — simple and
reliable now, explicit download behavior can be added later if
needed. Replaces the Fase 3 placeholder.
EOF
)"
```

---

### Task 9: Contato page content

**Files:**
- Modify: `lib/features/contact/contact_page.dart`
- Create: `test/features/contact/contact_page_test.dart`
- Modify: `test/features/pages_smoke_test.dart` (remove the ContactPage entry)

**Interfaces:**
- Consumes: `url_launcher`'s `launchUrl` (added in Task 7).
- Produces: no public API change.

- [ ] **Step 1: Write the failing test**

Create `test/features/contact/contact_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/contact/contact_page.dart';

void main() {
  testWidgets('shows email, LinkedIn, GitHub, and location', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ContactPage()));

    expect(find.text('victorwelter2003@gmail.com'), findsOneWidget);
    expect(find.text('linkedin.com/in/victor-welter'), findsOneWidget);
    expect(find.text('github.com/victor-welter'), findsOneWidget);
    expect(
      find.text('Três de Maio, Rio Grande do Sul, Brasil'),
      findsOneWidget,
    );
  });
}
```

In `test/features/pages_smoke_test.dart`, delete the `'ContactPage shows its placeholder message'` test block and its now-unused `ContactPage` import. After this step, `test/features/pages_smoke_test.dart` should contain only the `NotFoundPage` test.

- [ ] **Step 2: Run it to confirm it fails**

Run: `flutter test test/features/contact/contact_page_test.dart`
Expected: FAIL — the page still shows the old placeholder text.

- [ ] **Step 3: Implement ContactPage**

Replace the full contents of `lib/features/contact/contact_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Contato', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          _ContactLink(
            label: 'victorwelter2003@gmail.com',
            onTap: () =>
                launchUrl(Uri.parse('mailto:victorwelter2003@gmail.com')),
          ),
          _ContactLink(
            label: 'linkedin.com/in/victor-welter',
            onTap: () => launchUrl(
              Uri.parse('https://www.linkedin.com/in/victor-welter'),
            ),
          ),
          _ContactLink(
            label: 'github.com/victor-welter',
            onTap: () =>
                launchUrl(Uri.parse('https://github.com/victor-welter')),
          ),
          const SizedBox(height: 16),
          Text(
            'Três de Maio, Rio Grande do Sul, Brasil',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ContactLink extends StatelessWidget {
  const _ContactLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run it to confirm it passes**

Run: `flutter test test/features/contact/ test/features/pages_smoke_test.dart`
Expected: PASS.

- [ ] **Step 5: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; every test green.

- [ ] **Step 6: Commit**

```bash
git add lib/features/contact/contact_page.dart test/features/contact/ test/features/pages_smoke_test.dart
git commit -m "$(cat <<'EOF'
Add real Contato page content

Email (mailto), LinkedIn, and GitHub as tappable links via
url_launcher, plus location as plain informational text. Replaces
the Fase 3 placeholder — this was the last of the 9 pages.
EOF
)"
```

---

### Task 10: Remove the now-unused PlaceholderSection widget

**Files:**
- Delete: `lib/core/widgets/placeholder_section.dart`
- Delete: `test/core/widgets/placeholder_section_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: nothing — pure removal.

- [ ] **Step 1: Confirm nothing still references PlaceholderSection**

Run: `grep -r "PlaceholderSection" lib/ test/`
Expected: only `lib/core/widgets/placeholder_section.dart` itself and `test/core/widgets/placeholder_section_test.dart` — every one of the 9 feature pages built content directly in Tasks 2-9 instead of using it.

- [ ] **Step 2: Delete both files**

```bash
git rm lib/core/widgets/placeholder_section.dart test/core/widgets/placeholder_section_test.dart
```

- [ ] **Step 3: Run the whole suite and analyze**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues (no dangling imports); every remaining test green.

- [ ] **Step 4: Commit**

```bash
git commit -m "$(cat <<'EOF'
Remove PlaceholderSection: no longer used by any page

Every feature page now has its own real content (Tasks 2-9 of the
Fase 5 content plan) instead of wrapping PlaceholderSection.
EOF
)"
```

---

### Task 11: Final verification

**Files:** none (verification only).

- [ ] **Step 1: Static checks**

Run:
```bash
flutter analyze
flutter test
flutter build web --release
```
Expected: no analyzer issues, full test suite green, build succeeds.

- [ ] **Step 2: Confirm you're testing against the CI-pinned Flutter version**

CI (`.github/workflows/deploy.yml`) is pinned to Flutter `3.47.2`. Check:

```bash
flutter --version
```

If it does not report `3.47.2`, this repo's Fase 4 CI incident (commit
`8df680b`) showed the local dev SDK can be far enough behind CI's pinned
version to hide real breakage (a Material API rename, a dependency's
constant-evaluation incompatibility) that only shows up when you build
against the exact version CI uses. Download it before proceeding:

```bash
mkdir -p /tmp/flutter-ci-check && cd /tmp/flutter-ci-check
curl -L -o flutter.zip "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.47.2-stable.zip"
unzip -q flutter.zip
```

Extract to a **short path** (e.g. `C:\fci\flutter`, not deep inside a temp
directory) — Windows' command-line length limit breaks the SDK's first-run
pub-cache-preload step if the path is long/deeply nested. Then re-run Step 1
with that SDK's `bin` directory prepended to `PATH`.

- [ ] **Step 3: Real-browser visual check**

Static checks and widget tests don't execute in a real browser engine — this
project's history (Fase 3's blank-page bug, Fase 4's nav-color bug) shows
real bugs slip through both. Do the same real-browser check those phases
used.

Install Playwright in a scratch directory **outside the repo** if not
already available:

```bash
mkdir -p /tmp/portfolio-verify && cd /tmp/portfolio-verify
npm init -y
npm install playwright
npx playwright install chromium
```

Serve the release build from the repo's `build/web` directory (path from
the repo root):

```bash
cd build/web && python -m http.server 8766 --bind 127.0.0.1 &
```

In `/tmp/portfolio-verify`, create `verify.js`:

```javascript
const { chromium } = require('playwright');
const BASE = 'http://127.0.0.1:8766';

const PAGES = [
  { path: '/', expectText: 'Víctor Welter' },
  { path: '/sobre', expectText: 'Víctor Vinícius Welter' },
  { path: '/experiencia', expectText: 'Experiência anterior' },
  { path: '/formacao', expectText: 'Bacharelado, Engenharia de Computação' },
  { path: '/skills', expectText: 'Arquitetura & Cloud' },
  { path: '/projetos', expectText: 'Bee Visit Tracking & Counting' },
  { path: '/curriculo', expectText: 'Ver Currículo (PDF)' },
  { path: '/contato', expectText: 'victorwelter2003@gmail.com' },
];

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const errors = [];
  page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
  page.on('pageerror', (e) => errors.push('pageerror: ' + e.message));

  await page.setViewportSize({ width: 1300, height: 900 });

  for (const { path, expectText } of PAGES) {
    await page.goto(BASE + '/#' + path, { waitUntil: 'load', timeout: 60000 });
    await page.waitForTimeout(1500);
    const found = await page.getByText(expectText, { exact: false }).count();
    console.log(`[${path}] "${expectText}" found: ${found > 0}`);
    await page.screenshot({ path: `page-${path.replace('/', 'home')}.png` });
  }

  // Confirm the résumé PDF button opens a new tab pointing at the PDF.
  await page.goto(BASE + '/#/curriculo', { waitUntil: 'load' });
  await page.waitForTimeout(1500);
  const [popup] = await Promise.all([
    page.waitForEvent('popup', { timeout: 10000 }).catch(() => null),
    page.getByText('Ver Currículo (PDF)', { exact: false }).click(),
  ]);
  console.log('Résumé PDF popup URL:', popup ? popup.url() : 'NO POPUP OPENED');

  console.log('Total console/page errors:', errors.length);
  errors.forEach((e) => console.log('  ' + e));

  await browser.close();
})();
```

Run it and inspect the output and screenshots:

```bash
node verify.js
```

Confirm:
1. `Total console/page errors: 0`.
2. Every page in `PAGES` reports `found: true`.
3. `Résumé PDF popup URL` ends with `assets/documents/curriculo-victor-welter.pdf` (confirms the `Uri.base.resolve` path construction works against a real served site, not just the unit test's VM-local `Uri.base`).
4. Each screenshot shows real content, not a blank page or leftover placeholder text.

Fix anything this step finds before proceeding. When done, stop the local
server (`kill %1` or find/kill the `http.server` process) — nothing from
this step gets committed.

- [ ] **Step 4: Report status**

Fase 5 (Conteúdo) is done when Steps 1-3 all pass clean. Remaining known
gaps, not part of this plan: `BarberApp` (needs real project details from
Víctor before it can be added — see the design spec's Open Items) and
whether the Bee Visit Tracking & Counting repo ever gets made public (if it
does, `projects_data.dart`'s `links: []` for that entry should be updated in
a follow-up, not guessed now).
