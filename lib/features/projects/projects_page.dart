import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/section_card.dart';
import '../../core/widgets/tag_chip.dart';
import 'projects_data.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final featured = projectEntries.where(
      (p) => p.tier == ProjectTier.featured,
    );
    final secondary = projectEntries.where(
      (p) => p.tier == ProjectTier.secondary,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Projetos', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final project in featured) _ProjectCard(project: project),
            const SizedBox(height: 12),
            Text('Outros projetos', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final project in secondary)
              _SecondaryProjectRow(project: project),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(project.name, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(project.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tech in project.techStack) TagChip(tech),
                    ],
                  ),
                  if (project.links.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        for (final link in project.links)
                          TextButton(
                            onPressed: () => launchUrl(Uri.parse(link.url)),
                            child: Text(link.label),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryProjectRow extends StatelessWidget {
  const _SecondaryProjectRow({required this.project});

  final ProjectEntry project;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: project.links.isEmpty
                ? null
                : () => launchUrl(Uri.parse(project.links.first.url)),
            child: Text(
              '${project.name} — ${project.description}',
              style: textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}
