import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_section.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderSection(
      title: 'Formação',
      message:
          'PLACEHOLDER: Engenharia da Computação, Técnico em Informática e '
          'outras formações (Fase 5).',
    );
  }
}
