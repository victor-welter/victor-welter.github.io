import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/about/about_page.dart';
import '../features/contact/contact_page.dart';
import '../features/education/education_page.dart';
import '../features/experience/experience_page.dart';
import '../features/home/home_page.dart';
import '../features/not_found/not_found_page.dart';
import '../features/projects/projects_page.dart';
import '../features/resume/resume_page.dart';
import '../features/skills/skills_page.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => AppShell(
      currentPath: state.uri.path,
      child: const NotFoundPage(),
    ),
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentPath: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/sobre',
            builder: (context, state) => const AboutPage(),
          ),
          GoRoute(
            path: '/experiencia',
            builder: (context, state) => const ExperiencePage(),
          ),
          GoRoute(
            path: '/formacao',
            builder: (context, state) => const EducationPage(),
          ),
          GoRoute(
            path: '/skills',
            builder: (context, state) => const SkillsPage(),
          ),
          GoRoute(
            path: '/projetos',
            builder: (context, state) => const ProjectsPage(),
          ),
          GoRoute(
            path: '/curriculo',
            builder: (context, state) => const ResumePage(),
          ),
          GoRoute(
            path: '/contato',
            builder: (context, state) => const ContactPage(),
          ),
        ],
      ),
    ],
  );
}
