import 'package:flutter/material.dart';

import 'experience_data.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = experienceEntries.where(
      (e) => e.tier == ExperienceTier.primary,
    );
    final previous = experienceEntries.where(
      (e) => e.tier == ExperienceTier.previous,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Experiência', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final entry in primary) _ExperienceCard(entry: entry),
            const SizedBox(height: 12),
            Text('Experiência anterior', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final entry in previous) _PreviousExperienceRow(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.entry});

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.role, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${entry.company} · ${entry.period}', style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          for (final bullet in entry.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $bullet', style: textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}

class _PreviousExperienceRow extends StatelessWidget {
  const _PreviousExperienceRow({required this.entry});

  final ExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${entry.role} — ${entry.company} (${entry.period})',
        style: textTheme.bodyMedium,
      ),
    );
  }
}
