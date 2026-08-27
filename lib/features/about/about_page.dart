import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_section.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderSection(
      title: 'Sobre',
      message:
          'PLACEHOLDER: trajetória, formação e objetivos de carreira (Fase 5).',
    );
  }
}
