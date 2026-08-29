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
