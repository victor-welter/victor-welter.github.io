import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/hero_photo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Víctor Welter',
          style: AppTheme.heroDisplayStyle.copyWith(
            color: textTheme.headlineLarge?.color,
          ),
        ),
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
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: context.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(child: HeroPhoto(size: 200)),
                  const SizedBox(height: 24),
                  textColumn,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: textColumn),
                  const SizedBox(width: 40),
                  const HeroPhoto(),
                ],
              ),
      ),
    );
  }
}
