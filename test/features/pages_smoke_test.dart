import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/contact/contact_page.dart';
import 'package:portfolio/features/education/education_page.dart';
import 'package:portfolio/features/experience/experience_page.dart';
import 'package:portfolio/features/not_found/not_found_page.dart';
import 'package:portfolio/features/projects/projects_page.dart';
import 'package:portfolio/features/resume/resume_page.dart';
import 'package:portfolio/features/skills/skills_page.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget page) {
    return tester.pumpWidget(MaterialApp(home: page));
  }

  testWidgets('ExperiencePage shows its placeholder message', (tester) async {
    await pump(tester, const ExperiencePage());
    expect(
      find.text(
        'PLACEHOLDER: timeline de experiências profissionais (Fase 5).',
      ),
      findsOneWidget,
    );
  });

  testWidgets('EducationPage shows its placeholder message', (tester) async {
    await pump(tester, const EducationPage());
    expect(
      find.text(
        'PLACEHOLDER: Engenharia da Computação, Técnico em Informática e '
        'outras formações (Fase 5).',
      ),
      findsOneWidget,
    );
  });

  testWidgets('SkillsPage shows its placeholder message', (tester) async {
    await pump(tester, const SkillsPage());
    expect(
      find.text('PLACEHOLDER: tecnologias organizadas por categoria (Fase 5).'),
      findsOneWidget,
    );
  });

  testWidgets('ProjectsPage shows its placeholder message', (tester) async {
    await pump(tester, const ProjectsPage());
    expect(
      find.text('PLACEHOLDER: cards de projetos (Fase 6).'),
      findsOneWidget,
    );
  });

  testWidgets('ResumePage shows its placeholder message', (tester) async {
    await pump(tester, const ResumePage());
    expect(
      find.text(
        'PLACEHOLDER: resumo profissional e botão de download do PDF '
        '(Fase 5).',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ContactPage shows its placeholder message', (tester) async {
    await pump(tester, const ContactPage());
    expect(
      find.text(
        'PLACEHOLDER: LinkedIn, GitHub, e-mail e outros contatos (Fase 5).',
      ),
      findsOneWidget,
    );
  });

  testWidgets('NotFoundPage shows a not-found message', (tester) async {
    await pump(tester, const NotFoundPage());
    expect(find.text('Página não encontrada'), findsOneWidget);
  });
}
