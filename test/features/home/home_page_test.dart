import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/widgets/hero_photo.dart';
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

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Ver Projetos'));
    await tester.tap(find.widgetWithText(FilledButton, 'Ver Projetos'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectsPage), findsOneWidget);
  });

  testWidgets('the "Entrar em Contato" button navigates to /contato', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Entrar em Contato'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'Entrar em Contato'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactPage), findsOneWidget);
  });

  testWidgets('shows the hero photo', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.byType(HeroPhoto), findsOneWidget);
  });
}
