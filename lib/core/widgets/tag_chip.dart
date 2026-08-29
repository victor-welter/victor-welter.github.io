import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small pill-shaped tag for skill names and project tech stacks — the
/// mono-font/full-pill convention the Fase 4 design spec reserved for
/// exactly this kind of technical/code-like UI element.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTheme.monoTextStyle.copyWith(
          color: colorScheme.onSurface,
          fontSize: 13,
        ),
      ),
    );
  }
}
