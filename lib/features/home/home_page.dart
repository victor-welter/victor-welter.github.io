import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderSection(
      title: 'Home',
      message: 'PLACEHOLDER: apresentação principal da Home (Fase 5).',
    );
  }
}
