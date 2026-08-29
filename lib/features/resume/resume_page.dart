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
