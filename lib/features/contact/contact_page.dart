import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/widgets/section_card.dart';
import 'mailto.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final uri = buildMailtoUri(
      name: _nameController.text,
      subject: _subjectController.text,
      message: _messageController.text,
    );
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final formCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Envie uma mensagem', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Assunto'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Mensagem'),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _sendMessage, child: const Text('Enviar')),
          const SizedBox(height: 12),
          // "Enviar" hands the message to the visitor's mail client via a
          // mailto: link — there is no backend to submit to. On web,
          // url_launcher_web calls window.open() and reports success whether
          // or not a mail handler exists, so there is no reliable signal to
          // drive a success/failure message off. Say up front what the button
          // does, and repeat the address here so a visitor whose machine has
          // no mail client configured still has something to act on without
          // hunting for the panel beside this one.
          Text(
            'Isso abrirá seu cliente de e-mail padrão. Se nada acontecer, '
            'escreva para victorwelter2003@gmail.com.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );

    final infoCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Informações de contato', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          _ContactLink(
            icon: Icons.email,
            label: 'victorwelter2003@gmail.com',
            onTap: () =>
                launchUrl(Uri.parse('mailto:victorwelter2003@gmail.com')),
          ),
          _ContactLink(
            icon: Icons.link,
            label: 'linkedin.com/in/victor-welter',
            onTap: () => launchUrl(
              Uri.parse('https://www.linkedin.com/in/victor-welter'),
            ),
          ),
          _ContactLink(
            icon: Icons.code,
            label: 'github.com/victor-welter',
            onTap: () =>
                launchUrl(Uri.parse('https://github.com/victor-welter')),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 18),
              const SizedBox(width: 8),
              // Expanded so the address wraps instead of overflowing the
              // Row once this panel is squeezed to half-width side-by-side
              // with formCard on tablet/desktop.
              Expanded(
                child: Text(
                  'Três de Maio, Rio Grande do Sul, Brasil',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Material(
      // TextField requires a Material ancestor (debugCheckHasMaterial).
      // In the running app that ancestor comes from AppShell's Scaffold,
      // but ContactPage is also pumped standalone (MaterialApp(home:
      // ContactPage()), matching every other *_page_test.dart in this
      // codebase) without a Scaffold — so make ContactPage self-sufficient
      // the same way `_ContactLink` already does for InkWell, below.
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Contato', style: textTheme.headlineMedium),
              const SizedBox(height: 16),
              context.isMobile
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        formCard,
                        const SizedBox(height: 16),
                        infoCard,
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: formCard),
                          const SizedBox(width: 16),
                          Expanded(child: infoCard),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactLink extends StatelessWidget {
  const _ContactLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              // Expanded so long labels (e.g. the LinkedIn URL) wrap
              // instead of overflowing once this panel is squeezed to
              // half-width side-by-side with formCard on tablet/desktop.
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
