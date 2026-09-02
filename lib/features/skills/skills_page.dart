import 'package:flutter/material.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/tag_chip.dart';
import 'skills_data.dart';

const Map<String, IconData> _categoryIcons = {
  'Mobile': Icons.smartphone,
  'Backend & Dados': Icons.storage,
  'IA & Automação': Icons.auto_awesome,
  'Processos & Qualidade': Icons.rule,
  'Arquitetura & Cloud': Icons.cloud,
};

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final columns = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);
    const spacing = 16.0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skills', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) /
                    columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final category in skillCategories)
                      SizedBox(
                        width: cardWidth,
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _categoryIcons[category.name] ??
                                        Icons.category,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: textTheme.titleLarge,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final skill in category.skills)
                                    TagChip(skill),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
