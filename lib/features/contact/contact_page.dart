import 'package:flutter/material.dart';

import '../../core/widgets/placeholder_section.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderSection(
      title: 'Contato',
      message:
          'PLACEHOLDER: LinkedIn, GitHub, e-mail e outros contatos (Fase 5).',
    );
  }
}
