import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Contato', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          _ContactLink(
            label: 'victorwelter2003@gmail.com',
            onTap: () =>
                launchUrl(Uri.parse('mailto:victorwelter2003@gmail.com')),
          ),
          _ContactLink(
            label: 'linkedin.com/in/victor-welter',
            onTap: () => launchUrl(
              Uri.parse('https://www.linkedin.com/in/victor-welter'),
            ),
          ),
          _ContactLink(
            label: 'github.com/victor-welter',
            onTap: () =>
                launchUrl(Uri.parse('https://github.com/victor-welter')),
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

class _ContactLink extends StatelessWidget {
  const _ContactLink({required this.label, required this.onTap});

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
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
