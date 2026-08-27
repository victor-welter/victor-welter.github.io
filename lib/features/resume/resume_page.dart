import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_section.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderSection(
      title: 'Currículo',
      message:
          'PLACEHOLDER: resumo profissional e botão de download do PDF '
          '(Fase 5).',
    );
  }
}
