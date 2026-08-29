import 'package:flutter/material.dart';

import 'education_data.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Formação', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final entry in educationEntries) ...[
            Text(entry.degree, style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(entry.institution, style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '${entry.period} · ${entry.status}',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
          Text('Certificações', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final certification in certifications)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $certification', style: textTheme.bodyLarge),
            ),
          const SizedBox(height: 20),
          Text('Publicações', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final publication in publications)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $publication', style: textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}
