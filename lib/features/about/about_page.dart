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
