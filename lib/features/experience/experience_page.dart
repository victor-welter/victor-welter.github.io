import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_chevron_divider.dart';
import '../../core/widgets/section_card.dart';
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
            const BrandChevronDivider(),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isCurrent = entry.period.contains('Presente');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        padding: EdgeInsets.zero,
        // IntrinsicHeight gives the Row a real height to stretch its
        // children to — without it, CrossAxisAlignment.stretch inside a
        // Row whose parent (ultimately a SingleChildScrollView) imposes no
        // height constraint would ask the accent-bar Container to be
        // infinitely tall and crash.
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: isCurrent ? colorScheme.primary : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.role, style: textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.company} · ${entry.period}',
                        style: AppTheme.monoTextStyle.copyWith(
                          color: textTheme.bodyMedium?.color,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final bullet in entry.bullets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• $bullet',
                            style: textTheme.bodyLarge,
                          ),
                        ),
                    ],
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
