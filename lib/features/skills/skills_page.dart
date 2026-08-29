import 'package:flutter/material.dart';

import '../../core/widgets/tag_chip.dart';
import 'skills_data.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skills', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final category in skillCategories) ...[
              Text(category.name, style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final skill in category.skills) TagChip(skill)],
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
